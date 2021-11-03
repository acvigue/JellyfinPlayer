//
// SwiftFin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2021 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI
import SwiftUICollection

struct LibraryView: View {
	@EnvironmentObject
	var libraryRouter: LibraryCoordinator.Router
	@StateObject
	var viewModel: LibraryViewModel
	var title: String

	// MARK: tracks for grid

	var defaultFilters = LibraryFilters(filters: [], sortOrder: [.ascending], withGenres: [], tags: [], sortBy: [.name])

	@State
	var isShowingSearchView = false
	@State
	var isShowingFilterView = false

	var body: some View {
		if viewModel.isLoading == true {
			ProgressView()
		} else if !viewModel.rows.isEmpty {
			CollectionView(rows: viewModel.rows) { _, _ in
				let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
				                                      heightDimension: .fractionalHeight(1))
				let item = NSCollectionLayoutItem(layoutSize: itemSize)

				let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(200),
				                                       heightDimension: .absolute(300))
				let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
				                                               subitems: [item])

				let header =
					NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
					                                                                               heightDimension: .absolute(44)),
					                                            elementKind: UICollectionView.elementKindSectionHeader,
					                                            alignment: .topLeading)

				let section = NSCollectionLayoutSection(group: group)

				section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 0, bottom: 80, trailing: 80)
				section.interGroupSpacing = 48
				section.orthogonalScrollingBehavior = .continuous
				section.boundarySupplementaryItems = [header]
				return section
			} cell: { _, cell in
				GeometryReader { _ in
					if let item = cell.item {
						if item.type != "Folder" {
							Button {
								libraryRouter.route(to: \.modalItem, item)
							} label: {
								PortraitItemElement(item: item)
							}
							.buttonStyle(PlainNavigationLinkButtonStyle())
							.onAppear {
								if item == viewModel.items.last && viewModel.hasNextPage {
									viewModel.requestNextPageAsync()
								}
							}
						}
					} else if cell.loadingCell {
						ProgressView()
							.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
					}
				}
			} supplementaryView: { _, indexPath in
				HStack {
					Spacer()
				}.accessibilityIdentifier("\(indexPath.section).\(indexPath.row)")
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.ignoresSafeArea(.all)
		} else {
			VStack {
				Text("No results.")
				Button {} label: {
					Text("Reload")
				}
			}
		}
	}
}

// stream BM^S by nicki!
//
