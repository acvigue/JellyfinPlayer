//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import CoreData
import Defaults
import Factory
import Stinsen
import SwiftUI

struct SettingsView: View {

    @Default(.accentColor)
    private var accentColor

    #warning("TODO: user app appearance")
    @Default(.appearance)
    private var appAppearance
    @Default(.VideoPlayer.videoPlayerType)
    private var videoPlayerType

    @EnvironmentObject
    private var router: SettingsCoordinator.Router

    @StateObject
    private var viewModel = SettingsViewModel()

    var body: some View {
        Form {

            Section {

                UserProfileRow {
                    router.route(to: \.userProfile, viewModel)
                }

                // TODO: admin users go to dashboard instead
                ChevronButton(
                    title: L10n.server,
                    subtitle: viewModel.userSession.server.name
                )
                .onSelect {
                    router.route(to: \.serverDetail, viewModel.userSession.server)
                }
            }

            ListRowButton(L10n.switchUser) {
                router.dismissCoordinator {
                    viewModel.signOut()
                }
            }
            .foregroundStyle(.primary, Color.accentColor)

            Section(L10n.videoPlayer) {
                CaseIterablePicker(
                    title: L10n.videoPlayerType,
                    selection: $videoPlayerType
                )

                ChevronButton(title: L10n.nativePlayer)
                    .onSelect {
                        router.route(to: \.nativePlayerSettings)
                    }

                ChevronButton(title: L10n.videoPlayer)
                    .onSelect {
                        router.route(to: \.videoPlayerSettings)
                    }
            }

            Section(L10n.accessibility) {
                CaseIterablePicker(title: L10n.appearance, selection: $appAppearance)

                ChevronButton(title: L10n.customize)
                    .onSelect {
                        router.route(to: \.customizeViewsSettings)
                    }

                ChevronButton(title: L10n.experimental)
                    .onSelect {
                        router.route(to: \.experimentalSettings)
                    }
            }

            Section {
                ColorPicker(L10n.accentColor, selection: $accentColor, supportsOpacity: false)
            } footer: {
                Text(L10n.accentColorDescription)
            }

            ChevronButton(title: L10n.logs)
                .onSelect {
                    router.route(to: \.log)
                }

            #if DEBUG

            ChevronButton(title: "Debug")
                .onSelect {
                    router.route(to: \.debugSettings)
                }

            #endif
        }
        .navigationTitle(L10n.settings)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarCloseButton {
            router.dismissCoordinator()
        }
    }
}
