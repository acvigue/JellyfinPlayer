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

    @EnvironmentObject
    private var router: AdminDashboardCoordinator.Router

    @CurrentDate
    private var currentDate: Date

    @StateObject
    private var viewModel: ServerUserAdminViewModel

    // MARK: - Initializer

    init(user: UserDto) {
        _viewModel = StateObject(wrappedValue: ServerUserAdminViewModel(user: user))
    }

    // MARK: - Body

    var body: some View {
        List {

            // TODO: Replace with Update Profile Picture & Username
            AdminDashboardView.UserSection(
                user: viewModel.user,
                lastActivityDate: viewModel.user.lastActivityDate
            )

            Section {
                if let userId = viewModel.user.id {
                    ChevronButton(L10n.password)
                        .onSelect {
                            router.route(to: \.resetUserPassword, userId)
                        }
                }
            }

            Section {
                ChevronButton(L10n.permissions)
                    .onSelect {
                        router.route(to: \.userPermissions, viewModel)
                    }

                // TODO: Parental: accessSchedules, maxParentalRating, blockUnratedItems, blockedTags, blockUnratedItems & blockedMediaFolders

                // TODO: Live TV: enabledChannels & enableAllChannels
            }

            Section(L10n.access) {
                ChevronButton(L10n.media)
                    .onSelect {
                        router.route(to: \.userMediaAccess, viewModel)
                    }

                ChevronButton(L10n.devices)
                    .onSelect {
                        router.route(to: \.userDeviceAccess, viewModel)
                    }
            }
        }
        .navigationTitle(L10n.user)
        .onAppear {
            viewModel.send(.loadDetails)
        }
    }
}
