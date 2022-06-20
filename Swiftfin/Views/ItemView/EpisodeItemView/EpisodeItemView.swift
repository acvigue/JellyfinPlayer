//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

struct EpisodeItemView: View {

	@EnvironmentObject
	var itemRouter: ItemCoordinator.Router
	@EnvironmentObject
	private var viewModel: EpisodeItemViewModel

	// MARK: portraitShelfItem

	@ViewBuilder
	private var portraitShelfView: some View {
        VStack(alignment: .center) {
            Text(viewModel.item.seriesName ?? "--")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
                .foregroundColor(.secondary)

            Text(viewModel.getItemDisplayName())
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)

            HStack(spacing: 10) {
                if let episodeLocation = viewModel.item.getEpisodeLocator() {
                    Text(episodeLocation)
                    
                    Circle()
                        .frame(width: 2, height: 2)
                        .padding(.horizontal, 1)
                }

                if let productionYear = viewModel.item.premiereDateYear {
                    Text(productionYear)
                    
                    Circle()
                        .frame(width: 2, height: 2)
                        .padding(.horizontal, 1)
                }
                
                if let runtime = viewModel.item.getItemRuntime() {
                    Text(runtime)
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)

            ItemView.PlayButton(viewModel: viewModel)
                .frame(maxWidth: 300)
                .frame(height: 50)
            
            ItemView.ItemActionHStackView()
                .environmentObject(viewModel as ItemViewModel)
                .frame(maxWidth: 300)
        }
	}

	// MARK: landscapeShelfItem

	@ViewBuilder
	private var landscapeShelfView: some View {
		HStack {
			VStack(alignment: .leading) {
				Text(viewModel.item.seriesName ?? "--")
					.font(.headline)
					.fontWeight(.semibold)
					.padding(.horizontal)
					.foregroundColor(.secondary)

				Text(viewModel.getItemDisplayName())
					.font(.title2)
					.fontWeight(.bold)
					.multilineTextAlignment(.center)
					.fixedSize(horizontal: false, vertical: true)
					.padding(.horizontal)

				HStack(spacing: 10) {
					if let episodeLocation = viewModel.item.getSeasonEpisodeLocator() {
						Text(episodeLocation)
					}

					if let runtime = viewModel.item.getItemRuntime() {
						Text(runtime)
					}

					// TODO: Change to premiere date
					if let productionYear = viewModel.item.productionYear {
						Text(String(productionYear))
					}
				}
				.font(.subheadline)
				.foregroundColor(.secondary)
				.padding(.horizontal)
			}

			Spacer(minLength: 0)

            ItemView.PlayButton(viewModel: viewModel)
				.padding(.horizontal)
		}
	}

	var body: some View {
		GeometryReader { geometry in
			NavBarOffsetScrollView(headerHeight: 10) {
				VStack(alignment: .leading) {

                    VStack(alignment: .center) {
                        ImageView(viewModel.item.getPrimaryImage(maxWidth: 600),
                                  blurHash: viewModel.item.getPrimaryImageBlurHash())
                            .cornerRadius(10)
                            .aspectRatio(1.77, contentMode: .fit)
                            .frame(maxWidth: UIDevice.isIPad ? geometry.size.width / 2 : 600)
                            .padding(.horizontal)

                        if UIDevice.isLandscape {
                            landscapeShelfView
                        } else {
                            portraitShelfView
                        }
                    }

                    // MARK: Overview

                    if let itemOverview = viewModel.item.overview {
                        HStack {
                            TruncatedTextView(itemOverview,
                                              lineLimit: 5,
                                              font: UIFont.preferredFont(forTextStyle: .footnote)) {
                                itemRouter.route(to: \.itemOverview, viewModel.item)
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top)
                            .padding(.horizontal)

                            Spacer(minLength: 0)
                        }
                    }

                    // MARK: Genres

                    if let genres = viewModel.item.genreItems, !genres.isEmpty {
                        PillHStackView(title: L10n.genres,
                                       items: genres,
                                       selectedAction: { genre in
                                        itemRouter.route(to: \.library, (viewModel: .init(genre: genre), title: genre.title))
                                       })
                                       .padding(.bottom)
                    }

                    if let studios = viewModel.item.studios, !studios.isEmpty {
                        PillHStackView(title: L10n.studios,
                                       items: studios) { studio in
                            itemRouter.route(to: \.library, (viewModel: .init(studio: studio), title: studio.name ?? ""))
                        }
                        .padding(.bottom)
                    }

                    if let castAndCrew = viewModel.item.people, !castAndCrew.isEmpty {
                        PortraitImageHStackView(items: castAndCrew
                            .filter { BaseItemPerson.DisplayedType.allCasesRaw.contains($0.type ?? "") },
                            topBarView: {
                                L10n.castAndCrew.text
                                    .fontWeight(.semibold)
                                    .padding(.bottom)
                                    .padding(.horizontal)
                                    .accessibility(addTraits: [.isHeader])
                            },
                            selectedAction: { person in
                                itemRouter.route(to: \.library,
                                                 (viewModel: .init(person: person), title: person.title))
                            })
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
}