//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Foundation
import JellyfinAPI
import Stinsen
import SwiftUI

typealias LibraryCoordinatorParams = (viewModel: LibraryViewModel, title: String)

final class LibraryCoordinator: NavigationCoordinatable {

    let stack = NavigationStack(initial: \LibraryCoordinator.start)

    @Root
    var start = makeStart

    #if os(tvOS)
        @Route(.modal)
        var item = makeModalItem
    #else
        @Route(.push)
        var item = makeItem
    @Route(.modal)
    var filter = makeFilter
    #endif

    let viewModel: LibraryViewModel
    let title: String

    init(viewModel: LibraryViewModel, title: String) {
        self.viewModel = viewModel
        self.title = title
    }

    @ViewBuilder
    func makeStart() -> some View {
        LibraryView(viewModel: viewModel)
    }

//    func makeFilter(params: FilterCoordinatorParams) -> NavigationViewCoordinator<FilterCoordinator> {
//        NavigationViewCoordinator(FilterCoordinator(
//            filters: params.filters,
//            enabledFilterType: params.enabledFilterType,
//            parentId: params.parentId
//        ))
//    }

    func makeItem(item: BaseItemDto) -> ItemCoordinator {
        ItemCoordinator(item: item)
    }
    
    func makeFilter() -> NavigationViewCoordinator<FilterCoordinator> {
        NavigationViewCoordinator(FilterCoordinator())
    }

    func makeModalItem(item: BaseItemDto) -> NavigationViewCoordinator<ItemCoordinator> {
        NavigationViewCoordinator(ItemCoordinator(item: item))
    }
}
