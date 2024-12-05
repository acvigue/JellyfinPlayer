//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Combine
import Foundation
import JellyfinAPI

class GenreEditorViewModel: ItemEditorViewModel<String> {

    // MARK: - Add Genre(s)

    override func addComponents(_ genres: [String]) async throws {
        var updatedItem = item
        if updatedItem.genres == nil {
            updatedItem.genres = []
        }
        updatedItem.genres?.append(contentsOf: genres)
        try await updateItem(updatedItem)
    }

    // MARK: - Remove Genre(s)

    override func removeComponents(_ genres: [String]) async throws {
        var updatedItem = item
        updatedItem.genres?.removeAll { genres.contains($0) }
        try await updateItem(updatedItem)
    }

    // MARK: - Reorder Tag(s)

    override func reorderComponents(_ genres: [String]) async throws {
        var updatedItem = item
        updatedItem.genres = genres
        try await updateItem(updatedItem)
    }

    // MARK: - Fetch All Possible Genres

    override func fetchElements() async throws -> [String] {
        let request = Paths.getGenres()
        let response = try await userSession.client.send(request)

        if let genres = response.value.items {
            return genres.compactMap(\.name).compactMap { $0 }
        } else {
            return []
        }
    }

    // MARK: - Get Genres Matches from Population

    override func searchElements(_ searchTerm: String) async throws -> [String] {
        guard !searchTerm.isEmpty else {
            return []
        }

        return self.elements.filter {
            $0.range(of: searchTerm, options: .caseInsensitive) != nil
        }
    }
}
