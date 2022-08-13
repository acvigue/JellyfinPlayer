//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Combine
import JellyfinAPI
import Stinsen
import SwiftUI

struct LibrarySearchView: View {
    @EnvironmentObject
    private var searchRouter: SearchCoordinator.Router
    @StateObject
    var viewModel: LibrarySearchViewModel
    @State
    private var searchQuery = ""

    @State
    private var tracks: [GridItem] = Array(repeating: .init(.flexible()), count: Int(UIScreen.main.bounds.size.width) / 125)

    func recalcTracks() {
        tracks = Array(repeating: .init(.flexible()), count: Int(UIScreen.main.bounds.size.width) / 125)
    }

    var body: some View {
        ZStack {
            VStack {
                SearchBar(text: $searchQuery)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                if searchQuery.isEmpty {
                    suggestionsListView
                } else {
                    resultView
                }
            }
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .onChange(of: searchQuery) { query in
            viewModel.searchQuerySubject.send(query)
        }
        .navigationBarTitle(L10n.search, displayMode: .inline)
    }

    var suggestionsListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                L10n.suggestions.text
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.bottom, 8)
                ForEach(viewModel.suggestions, id: \.id) { item in
                    Button {
                        searchQuery = item.name ?? ""
                    } label: {
                        Text(item.name ?? "")
                            .font(.body)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    var resultView: some View {
        let items = items(for: viewModel.selectedItemType)
        return VStack(alignment: .leading, spacing: 16) {
            Picker("ItemType", selection: $viewModel.selectedItemType) {
                ForEach(viewModel.supportedItemTypeList, id: \.self) {
                    Text($0.localized)
                        .tag($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    if !items.isEmpty {
                        LazyVGrid(columns: tracks) {
                            ForEach(items, id: \.id) { item in
                                PortraitPosterButton(item: item)
                                    .selectedAction { item in
                                        searchRouter.route(to: \.item, item)
                                    }
                            }
                        }
                    }
                }
            }
        }
        .onRotate { _ in
            recalcTracks()
        }
    }

    func items(for type: ItemType) -> [BaseItemDto] {
        switch type {
        case .episode:
            return viewModel.episodeItems
        case .movie:
            return viewModel.movieItems
        case .series:
            return viewModel.showItems
        default:
            return []
        }
    }
}
