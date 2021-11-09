//
 /* 
  * SwiftFin is subject to the terms of the Mozilla Public
  * License, v2.0. If a copy of the MPL was not distributed with this
  * file, you can obtain one at https://mozilla.org/MPL/2.0/.
  *
  * Copyright 2021 Aiden Vigue & Jellyfin Contributors
  */

import SwiftUI

struct ItemLandscapeTopBarView: View {

    @EnvironmentObject private var viewModel: ItemViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading) {

                // MARK: Name

                Text(viewModel.getItemDisplayName())
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.leading, 16)
                    .padding(.bottom, 10)

                if viewModel.item.itemType.showDetails {
                    // MARK: Runtime
                    Text(viewModel.item.getItemRuntime())
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.leading, 16)
                }

                // MARK: Details
                HStack {
                    if viewModel.item.productionYear != nil {
                        Text(String(viewModel.item.productionYear ?? 0))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }

                    if viewModel.item.officialRating != nil {
                        Text(viewModel.item.officialRating!)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(EdgeInsets(top: 1, leading: 4, bottom: 1, trailing: 4))
                            .overlay(RoundedRectangle(cornerRadius: 2)
                                .stroke(Color.secondary, lineWidth: 1))
                    }

                    Spacer()

                    if viewModel.item.itemType.showDetails {
                        // MARK: Favorite
                        Button {
                            viewModel.updateFavoriteState()
                        } label: {
                            if viewModel.isFavorited {
                                Image(systemName: "heart.fill").foregroundColor(Color(UIColor.systemRed))
                                    .font(.system(size: 20))
                            } else {
                                Image(systemName: "heart").foregroundColor(Color.primary)
                                    .font(.system(size: 20))
                            }
                        }
                        .disabled(viewModel.isLoading)

                        // MARK: Watched
                        Button {
                            viewModel.updateWatchState()
                        } label: {
                            if viewModel.isWatched {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(Color.primary)
                                    .font(.system(size: 20))
                            } else {
                                Image(systemName: "checkmark.circle").foregroundColor(Color.primary)
                                    .font(.system(size: 20))
                            }
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
                .padding(.leading, 16)
            }
        }
    }
}
