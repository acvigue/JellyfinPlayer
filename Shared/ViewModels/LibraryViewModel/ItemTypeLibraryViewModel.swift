//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Combine
import Foundation
import Get
import JellyfinAPI

// TODO: atow, this is only really used for tvOS tabs
final class ItemTypeLibraryViewModel: PagingLibraryViewModel {

    let itemTypes: [BaseItemKind]
    let filterViewModel: FilterViewModel

    init(itemTypes: [BaseItemKind], filters: ItemFilterCollection) {
        self.itemTypes = itemTypes
        self.filterViewModel = .init(parent: nil, currentFilters: filters)
        super.init()

//        filterViewModel.$currentFilters
//            .sink { newFilters in
//                self.requestItems(with: newFilters, replaceCurrentItems: true)
//            }
//            .store(in: &cancellables)
    }

    private func requestItems(with filters: ItemFilterCollection, replaceCurrentItems: Bool = false) {

        if replaceCurrentItems {
            items = []
            currentPage = 0
            hasNextPage = true
        }

        Task {
            let parameters = self._getDefaultParams()
            let request = Paths.getItems(parameters: parameters)
            let response = try await userSession.client.send(request)

            guard let items = response.value.items, items.isNotEmpty else {
                hasNextPage = false
                return
            }

            await MainActor.run {
                self.items.append(contentsOf: items)
            }
        }
    }

    override func _getDefaultParams() -> Paths.GetItemsParameters? {
        let filters = filterViewModel.currentFilters
        let genreIDs = filters.genres.compactMap(\.id)
        let sortBy: [String] = filters.sortBy.map(\.filterName).appending("IsFolder")
        let sortOrder = filters.sortOrder.map { SortOrder(rawValue: $0.filterName) ?? .ascending }
        let ItemFilterCollection: [ItemFilter] = filters.filters.compactMap { .init(rawValue: $0.filterName) }

        let parameters = Paths.GetItemsParameters(
            userID: userSession.user.id,
            startIndex: currentPage * Self.DefaultPageSize,
            limit: Self.DefaultPageSize,
            isRecursive: true,
            sortOrder: sortOrder,
            fields: ItemFields.allCases,
            includeItemTypes: itemTypes,
            filters: ItemFilterCollection,
            sortBy: sortBy,
            enableUserData: true,
            genreIDs: genreIDs
        )

        return parameters
    }

    override func getCurrentPage() async throws {
        requestItems(with: filterViewModel.currentFilters)
    }
}
