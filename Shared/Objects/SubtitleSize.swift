//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import Defaults

enum SubtitleSize: Int32, CaseIterable, Defaults.Serializable {
    case smallest
    case smaller
    case regular
    case larger
    case largest
}

// MARK: - appearance

extension SubtitleSize {
    var label: String {
        switch self {
        case .smallest:
            return L10n.smallest
        case .smaller:
            return L10n.smaller
        case .regular:
            return L10n.regular
        case .larger:
            return L10n.larger
        case .largest:
            return L10n.largest
        }
    }
}

// MARK: - sizing for VLC

extension SubtitleSize {
    /// Value to be passed to VLCKit (via hacky internal property, until VLCKit 4)
    ///
    /// note that it doesn't correspond to actual font sizes; a smaller int creates bigger text
    var textRendererFontSize: Int {
        switch self {
        case .smallest:
            return 24
        case .smaller:
            return 20
        case .regular:
            return 16
        case .larger:
            return 12
        case .largest:
            return 8
        }
    }
}
