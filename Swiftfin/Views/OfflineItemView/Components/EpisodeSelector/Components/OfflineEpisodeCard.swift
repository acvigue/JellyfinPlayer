//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Factory
import Foundation
import JellyfinAPI
import SwiftUI

extension OfflineSeriesEpisodeSelector {

    struct EpisodeCard: View {

        @Injected(Container.downloadManager)
        private var downloadManager

        @EnvironmentObject
        private var mainRouter: MainCoordinator.Router
        @EnvironmentObject
        private var router: OfflineItemCoordinator.Router

        let offlineViewModel: OfflineViewModel
        let episode: BaseItemDto

        @ViewBuilder
        private var overlayView: some View {
            if let progressLabel = episode.progressLabel {
                LandscapePosterProgressBar(
                    title: progressLabel,
                    progress: (episode.userData?.playedPercentage ?? 0) / 100
                )
            } else if episode.userData?.isPlayed ?? false {
                ZStack(alignment: .bottomTrailing) {
                    Color.clear

                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .bottomTrailing)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .black)
                        .padding()
                }
            }
        }

        private var episodeContent: String {
            if episode.isUnaired {
                episode.airDateLabel ?? L10n.noOverviewAvailable
            } else {
                episode.overview ?? L10n.noOverviewAvailable
            }
        }

        var body: some View {
            VStack(alignment: .leading) {
                Button {
                    mainRouter.route(
                        to: \.videoPlayer,
                        DownloadVideoPlayerManager(
                            downloadTask: downloadManager.getItem(item: episode)!,
                            offlineViewModel: offlineViewModel
                        )
                    )
                } label: {
                    ZStack {
                        Color.clear

                        ImageView(episode.landscapeImageSources(maxWidth: 500))
                            .failure {
                                SystemImageContentView(systemName: episode.systemImage)
                            }

                        overlayView
                    }
                    .posterStyle(.landscape)
                }

                SeriesEpisodeSelector.EpisodeContent(
                    subHeader: episode.episodeLocator ?? .emptyDash,
                    header: episode.displayTitle,
                    content: episodeContent
                )
                .onSelect {
                    router.route(to: \.item, episode)
                }
            }
        }
    }
}