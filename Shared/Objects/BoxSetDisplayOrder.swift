//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Foundation

enum BoxSetDisplayOrder: String, CaseIterable, Identifiable {
    case dateModified = "DateModified"
    case sortName = "SortName"
    case premiereDate = "PremiereDate"

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .dateModified:
            return "Date Modified"
        case .sortName:
            return "Sort Name"
        case .premiereDate:
            return "Premiere Date"
        }
    }
}
