//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Defaults
import SwiftUI

// TODO: Look at name spacing
// TODO: Consistent naming: ...Key

extension EnvironmentValues {

    struct AccentColorKey: EnvironmentKey {
        static let defaultValue: Color = Defaults[.accentColor]
    }

    struct AudioOffsetKey: EnvironmentKey {
        static let defaultValue: Binding<Int> = .constant(0)
    }

    struct AspectFilledKey: EnvironmentKey {
        static let defaultValue: Binding<Bool> = .constant(false)
    }

    struct CurrentOverlayTypeKey: EnvironmentKey {
        static let defaultValue: Binding<VideoPlayer.OverlayType> = .constant(.main)
    }

    struct IsScrubbingKey: EnvironmentKey {
        static let defaultValue: Binding<Bool> = .constant(false)
    }

    struct PlaybackSpeedKey: EnvironmentKey {
        static let defaultValue: Binding<Float> = .constant(1)
    }

    // TODO: remove, this doesn't actually give us anything useful
    struct SafeAreaInsetsKey: EnvironmentKey {
        static var defaultValue: EdgeInsets {
            UIApplication.shared.keyWindow?.safeAreaInsets.asEdgeInsets ?? .zero
        }
    }

    struct ShowsLibraryFiltersKey: EnvironmentKey {
        static let defaultValue: Bool = true
    }

    struct SubtitleOffsetKey: EnvironmentKey {
        static let defaultValue: Binding<Int> = .constant(0)
    }

    struct IsPresentingOverlayKey: EnvironmentKey {
        static let defaultValue: Binding<Bool> = .constant(false)
    }
}
