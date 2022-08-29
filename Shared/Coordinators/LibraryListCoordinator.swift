//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Foundation
import Stinsen
import SwiftUI

final class LibraryListCoordinator: NavigationCoordinatable {

    let stack = NavigationStack(initial: \LibraryListCoordinator.start)

    @Root
    var start = makeStart
    @Route(.push)
    var library = makeLibrary
    #if os(iOS)
        @Route(.push)
        var liveTV = makeLiveTV
    #endif

    func makeLibrary(params: LibraryCoordinatorParams) -> LibraryCoordinator {
        LibraryCoordinator(viewModel: params.viewModel, title: params.title)
    }

    #if os(iOS)
        func makeLiveTV() -> LiveTVCoordinator {
            LiveTVCoordinator()
        }
    #endif

    @ViewBuilder
    func makeStart() -> some View {
        LibraryListView(viewModel: .init())
    }
}
