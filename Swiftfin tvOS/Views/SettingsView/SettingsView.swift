//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Defaults
import Factory
import JellyfinAPI
import SwiftUI

struct SettingsView: View {

    @Default(.VideoPlayer.videoPlayerType)
    private var videoPlayerType

    @EnvironmentObject
    private var router: SettingsCoordinator.Router

    @StateObject
    private var viewModel = SettingsViewModel()

    var body: some View {
        SplitFormWindowView()
            .descriptionView {
                Image(.jellyfinBlobBlue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 400)
            }
            .contentView {
                SettingsViewFormSection {

                    Button {} label: {
                        TextPairView(
                            leading: L10n.user,
                            trailing: viewModel.userSession.user.username
                        )
                    }
                    .focusable(false)

                    ChevronButton(
                        L10n.server,
                        subtitle: viewModel.userSession.server.name
                    )
                    .onSelect {
                        router.route(to: \.serverDetail, viewModel.userSession.server)
                    }

                    Button {
                        viewModel.signOut()
                    } label: {
                        HStack {

                            Text(L10n.switchUser)
                                .foregroundColor(.purple)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.body.weight(.regular))
                                .foregroundColor(.secondary)
                        }
                    }

                } header: {
                    L10n.jellyfin.text
                }

                SettingsViewFormSection {

                    InlineEnumToggle(title: L10n.videoPlayer, selection: $videoPlayerType)

                    ChevronButton(L10n.videoPlayer)
                        .onSelect {
                            router.route(to: \.videoPlayerSettings)
                        }

                    ChevronButton(L10n.maximumBitrate)
                        .onSelect {
                            router.route(to: \.maximumBitrateSettings)
                        }

                } header: {
                    L10n.videoPlayer.text
                }

                SettingsViewFormSection {

                    ChevronButton(L10n.customize)
                        .onSelect {
                            router.route(to: \.customizeViewsSettings)
                        }

                    ChevronButton(L10n.experimental)
                        .onSelect {
                            router.route(to: \.experimentalSettings)
                        }

                } header: {
                    L10n.accessibility.text
                }

                SettingsViewFormSection {

                    ChevronButton(L10n.logs)
                        .onSelect {
                            router.route(to: \.log)
                        }
                }
            }
    }
}
