//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Combine
import Foundation
import JellyfinAPI
import Stinsen

struct AddServerURIPayload: Identifiable {

    let server: SwiftfinStore.State.Server
    let uri: String

    var id: String {
        server.id.appending(uri)
    }
}

final class ConnectToServerViewModel: ViewModel {

    @RouterObject
    var router: ConnectToServerCoodinator.Router?
    @Published
    var discoveredServers: Set<ServerDiscovery.ServerLookupResponse> = []
    @Published
    var searching = false
    @Published
    var addServerURIPayload: AddServerURIPayload?
    var backAddServerURIPayload: AddServerURIPayload?

    private let discovery = ServerDiscovery()

    var alertTitle: String {
        var message: String = ""
        if errorMessage?.code != ErrorMessage.noShowErrorCode {
            message.append(contentsOf: "\(errorMessage?.code ?? ErrorMessage.noShowErrorCode)\n")
        }
        message.append(contentsOf: "\(errorMessage?.title ?? L10n.unknownError)")
        return message
    }

    func connectToServer(uri: String, redirectCount: Int = 0) {

        #if targetEnvironment(simulator)
            var uri = uri
            if uri == "http://localhost" || uri == "localhost" {
                uri = "http://localhost:8096"
            }
        #endif

        let trimmedURI = uri.trimmingCharacters(in: .whitespaces)

        LogManager.log.debug("Attempting to connect to server at \"\(trimmedURI)\"", tag: "connectToServer")
        SessionManager.main.connectToServer(with: trimmedURI)
            .trackActivity(loading)
            .sink(receiveCompletion: { completion in
                // This is disgusting. ViewModel Error handling overall needs to be refactored
                switch completion {
                case .finished: ()
                case let .failure(error):
                    switch error {
                    case is ErrorResponse:
                        let errorResponse = error as! ErrorResponse
                        switch errorResponse {
                        case let .error(_, _, response, _):
                            // a url in the response is the result if a redirect
                            if let newURL = response?.url {
                                if redirectCount > 2 {
                                    self.handleAPIRequestError(displayMessage: L10n.tooManyRedirects, completion: completion)
                                } else {
                                    self
                                        .connectToServer(
                                            uri: newURL.absoluteString
                                                .removeRegexMatches(pattern: "/web/index.html"),
                                            redirectCount: redirectCount + 1
                                        )
                                }
                            } else {
                                self.handleAPIRequestError(completion: completion)
                            }
                        }
                    case is SwiftfinStore.Error:
                        let swiftfinError = error as! SwiftfinStore.Error
                        switch swiftfinError {
                        case let .existingServer(server):
                            self.addServerURIPayload = AddServerURIPayload(server: server, uri: uri)
                            self.backAddServerURIPayload = AddServerURIPayload(server: server, uri: uri)
                        default:
                            self.handleAPIRequestError(displayMessage: L10n.unableToConnectServer, completion: completion)
                        }
                    default:
                        self.handleAPIRequestError(displayMessage: L10n.unableToConnectServer, completion: completion)
                    }
                }
            }, receiveValue: { server in
                LogManager.log.debug("Connected to server at \"\(uri)\"", tag: "connectToServer")
                self.router?.route(to: \.userSignIn, server)
            })
            .store(in: &cancellables)
    }

    func discoverServers() {
        discoveredServers.removeAll()
        searching = true

        // Timeout after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.searching = false
        }

        discovery.locateServer { [self] server in
            if let server = server {
                discoveredServers.insert(server)
            }
        }
    }

    func addURIToServer(addServerURIPayload: AddServerURIPayload) {
        SessionManager.main.addURIToServer(server: addServerURIPayload.server, uri: addServerURIPayload.uri)
            .sink { completion in
                self.handleAPIRequestError(displayMessage: L10n.unableToConnectServer, completion: completion)
            } receiveValue: { server in
                SessionManager.main.setServerCurrentURI(server: server, uri: addServerURIPayload.uri)
                    .sink { completion in
                        self.handleAPIRequestError(displayMessage: L10n.unableToConnectServer, completion: completion)
                    } receiveValue: { _ in
                        self.router?.dismissCoordinator()
                    }
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }

    func cancelConnection() {
        for cancellable in cancellables {
            cancellable.cancel()
        }

        self.isLoading = false
    }
}
