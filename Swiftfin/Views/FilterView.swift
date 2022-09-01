//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

struct FilterView: View {

    @EnvironmentObject
    private var router: FilterCoordinator.Router

    @ObservedObject
    private var viewModel: FilterViewModel

    private let title: String
    private let filter: WritableKeyPath<ItemFilters, [ItemFilters.Filter]>
    private let selectedFiltersBinding: Binding<[ItemFilters.Filter]>
    private let singleSelect: Bool

    init(
        title: String,
        viewModel: FilterViewModel,
        filter: WritableKeyPath<ItemFilters, [ItemFilters.Filter]>,
        singleSelect: Bool
    ) {
        self.title = title
        self.viewModel = viewModel
        self.filter = filter
        self.singleSelect = singleSelect

        self.selectedFiltersBinding = Binding(get: {
            viewModel.currentFilters[keyPath: filter]
        }, set: { newValue, _ in
            viewModel.currentFilters[keyPath: filter] = newValue
        })
    }

    var body: some View {

        VStack {
            SelectorView(
                allItems: viewModel.allFilters[keyPath: filter],
                selectedItems: selectedFiltersBinding,
                singleSelect: singleSelect
            )
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button {
                    router.dismissCoordinator()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
            }
        }
    }
}
