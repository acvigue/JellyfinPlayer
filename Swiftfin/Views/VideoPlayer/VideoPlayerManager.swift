//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Foundation
import JellyfinAPI
import VLCUI

class VideoPlayerManager: ViewModel {

    // MARK: Properties

    @Published
    var audioTrackIndex: Int = -1
    @Published
    var rate: Float = 1
    @Published
    var state: VLCVideoPlayer.State = .opening
    @Published
    var subtitleTrackIndex: Int = -1

    // MARK: ViewModel

    @Published
    var previousViewModel: ItemVideoPlayerViewModel?
    @Published
    var currentViewModel: ItemVideoPlayerViewModel? {
        willSet {
            guard let newValue else { return }
            getAdjacentEpisodes(for: newValue.item)
        }
    }

    @Published
    var nextViewModel: ItemVideoPlayerViewModel?

    // MARK: init

    init(viewModel: ItemVideoPlayerViewModel) {
        self.currentViewModel = viewModel
        super.init()

        getAdjacentEpisodes(for: viewModel.item)
    }

    init(item: BaseItemDto) {
        super.init()
        item.createItemVideoPlayerViewModel()
            .sink { completion in
                self.handleAPIRequestError(completion: completion)
            } receiveValue: { viewModels in
                self.currentViewModel = viewModels[0]
            }
            .store(in: &cancellables)
    }

    func selectNextViewModel() {
        guard let nextViewModel else { return }
        currentViewModel = nextViewModel
        previousViewModel = nil
        self.nextViewModel = nil

        getAdjacentEpisodes(for: nextViewModel.item)
    }

    func selectPreviousViewModel() {
        guard let previousViewModel else { return }
        currentViewModel = previousViewModel
        self.previousViewModel = nil
        nextViewModel = nil

        getAdjacentEpisodes(for: previousViewModel.item)
    }

    func onTicksUpdated(ticks: Int, playbackInformation: VLCVideoPlayer.PlaybackInformation) {

        if audioTrackIndex != playbackInformation.currentAudioTrack.index {
            audioTrackIndex = playbackInformation.currentAudioTrack.index
            print("Current audio track index: \(playbackInformation.currentAudioTrack.index)")
        }

        if rate != playbackInformation.playbackRate {
            self.rate = playbackInformation.playbackRate
        }

        if subtitleTrackIndex != playbackInformation.currentSubtitleTrack.index {
            subtitleTrackIndex = playbackInformation.currentSubtitleTrack.index
        }
    }

    func onStateUpdated(state: VLCVideoPlayer.State, playbackInformation: VLCVideoPlayer.PlaybackInformation) {
        guard self.state != state else { return }
        self.state = state
    }
}

extension VideoPlayerManager {
    func getAdjacentEpisodes(for item: BaseItemDto) {
        guard let seriesID = item.seriesId, item.type == .episode else { return }

        TvShowsAPI.getEpisodes(
            seriesId: seriesID,
            userId: SessionManager.main.currentLogin.user.id,
            fields: [.chapters],
            adjacentTo: item.id,
            limit: 3
        )
        .sink(receiveCompletion: { completion in
            self.handleAPIRequestError(completion: completion)
        }, receiveValue: { response in

            // 4 possible states:
            //  1 - only current episode
            //  2 - two episodes with next episode
            //  3 - two episodes with previous episode
            //  4 - three episodes with current in middle

            // State 1
            guard let items = response.items, items.count > 1 else { return }

            if items.count == 2 {
                if items[0].id == item.id {
                    // State 2
                    let nextItem = items[1]

                    nextItem.createItemVideoPlayerViewModel()
                        .sink { completion in
                            print(completion)
                        } receiveValue: { viewModels in
                            self.nextViewModel = viewModels.first
                        }
                        .store(in: &self.cancellables)
                } else {
                    // State 3
                    let previousItem = items[0]

                    previousItem.createItemVideoPlayerViewModel()
                        .sink { completion in
                            print(completion)
                        } receiveValue: { viewModels in
                            self.previousViewModel = viewModels.first
                        }
                        .store(in: &self.cancellables)
                }
            } else {
                // State 4

                let previousItem = items[0]
                let nextItem = items[2]

                previousItem.createItemVideoPlayerViewModel()
                    .sink { completion in
                        print(completion)
                    } receiveValue: { viewModels in
                        self.previousViewModel = viewModels.first
                    }
                    .store(in: &self.cancellables)

                nextItem.createItemVideoPlayerViewModel()
                    .sink { completion in
                        print(completion)
                    } receiveValue: { viewModels in
                        self.nextViewModel = viewModels.first
                    }
                    .store(in: &self.cancellables)
            }
        })
        .store(in: &cancellables)
    }
}