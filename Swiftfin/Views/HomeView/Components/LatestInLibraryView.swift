//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

struct LatestInLibraryView: View {

    @EnvironmentObject
    private var homeRouter: HomeCoordinator.Router
    @ObservedObject
    var viewModel: LatestMediaViewModel

    var body: some View {
        LandscapePosterHStack(
            title: L10n.latestWithString(viewModel.library.displayName),
            items: viewModel.items
        )
        .trailing {
            Button {
                let libraryViewModel = LibraryViewModel(parentID: viewModel.library.id, filters: HomeViewModel.recentFilterSet)
                homeRouter.route(to: \.library, (viewModel: libraryViewModel, title: viewModel.library.displayName))
            } label: {
                HStack {
                    L10n.seeAll.text
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline.bold())
            }
        }
        .selectedAction { item in
            homeRouter.route(to: \.item, item)
        }
    }
}
