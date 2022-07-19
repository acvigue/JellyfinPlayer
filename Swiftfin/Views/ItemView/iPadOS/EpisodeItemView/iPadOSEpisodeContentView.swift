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
        var itemRouter: ItemCoordinator.Router
        @ObservedObject
        var viewModel: EpisodeItemViewModel

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {

                VStack(alignment: .center) {
                    ImageView(
                        viewModel.item.getPrimaryImage(maxWidth: 600),
                        blurHash: viewModel.item.getPrimaryImageBlurHash()
                    )
                    .cornerRadius(10)
                    .frame(maxHeight: 400)
                    .aspectRatio(1.77, contentMode: .fit)
                    .padding(.horizontal)

                    ShelfView(viewModel: viewModel)
                }

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

                if let castAndCrew = viewModel.item.people?.filter { BaseItemPerson.DisplayedType.allCasesRaw.contains($0.type ?? "") },
                   !castAndCrew.isEmpty {
                       PortraitImageHStack(
                           title: L10n.castAndCrew,
                           items: castAndCrew,
                           itemWidth: UIDevice.isIPad ? 130 : 110
                       ) { person in
                           itemRouter.route(to: \.library, (viewModel: .init(person: person), title: person.title))
                       }

                       Divider()
                   }

                // MARK: Details

                if let informationItems = viewModel.item.createInformationItems(), !informationItems.isEmpty {
                    ListDetailsView(title: L10n.information, items: informationItems)
                        .padding(.horizontal)
                }

                if let mediaItems = viewModel.selectedVideoPlayerViewModel?.item.createMediaItems(), !mediaItems.isEmpty {
                    ListDetailsView(title: L10n.media, items: mediaItems)
                        .padding(.horizontal)
                }
            }
        }
    }
}

extension iPadOSEpisodeItemView.ContentView {

    struct ShelfView: View {

        @EnvironmentObject
        var itemRouter: ItemCoordinator.Router
        @ObservedObject
        var viewModel: EpisodeItemViewModel

        var body: some View {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {

                    Text(viewModel.item.seriesName ?? "--")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    Text(viewModel.item.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    DotHStack {
                        if let firstGenre = viewModel.item.genres?.first {
                            Text(firstGenre)
                        }

                        if let premiereYear = viewModel.item.premiereDateYear {
                            Text(String(premiereYear))
                        }

                        if let playButtonitem = viewModel.playButtonItem, let runtime = playButtonitem.getItemRuntime() {
                            Text(runtime)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(Color(UIColor.lightGray))

                    if let playButtonOverview = viewModel.playButtonItem?.overview {
                        TruncatedTextView(
                            playButtonOverview,
                            lineLimit: 3,
                            font: UIFont.preferredFont(forTextStyle: .footnote)
                        ) {
                            itemRouter.route(to: \.itemOverview, viewModel.item)
                        }
                    } else if let seriesOverview = viewModel.item.overview {
                        TruncatedTextView(
                            seriesOverview,
                            lineLimit: 3,
                            font: UIFont.preferredFont(forTextStyle: .footnote)
                        ) {
                            itemRouter.route(to: \.itemOverview, viewModel.item)
                        }
                    }

                    ItemView.AttributesHStack(viewModel: viewModel)
                }

                Spacer()

                VStack(spacing: 10) {
                    ItemView.PlayButton(viewModel: viewModel)
                        .frame(height: 50)

                    ItemView.ActionButtonHStack(viewModel: viewModel)
                        .font(.title)
                }
                .frame(width: 300)
                .padding(.leading, 150)
            }
            .padding()
        }
    }
}
