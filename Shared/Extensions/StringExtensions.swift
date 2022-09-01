//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Foundation
import SwiftUI

extension String {
    func removeRegexMatches(pattern: String, replaceWith: String = "") -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: count)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch { return self }
    }

    func leftPad(toWidth width: Int, withString string: String?) -> String {
        let paddingString = string ?? " "

        if self.count >= width {
            return self
        }

        let remainingLength: Int = width - self.count
        var padString = String()
        for _ in 0 ..< remainingLength {
            padString += paddingString
        }

        return "\(padString)\(self)"
    }

    var text: Text {
        Text(self)
    }

    var initials: String {
        let initials = self.split(separator: " ").compactMap(\.first)
        return String(initials)
    }

    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let textSize = self.size(withAttributes: fontAttributes)
        return textSize.height
    }

    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let textSize = self.size(withAttributes: fontAttributes)
        return textSize.width
    }

    var filter: ItemFilters.Filter {
        .init(displayName: self, id: self, filterName: self)
    }
}
