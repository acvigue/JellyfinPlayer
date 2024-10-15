//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Foundation
import JellyfinAPI

extension DayOfWeek {

    var displayTitle: String? {
        let newLineRemoved = self.rawValue.replacingOccurrences(of: "\n", with: "")

        guard let index = DateFormatter().weekdaySymbols.firstIndex(of: newLineRemoved) else {
            return nil
        }

        let localCal = Calendar.current
        return localCal.weekdaySymbols[index].localizedCapitalized
    }
}
