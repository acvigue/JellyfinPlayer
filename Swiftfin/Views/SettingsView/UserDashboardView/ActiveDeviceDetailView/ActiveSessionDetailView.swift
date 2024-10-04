//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Foundation
import JellyfinAPI
import SwiftUI
import SwiftUIIntrospect

struct ActiveDeviceDetailView: View {

    @EnvironmentObject
    private var router: SettingsCoordinator.Router

    @ObservedObject
    var box: BindingBox<SessionInfo?>

    @State
    private var currentDate: Date = .now

    private let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()

    // MARK: Create Idle Content View

    @ViewBuilder
    private func idleContent(session: SessionInfo) -> some View {
        List {
            Section(L10n.user) {
                if let userID = session.userID {
                    SettingsView.UserProfileRow(
                        user: .init(
                            id: userID,
                            name: session.userName
                        )
                    )
                }

                if let client = session.client {
                    TextPairView(leading: L10n.client, trailing: client)
                }

                if let device = session.deviceName {
                    TextPairView(leading: L10n.device, trailing: device)
                }

                if let applicationVersion = session.applicationVersion {
                    TextPairView(leading: L10n.version, trailing: applicationVersion)
                }

                if let lastActivityDate = session.lastActivityDate {
                    TextPairView(
                        L10n.lastSeen,
                        value: Text(lastActivityDate, format: .relative(presentation: .numeric, unitsStyle: .narrow))
                    )
                    .id(currentDate)
                    .monospacedDigit()
                }
            }
        }
    }

    // MARK: Create Session Content View

    @ViewBuilder
    private func sessionContent(
        session: SessionInfo,
        nowPlayingItem: BaseItemDto,
        playState: PlayerStateInfo
    ) -> some View {
        List {

            nowPlayingSection(item: nowPlayingItem)

            Section(L10n.progress) {
                ActiveDevicesView.ProgressSection(
                    item: nowPlayingItem,
                    playState: playState,
                    transcodingInfo: session.transcodingInfo
                )
            }

            Section(L10n.user) {
                if let userID = session.userID {
                    SettingsView.UserProfileRow(
                        user: .init(
                            id: userID,
                            name: session.userName
                        )
                    )
                }

                if let client = session.client {
                    TextPairView(leading: L10n.client, trailing: client)
                }

                if let device = session.deviceName {
                    TextPairView(leading: L10n.device, trailing: device)
                }

                if let applicationVersion = session.applicationVersion {
                    TextPairView(leading: L10n.version, trailing: applicationVersion)
                }
            }

            Section(L10n.streams) {
                if let playMethod = playState.playMethod {
                    TextPairView(leading: L10n.method, trailing: playMethod.description)
                }

                StreamSection(
                    nowPlayingItem: nowPlayingItem,
                    transcodingInfo: session.transcodingInfo
                )
            }

            if let transcodeReasons = session.transcodingInfo?.transcodeReasons {
                Section(L10n.transcodeReasons) {
                    TranscodeSection(transcodeReasons: transcodeReasons)
                }
            }
        }
    }

    // MARK: Now Playing Section

    @ViewBuilder
    private func nowPlayingSection(item: BaseItemDto) -> some View {
        Section {
            HStack(alignment: .bottom, spacing: 12) {
                Group {
                    if item.type == .audio {
                        ZStack {
                            Color.clear

                            ImageView(item.squareImageSources(maxWidth: 60))
                                .failure {
                                    SystemImageContentView(systemName: item.systemImage)
                                }
                        }
                        .squarePosterStyle()
                    } else {
                        ZStack {
                            Color.clear

                            ImageView(item.portraitImageSources(maxWidth: 60))
                                .failure {
                                    SystemImageContentView(systemName: item.systemImage)
                                }
                        }
                        .posterStyle(.portrait)
                    }
                }
                .frame(width: 100)
                .accessibilityIgnoresInvertColors()

                VStack(alignment: .leading) {

                    if let parent = item.parentTitle {
                        Text(parent)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    Text(item.displayTitle)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom)
            }
        }
        .listRowBackground(Color.clear)
        .listRowCornerRadius(0)
        .listRowInsets(.zero)
    }

    var body: some View {
        ZStack {
            if let session = box.value {
                if let nowPlayingItem = session.nowPlayingItem, let playState = session.playState {
                    sessionContent(
                        session: session,
                        nowPlayingItem: nowPlayingItem,
                        playState: playState
                    )
                } else {
                    idleContent(session: session)
                }
            } else {
                Text(L10n.noSession)
            }
        }
        .animation(.linear(duration: 0.2), value: box.value)
        .navigationTitle(L10n.session)
        .onReceive(timer) { newValue in
            currentDate = newValue
        }
    }
}