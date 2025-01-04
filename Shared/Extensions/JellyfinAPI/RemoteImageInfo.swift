//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2025 Jellyfin & Jellyfin Contributors
//

import Foundation
import JellyfinAPI
import SwiftUI

extension RemoteImageInfo: @retroactive Identifiable, Poster {

    var displayTitle: String {
        self.providerName ?? L10n.unknown
    }

    var unwrappedIDHashOrZero: Int {
        self.id
    }

    var subtitle: String? {
        self.language
    }

    var systemImage: String {
        "circle"
    }

    public var id: Int {
        self.hashValue
    }
}
