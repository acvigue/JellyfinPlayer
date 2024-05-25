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

class DownloadVideoPlayerManager: VideoPlayerManager {

    @Injected(Container.downloadManager)
    private var downloadManager

    private var task: DownloadEntity? = nil
    init(downloadTask: DownloadEntity) {
        super.init()
        guard let playbackURL = downloadTask.getMediaURL() else {
            logger.error("Download task does not have media url for item: \(downloadTask.item.displayTitle)")
            return
        }

        downloadTask.updatePlaybackInfo()
        self.task = downloadTask

        self.currentViewModel = .init(
            playbackURL: playbackURL,
            item: downloadTask.item,
            mediaSource: .init(),
            playSessionID: downloadTask.localPlaybackInfo.playSessionID ?? "",
            videoStreams: downloadTask.item.videoStreams,
            audioStreams: downloadTask.item.audioStreams,
            subtitleStreams: downloadTask.item.subtitleStreams,
            selectedAudioStreamIndex: downloadTask.localPlaybackInfo.audioStreamIndex ?? 1,
            selectedSubtitleStreamIndex: downloadTask.localPlaybackInfo.subtitleStreamIndex ?? -1,
            chapters: downloadTask.item.fullChapterInfo,
            streamType: .direct
        )
    }

    override func getAdjacentEpisodes(for item: BaseItemDto) {
        Task { @MainActor in

            let (prev, next) = downloadManager.getAdjacent(item: item)

            var nextViewModel: VideoPlayerViewModel?
            var previousViewModel: VideoPlayerViewModel?

            if let next {
                nextViewModel = try next.offlinePlayerViewModel()
            }

            if let prev {
                previousViewModel = try prev.offlinePlayerViewModel()
            }

            await MainActor.run {
                self.nextViewModel = nextViewModel
                self.previousViewModel = previousViewModel
            }
        }
    }

    override func sendStartReport() {
        updateProgress()
    }

    override func sendPauseReport() {
        updateProgress()
    }

    override func sendStopReport() {
        updateProgress()
    }

    override func sendProgressReport() {
        updateProgress()
    }

    private func updateProgress() {
        Task {
            let progressInfo = PlaybackProgressInfo(
                audioStreamIndex: audioTrackIndex,
                isPaused: false,
                itemID: currentViewModel.item.id,
                mediaSourceID: currentViewModel.item.id,
                playSessionID: currentViewModel.playSessionID,
                positionTicks: currentProgressHandler.seconds * 10_000_000,
                sessionID: currentViewModel.playSessionID,
                subtitleStreamIndex: subtitleTrackIndex
            )
            self.task?.savePlaybackInfo(progress: progressInfo)
        }
    }
}
