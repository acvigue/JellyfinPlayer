//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

extension iPadOSEpisodeItemView {

    struct ContentView: View {

        @EnvironmentObject
        private var itemRouter: ItemCoordinator.Router
        @ObservedObject
        var viewModel: EpisodeItemViewModel

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {

                // MARK: Genres

                if let genres = viewModel.item.genreItems, !genres.isEmpty {
                    PillHStack(
                        title: L10n.genres,
                        items: genres,
                        selectedAction: { genre in
                            itemRouter.route(to: \.library, (viewModel: .init(genre: genre), title: genre.title))
                        }
                    )

                    Divider()
                }

                if let studios = viewModel.item.studios, !studios.isEmpty {
                    PillHStack(
                        title: L10n.studios,
                        items: studios
                    ) { studio in
                        itemRouter.route(to: \.library, (viewModel: .init(studio: studio), title: studio.name ?? ""))
                    }

                    Divider()
                }

                if let castAndCrew = viewModel.item.people?.filter(\.isDisplayed),
                   !castAndCrew.isEmpty
                {
                    PortraitPosterHStack(title: L10n.castAndCrew, items: castAndCrew)
                        .selectedAction { person in
                            itemRouter.route(to: \.library, (viewModel: .init(person: person), title: person.title))
                        }

                    Divider()
                }

                ItemView.AboutView(viewModel: viewModel)
            }
        }
    }
}
