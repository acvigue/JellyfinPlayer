//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Defaults
import Factory
import Files
import Foundation
import JellyfinAPI
import UIKit
import VLCUI

class VideoPlayerViewModel: ViewModel {

    let playbackURL: URL
    let item: BaseItemDto
    let mediaSource: MediaSourceInfo
    let playSessionID: String
    let videoStreams: [MediaStream]
    let audioStreams: [MediaStream]
    let subtitleStreams: [MediaStream]
    let selectedAudioStreamIndex: Int
    let selectedSubtitleStreamIndex: Int
    let chapters: [ChapterInfo.FullInfo]
    let streamType: StreamType

    var hlsPlaybackURL: URL {

        let userSession = Container.userSession()

        let parameters = Paths.GetMasterHlsVideoPlaylistParameters(
            isStatic: true,
            tag: mediaSource.eTag,
            playSessionID: playSessionID,
            segmentContainer: "mp4",
            minSegments: 2,
            mediaSourceID: mediaSource.id!,
            deviceID: UIDevice.vendorUUIDString,
            audioCodec: mediaSource.audioStreams?
                .compactMap(\.codec)
                .joined(separator: ","),
            isBreakOnNonKeyFrames: true,
            requireAvc: false,
            transcodingMaxAudioChannels: 8,
            videoCodec: videoStreams
                .compactMap(\.codec)
                .joined(separator: ","),
            videoStreamIndex: videoStreams.first?.index,
            enableAdaptiveBitrateStreaming: true
        )
        let request = Paths.getMasterHlsVideoPlaylist(
            itemID: item.id!,
            parameters: parameters
        )

        // TODO: don't force unwrap
        let hlsStreamComponents = URLComponents(url: userSession.client.fullURL(with: request)!, resolvingAgainstBaseURL: false)!
            .addingQueryItem(key: "api_key", value: userSession.user.accessToken)

        return hlsStreamComponents.url!
    }

    var vlcVideoPlayerConfiguration: VLCVideoPlayer.Configuration {
        let configuration = VLCVideoPlayer.Configuration(url: playbackURL)
        configuration.autoPlay = true
        configuration.startTime = .seconds(max(0, item.startTimeSeconds - Defaults[.VideoPlayer.resumeOffset]))
        configuration.audioIndex = .absolute(selectedAudioStreamIndex)
        configuration.subtitleIndex = .absolute(selectedSubtitleStreamIndex)
        configuration.subtitleSize = .absolute(Defaults[.VideoPlayer.Subtitle.subtitleSize])
        configuration.subtitleColor = .absolute(Defaults[.VideoPlayer.Subtitle.subtitleColor].uiColor)

        if let font = UIFont(name: Defaults[.VideoPlayer.Subtitle.subtitleFontName], size: 0) {
            configuration.subtitleFont = .absolute(font)
        }

        configuration.playbackChildren = subtitleStreams
            .filter { $0.deliveryMethod == .external }
            .compactMap(\.asPlaybackChild)

        return configuration
    }

    init(
        playbackURL: URL,
        item: BaseItemDto,
        mediaSource: MediaSourceInfo,
        playSessionID: String,
        videoStreams: [MediaStream],
        audioStreams: [MediaStream],
        subtitleStreams: [MediaStream],
        selectedAudioStreamIndex: Int,
        selectedSubtitleStreamIndex: Int,
        chapters: [ChapterInfo.FullInfo],
        streamType: StreamType
    ) {
        self.item = item
        self.mediaSource = mediaSource
        self.playSessionID = playSessionID
        self.playbackURL = playbackURL
        self.videoStreams = videoStreams
        self.audioStreams = audioStreams
            .adjustAudioForExternalSubtitles(externalMediaStreamCount: subtitleStreams.filter { $0.isExternal ?? false }.count)
        self.subtitleStreams = subtitleStreams
            .adjustExternalSubtitleIndexes(audioStreamCount: audioStreams.count)
        self.selectedAudioStreamIndex = selectedAudioStreamIndex
        self.selectedSubtitleStreamIndex = selectedSubtitleStreamIndex
        self.chapters = chapters
        self.streamType = streamType
        super.init()
    }

    func chapter(from seconds: Int) -> ChapterInfo.FullInfo? {
        chapters.first(where: { $0.secondsRange.contains(seconds) })
    }
}

extension VideoPlayerViewModel: Equatable {

    static func == (lhs: VideoPlayerViewModel, rhs: VideoPlayerViewModel) -> Bool {
        lhs.item == rhs.item &&
            lhs.playbackURL == rhs.playbackURL
    }
}
