//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Defaults
import JellyfinAPI
import SwiftUI

struct ServerUserDetailsView: View {

    // MARK: - Current Date

    @CurrentDate
    private var currentDate: Date

    // MARK: - State, Observed, & Environment Objects

    @EnvironmentObject
    private var router: AdminDashboardCoordinator.Router

    @StateObject
    private var viewModel: ServerUserAdminViewModel

    @ObservedObject
    private var profileViewModel: UserProfileImageViewModel

    // MARK: - Dialog State

    @State
    private var username: String
    @State
    private var isPresentingUsername = false

    // MARK: - Error State

    @State
    private var error: Error?

    // MARK: - Initializer

    init(user: UserDto) {
        self._viewModel = StateObject(wrappedValue: ServerUserAdminViewModel(user: user))
        self.profileViewModel = .init(userID: user.id!)
        self.username = user.name ?? ""
    }

    // MARK: - Body

    var body: some View {
        List {
            UserProfileImage(
                username: viewModel.user.name,
                imageSource: viewModel.user.profileImageSource(
                    client: viewModel.userSession.client,
                    maxWidth: 120
                )
            ) {
                router.route(to: \.userPhotoPicker, profileViewModel)
            } delete: {
                profileViewModel.send(.delete)
            }

            Section {
                if let userId = viewModel.user.id {
                    ChevronButton(L10n.password)
                        .onSelect {
                            router.route(to: \.resetUserPassword, userId)
                        }
                }
                ChevronButton(L10n.permissions)
                    .onSelect {
                        router.route(to: \.userPermissions, viewModel)
                    }
                ChevronAlertButton(
                    L10n.username,
                    subtitle: viewModel.user.name
                ) {
                    TextField(L10n.username, text: $username)
                    HStack {
                        Button(L10n.cancel) {
                            username = viewModel.user.name ?? ""
                            isPresentingUsername = false
                        }
                        Button(L10n.save) {
                            viewModel.send(.updateUsername(username))
                            isPresentingUsername = false
                        }
                    }
                }
            }

            Section(L10n.access) {
                ChevronButton(L10n.devices)
                    .onSelect {
                        router.route(to: \.userDeviceAccess, viewModel)
                    }
                ChevronButton(L10n.liveTV)
                    .onSelect {
                        router.route(to: \.userLiveTVAccess, viewModel)
                    }
                ChevronButton(L10n.media)
                    .onSelect {
                        router.route(to: \.userMediaAccess, viewModel)
                    }
            }

            Section(L10n.parentalControls) {
                ChevronButton(L10n.accessSchedules)
                    .onSelect {
                        router.route(to: \.userEditAccessSchedules, viewModel)
                    }
                // TODO: Allow items SDK 10.10 - allowedTags
                /* ChevronButton("Allow items")
                      .onSelect {
                          router.route(to: \.userAllowedTags, viewModel)
                      }
                 // TODO: Block items - blockedTags
                 ChevronButton("Block items")
                      .onSelect {
                          router.route(to: \.userBlockedTags, viewModel)
                      } */
                ChevronButton(L10n.ratings)
                    .onSelect {
                        router.route(to: \.userParentalRatings, viewModel)
                    }
            }
        }
        .navigationTitle(L10n.user)
        .onAppear {
            viewModel.send(.refresh)
        }
        .onReceive(viewModel.events) { event in
            switch event {
            case let .error(eventError):
                error = eventError
                username = viewModel.user.name ?? ""
            case .updated:
                break
            }
        }
        .errorMessage($error)
    }
}
