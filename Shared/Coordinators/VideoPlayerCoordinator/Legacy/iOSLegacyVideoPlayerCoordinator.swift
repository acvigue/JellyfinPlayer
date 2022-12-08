////
//// Swiftfin is subject to the terms of the Mozilla Public
//// License, v2.0. If a copy of the MPL was not distributed with this
//// file, you can obtain one at https://mozilla.org/MPL/2.0/.
////
//// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
////
//
//import Defaults
//import Foundation
//import JellyfinAPILegacy
//import Stinsen
//import SwiftUI
//
//final class LegacyVideoPlayerCoordinator: NavigationCoordinatable {
//
//    let stack = NavigationStack(initial: \LegacyVideoPlayerCoordinator.start)
//
//    @Root
//    var start = makeStart
//
//    let viewModel: LegacyVideoPlayerViewModel
//
//    init(viewModel: LegacyVideoPlayerViewModel) {
//        self.viewModel = viewModel
//    }
//
//    @ViewBuilder
//    func makeStart() -> some View {
//        PreferenceUIHostingControllerView {
//            if Defaults[.Experimental.nativePlayer] {
//                NativePlayerView(viewModel: self.viewModel)
//                    .navigationBarHidden(true)
//                    .statusBar(hidden: true)
//                    .ignoresSafeArea()
//                    .prefersHomeIndicatorAutoHidden(true)
//                    .supportedOrientations(UIDevice.current.userInterfaceIdiom == .pad ? .all : .landscape)
//            } else {
//                LegacyVLCPlayerView(viewModel: self.viewModel)
//                    .navigationBarHidden(true)
//                    .statusBar(hidden: true)
//                    .ignoresSafeArea()
//                    .prefersHomeIndicatorAutoHidden(true)
//                    .supportedOrientations(UIDevice.current.userInterfaceIdiom == .pad ? .all : .landscape)
//            }
//        }.ignoresSafeArea()
//    }
////}
