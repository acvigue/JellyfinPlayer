//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI
import SwiftUICollection

struct MovieLibrariesView: View {
    
    @EnvironmentObject
    private var movieLibrariesRouter: MovieLibrariesCoordinator.Router
    @StateObject
    var viewModel: MovieLibrariesViewModel
    var title: String

    var body: some View {
        if viewModel.isLoading == true {
            ProgressView()
        } else if !viewModel.rows.isEmpty {
            CollectionView(rows: viewModel.rows) { _, _ in
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(300)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                let header =
                    NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(44)
                        ),
                        elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .topLeading
                    )

                let section = NSCollectionLayoutSection(group: group)

                section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 0, bottom: 80, trailing: 80)
                section.interGroupSpacing = 48
                section.orthogonalScrollingBehavior = .continuous
                section.boundarySupplementaryItems = [header]
                return section
            } cell: { _, cell in
                GeometryReader { _ in
                    if let item = cell.item {
                        if item.type != .folder {
                            Button {
                                self.movieLibrariesRouter.route(to: \.library, item)
                            } label: {
                                PortraitItemElement(item: item)
                            }
                            .buttonStyle(PlainNavigationLinkButtonStyle())
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
                L10n.noResults.text
                Button {
                    print("movieLibraries reload")
                } label: {
                    L10n.refresh.text
                }
            }
        }
    }
}
