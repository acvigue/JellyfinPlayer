//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Foundation
import JellyfinAPI
import UIKit

protocol PlayerOverlayDelegate {

    func didSelectClose()
    func didSelectMenu()
    func didDeselectMenu()

    func didSelectBackward()
    func didSelectForward()
    func didSelectMain()

    func didGenerallyTap(point: CGPoint?)
    func didLongPress()

    func didBeginScrubbing()
    func didEndScrubbing()

    func didSelectAudioStream(index: Int)
    func didSelectSubtitleStream(index: Int)

    func didSelectPlayPreviousItem()
    func didSelectPlayNextItem()

    func didSelectChapters()
    func didSelectChapter(_ chapter: ChapterInfo)

    func didSelectScreenFill()
    func getScreenFilled() -> Bool
    // Returns whether the aspect ratio of the video
    // is greater than the aspect ratio of the screen
    func isVideoAspectRatioGreater() -> Bool
}
