//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Foundation

extension Array {
    func appending(_ element: Element) -> [Element] {
        self + [element]
    }

    func appending(_ element: Element, if condition: Bool) -> [Element] {
        if condition {
            return self + [element]
        } else {
            return self
        }
    }

    func appending(_ contents: [Element]) -> [Element] {
        self + contents
    }

    // There are instances where `removeFirst()` is called on an empty
    // collection even with a count check and causes a crash
    @discardableResult
    mutating func removeFirstSafe() -> Element? {
        guard count > 0 else { return nil }
        return removeFirst()
    }
}

//extension ArraySlice {
//    var asArray: [Element] {
//        Array(self)
//    }
//}
