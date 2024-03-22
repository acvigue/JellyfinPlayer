//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import CoreStore
import Defaults
import Factory
import Foundation
import JellyfinAPI
import Pulse

final class UserSignInViewModel: ViewModel {

    @Published
    private(set) var publicUsers: [UserDto] = []
    @Published
    private(set) var quickConnectCode: String?
    @Published
    private(set) var quickConnectEnabled = false

    let client: JellyfinClient
    let server: SwiftfinStore.State.Server

    private var quickConnectMonitorTask: Task<Void, Never>?
    // We want to enforce that only one monitoring task runs at a time, done by this ID.
    // While cancelling a task is preferable to assigning IDs, cancelling has proven
    // unreliable and unpredictable.
    private var quickConnectMonitorTaskID: UUID?
    // We want to signal to the monitor task when we're ready to poll for authentication.
    // Without this, we may encounter a race condition where the monitor expects
    // the secret before it's been fetched, and exits prematurely.
    private var quickConnectStatus: QuickConnectStatus = .neutral
    // If, for whatever reason, the monitor task isn't stopped correctly, we don't want
    // to let it silently run forever.
    private let quickConnectMaxRetries = 200
    private var quickConnectSecret: String?

    enum QuickConnectStatus {
        case neutral
        case fetchingSecret
        case fetchingSecretFailed
        case awaitingAuthentication
    }

    init(server: ServerState) {
        self.client = JellyfinClient(
            configuration: .swiftfinConfiguration(url: server.currentURL),
            sessionDelegate: URLSessionProxyDelegate()
        )
        self.server = server
        super.init()
    }

    func signIn(username: String, password: String) async throws {

        let username = username.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .objectReplacement)
        let password = password.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .objectReplacement)

        let response = try await client.signIn(username: username, password: password)

        let user: UserState

        do {
            user = try await createLocalUser(response: response)
        } catch {
            if case let SwiftfinStore.Error.existingUser(existingUser) = error {
                user = existingUser
            } else {
                throw error
            }
        }

        Defaults[.lastServerUserID] = user.id
        Container.userSession.reset()
        Notifications[.didSignIn].post()
    }

    func getPublicUsers() async throws {
        let publicUsersPath = Paths.getPublicUsers
        let response = try await client.send(publicUsersPath)

        await MainActor.run {
            publicUsers = response.value
        }
    }

    func checkQuickConnect() async throws {
        let quickConnectEnabledPath = Paths.getEnabled
        let response = try await client.send(quickConnectEnabledPath)
        let decoder = JSONDecoder()
        let isEnabled = try? decoder.decode(Bool.self, from: response.value)

        await MainActor.run {
            quickConnectEnabled = isEnabled ?? false
        }
    }

    func startQuickConnect() -> AsyncStream<QuickConnectResult> {
        quickConnectStatus = .fetchingSecret

        Task {

            let initiatePath = Paths.initiate
            let response = try? await client.send(initiatePath)

            guard let response else {
                // TODO: Handle this directly or surface the error
                quickConnectStatus = .fetchingSecretFailed
                return
            }

            await MainActor.run {
                quickConnectSecret = response.value.secret
                quickConnectCode = response.value.code
                quickConnectStatus = .awaitingAuthentication
            }
        }

        let taskID = UUID()
        quickConnectMonitorTaskID = taskID

        return .init { continuation in

            checkAuthStatus(continuation: continuation, id: taskID)
        }
    }

    private func checkAuthStatus(continuation: AsyncStream<QuickConnectResult>.Continuation, id: UUID, tries: Int = 0) {
        let task = Task {
            // Don't race into failure while we're fetching the secret.
            while quickConnectStatus == .fetchingSecret {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }

            guard let quickConnectSecret, quickConnectStatus == .awaitingAuthentication, quickConnectMonitorTaskID == id else { return }

            if tries > quickConnectMaxRetries {
                logger.warning("Hit max retries while using quick connect, did `checkAuthStatus` keep running after signing in?")
                stopQuickConnectAuthCheck()
                return
            }

            let connectPath = Paths.connect(secret: quickConnectSecret)
            let response = try? await client.send(connectPath)

            if let responseValue = response?.value, responseValue.isAuthenticated ?? false {
                continuation.yield(responseValue)
                quickConnectStatus = .neutral
                stopQuickConnectAuthCheck()
                return
            }

            try? await Task.sleep(nanoseconds: 5_000_000_000)

            checkAuthStatus(continuation: continuation, id: id, tries: tries + 1)
        }

        self.quickConnectMonitorTask = task
    }

    func stopQuickConnectAuthCheck() {
        self.quickConnectMonitorTaskID = nil
    }

    func signIn(quickConnectSecret: String) async throws {
        let quickConnectPath = Paths.authenticateWithQuickConnect(.init(secret: quickConnectSecret))
        let response = try await client.send(quickConnectPath)

        let user: UserState

        do {
            user = try await createLocalUser(response: response.value)
        } catch {
            if case let SwiftfinStore.Error.existingUser(existingUser) = error {
                user = existingUser
            } else {
                throw error
            }
        }

        Defaults[.lastServerUserID] = user.id
        Container.userSession.reset()
        Notifications[.didSignIn].post()
    }

    @MainActor
    private func createLocalUser(response: AuthenticationResult) async throws -> UserState {
        guard let accessToken = response.accessToken,
              let username = response.user?.name,
              let id = response.user?.id else { throw JellyfinAPIError("Missing user data from network call") }

        if let existingUser = try? SwiftfinStore.dataStack.fetchOne(
            From<UserModel>(),
            [Where<UserModel>(
                "id == %@",
                id
            )]
        ) {
            throw SwiftfinStore.Error.existingUser(existingUser.state)
        }

        guard let storedServer = try? SwiftfinStore.dataStack.fetchOne(
            From<SwiftfinStore.Models.StoredServer>(),
            [
                Where<SwiftfinStore.Models.StoredServer>(
                    "id == %@",
                    server.id
                ),
            ]
        )
        else { fatalError("No stored server associated with given state server?") }

        let user = try SwiftfinStore.dataStack.perform { transaction in
            let newUser = transaction.create(Into<UserModel>())

            newUser.accessToken = accessToken
            newUser.appleTVID = ""
            newUser.id = id
            newUser.username = username

            let editServer = transaction.edit(storedServer)!
            editServer.users.insert(newUser)

            return newUser.state
        }

        return user
    }
}
