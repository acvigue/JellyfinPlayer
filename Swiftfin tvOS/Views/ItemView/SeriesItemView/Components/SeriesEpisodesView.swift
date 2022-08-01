//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Introspect
import JellyfinAPI
import SwiftUI

struct SeriesEpisodesView: View {

    @ObservedObject
    var viewModel: SeriesItemViewModel
    @FocusState
    private var isFocused: Bool
    @EnvironmentObject
    private var parentFocusGuide: FocusGuide

    var body: some View {
        VStack(spacing: 0) {
            SeasonsHStack(viewModel: viewModel)
                .environmentObject(parentFocusGuide)

            EpisodesHStack(viewModel: viewModel)
                .environmentObject(parentFocusGuide)
        }
    }
}

extension SeriesEpisodesView {

    // MARK: SeasonsHStack

    struct SeasonsHStack: View {

        @ObservedObject
        var viewModel: SeriesItemViewModel
        @EnvironmentObject
        private var focusGuide: FocusGuide
        @FocusState
        private var focusedSeason: BaseItemDto?

        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.sortedSeasons, id: \.self) { season in
                        Button {} label: {
                            Text(season.displayName)
                                .fontWeight(.semibold)
                                .fixedSize()
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .if(viewModel.selectedSeason == season) { text in
                                    text
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .id(season)
                        .focused($focusedSeason, equals: season)
                    }
                }
                .focusGuide(
                    focusGuide,
                    tag: "seasons",
                    onContentFocus: { focusedSeason = viewModel.selectedSeason },
                    top: "mediaButtons",
                    bottom: "episodes"
                )
                .frame(height: 70)
                .padding(.horizontal, 50)
                .padding(.top)
                .padding(.bottom, 45)
            }
            .onChange(of: focusedSeason) { season in
                guard let season = season else { return }
                viewModel.select(season: season)
            }
        }
    }
}

extension SeriesEpisodesView {

    // MARK: EpisodesHStack

    struct EpisodesHStack: View {

        @ObservedObject
        var viewModel: SeriesItemViewModel
        @EnvironmentObject
        private var focusGuide: FocusGuide
        @FocusState
        private var focusedEpisodeIndex: Int?
        @State
        private var lastFocusedEpisodeIndex: Int?
        @State
        private var currentEpisodes: [BaseItemDto] = []
        @State
        private var wrappedScrollView: UIScrollView?

        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 40) {
                    if !currentEpisodes.isEmpty {
                        ForEach(currentEpisodes, id: \.self) { episode in
                            EpisodeCard(episode: episode)
                                .focused($focusedEpisodeIndex, equals: episode.indexNumber ?? -1)
                        }
                    } else {
                        ForEach(1 ..< 10) { i in
                            EpisodeCard(episode: .placeHolder)
                                .redacted(reason: .placeholder)
                                .focused($focusedEpisodeIndex, equals: i)
                        }
                    }
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 50)
                .padding(.top)
            }
            .focusGuide(
                focusGuide,
                tag: "episodes",
                onContentFocus: { focusedEpisodeIndex = lastFocusedEpisodeIndex },
                top: "seasons",
                bottom: "recommended"
            )
            .transition(.opacity)
            .introspectScrollView { scrollView in
                wrappedScrollView = scrollView
            }
            .onChange(of: viewModel.selectedSeason) { _ in
                currentEpisodes = viewModel.currentEpisodes ?? []
                lastFocusedEpisodeIndex = viewModel.currentEpisodes?.first?.indexNumber ?? 1
                wrappedScrollView?.scrollToTop(animated: false)
            }
            .onChange(of: focusedEpisodeIndex) { episodeIndex in
                guard let episodeIndex = episodeIndex else { return }
                lastFocusedEpisodeIndex = episodeIndex
            }
            .onChange(of: viewModel.seasonsEpisodes) { _ in
                currentEpisodes = viewModel.currentEpisodes ?? []
            }
        }
    }
}
