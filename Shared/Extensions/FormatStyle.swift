//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import SwiftUI

struct HourMinuteFormatStyle: FormatStyle {

    func format(_ value: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: value) ?? .emptyDash
    }
}

extension FormatStyle where Self == HourMinuteFormatStyle {

    static var hourMinute: HourMinuteFormatStyle { HourMinuteFormatStyle() }
}

/// Represent intervals as 24 hour, 60 minute, 60 second days
struct DayIntervalParseableFormatStyle: ParseableFormatStyle {

    let range: ClosedRange<Int>
    var parseStrategy: DayIntervalParseStrategy = .init()

    func format(_ value: TimeInterval) -> String {
        "\(clamp(Int(value / 86400), min: range.lowerBound, max: range.upperBound))"
    }
}

struct DayIntervalParseStrategy: ParseStrategy {

    func parse(_ value: String) throws -> TimeInterval {
        (TimeInterval(value) ?? 0) * 86400
    }
}

extension ParseableFormatStyle where Self == DayIntervalParseableFormatStyle {

    static func dayInterval(range: ClosedRange<Int>) -> DayIntervalParseableFormatStyle {
        .init(range: range)
    }
}
