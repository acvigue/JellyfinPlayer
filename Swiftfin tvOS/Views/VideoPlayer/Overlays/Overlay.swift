//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import SwiftUI
import VLCUI

extension VideoPlayer {
    
    struct Overlay: View {
        
        @Environment(\.isPresentingOverlay)
        @Binding
        private var isPresentingOverlay
        
        @EnvironmentObject
        private var proxy: VLCVideoPlayer.Proxy
        @EnvironmentObject
        private var router: VideoPlayerCoordinator.Router
        
        @State
        private var confirmCloseWorkItem: DispatchWorkItem?
        @State
        private var currentOverlayType: VideoPlayer.OverlayType = .main
        
        @StateObject
        private var overlayTimer: TimerProxy = .init()
        
        var body: some View {
            ZStack {
                
                MainOverlay()
                    .visible(currentOverlayType == .main)
                
                ConfirmCloseOverlay()
                    .visible(currentOverlayType == .confirmClose)
            }
            .visible(isPresentingOverlay)
            .animation(.linear(duration: 0.1), value: currentOverlayType)
            .environment(\.currentOverlayType, $currentOverlayType)
            .environmentObject(overlayTimer)
            .onChange(of: overlayTimer.isActive) { isActive in
                guard !isActive else { return }

                withAnimation(.linear(duration: 0.3)) {
                    isPresentingOverlay = false
                }
            }
            .onSelectPressed {
                currentOverlayType = .main
                isPresentingOverlay = true
                overlayTimer.start(5)
            }
            .onMenuPressed {
                
                overlayTimer.start(5)
                confirmCloseWorkItem?.cancel()

                if isPresentingOverlay && currentOverlayType == .confirmClose {
                    proxy.stop()
                    router.dismissCoordinator()
                } else {
                    withAnimation {
                        currentOverlayType = .confirmClose
                        isPresentingOverlay = true
                    }

                    let task = DispatchWorkItem {
                        withAnimation {
                            isPresentingOverlay = false
                            overlayTimer.stop()
                        }
                    }

                    confirmCloseWorkItem = task

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: task)
                }
            }
        }
    }
}
