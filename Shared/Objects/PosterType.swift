//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Defaults
import SwiftUI

// TODO: Refactor to `ItemDisplayType`
//       - this is to move away from video specific to generalizing all media types. However,
//         media is still able to use grammar for their own contexts.
//       - move landscape/portrait to wide/narrow
//       - add `square`/something similar
// TODO: after no longer experimental, nest under `Poster`?
//       tracker: https://github.com/apple/swift-evolution/blob/main/proposals/0404-nested-protocols.md

enum PosterType: String, CaseIterable, Displayable, Defaults.Serializable {

    case landscape
    case portrait

    // TODO: localize
    var displayTitle: String {
        switch self {
        case .landscape:
            "Landscape"
        case .portrait:
            "Portrait"
        }
    }
}
