//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Foundation
import MediaPlayer

enum NowPlayableCommand {

    // Play/Pause
    case pause
    case play
    case stop
    case togglePausePlay

    // Track
    case nextTrack
    case previousTrack
    case changeRepeatMode
    case changeShuffleMode

    // Seeking/Rate
    case changePlaybackRate
    case seekBackward
    case seekForward
    case skipBackward(NSNumber)
    case skipForward(NSNumber)
    case changePlaybackPosition

    // Like/Dislike
    case rating
    case like
    case dislike

    // Bookmark
    case bookmark

    // Languages
    case enableLanguageOption
    case disableLanguageOption

    // The underlying `MPRemoteCommandCenter` command for this `NowPlayable` command.

    var remoteCommand: MPRemoteCommand {

        let remoteCommandCenter = MPRemoteCommandCenter.shared()
        switch self {
        case .pause:
            return remoteCommandCenter.pauseCommand
        case .play:
            return remoteCommandCenter.playCommand
        case .stop:
            return remoteCommandCenter.stopCommand
        case .togglePausePlay:
            return remoteCommandCenter.togglePlayPauseCommand
        case .nextTrack:
            return remoteCommandCenter.nextTrackCommand
        case .previousTrack:
            return remoteCommandCenter.previousTrackCommand
        case .changeRepeatMode:
            return remoteCommandCenter.changeRepeatModeCommand
        case .changeShuffleMode:
            return remoteCommandCenter.changeShuffleModeCommand
        case .changePlaybackRate:
            return remoteCommandCenter.changePlaybackRateCommand
        case .seekBackward:
            return remoteCommandCenter.seekBackwardCommand
        case .seekForward:
            return remoteCommandCenter.seekForwardCommand
        case .skipBackward:
            return remoteCommandCenter.skipBackwardCommand
        case .skipForward:
            return remoteCommandCenter.skipForwardCommand
        case .changePlaybackPosition:
            return remoteCommandCenter.changePlaybackPositionCommand
        case .rating:
            return remoteCommandCenter.ratingCommand
        case .like:
            return remoteCommandCenter.likeCommand
        case .dislike:
            return remoteCommandCenter.dislikeCommand
        case .bookmark:
            return remoteCommandCenter.bookmarkCommand
        case .enableLanguageOption:
            return remoteCommandCenter.enableLanguageOptionCommand
        case .disableLanguageOption:
            return remoteCommandCenter.disableLanguageOptionCommand
        }
    }

    // Remove all handlers associated with this command.

    func removeHandler() {
        remoteCommand.removeTarget(nil)
    }

    // Install a handler for this command.

    func addHandler(_ handler: @escaping (NowPlayableCommand, MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus) {
        switch self {
        case let .skipBackward(interval):
            MPRemoteCommandCenter.shared().skipBackwardCommand.preferredIntervals = [interval]
        case let .skipForward(interval):
            MPRemoteCommandCenter.shared().skipForwardCommand.preferredIntervals = [interval]
        default:
            remoteCommand.addTarget { handler(self, $0) }
        }
    }

    // Disable this command.

    func setDisabled(_ isDisabled: Bool) {
        remoteCommand.isEnabled = !isDisabled
    }
}
