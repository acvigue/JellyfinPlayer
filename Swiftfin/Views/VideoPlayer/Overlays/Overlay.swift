//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Defaults
import SwiftUI

extension VideoPlayer {

    struct Overlay: View {

        @Environment(\.isPresentingOverlay)
        @Binding
        private var isPresentingOverlay

        @State
        private var currentOverlayType: VideoPlayer.OverlayType = .main

        var body: some View {
            ZStack {

                MainOverlay()
                    .opacity(currentOverlayType == .main ? 1 : 0)

                ChapterOverlay()
                    .opacity(currentOverlayType == .chapters ? 1 : 0)
            }
            .environment(\.currentOverlayType, $currentOverlayType)
            .animation(.linear(duration: 0.1), value: currentOverlayType)
            .onChange(of: isPresentingOverlay) { newValue in
                guard newValue else { return }
                currentOverlayType = .main
            }
        }
    }
}
