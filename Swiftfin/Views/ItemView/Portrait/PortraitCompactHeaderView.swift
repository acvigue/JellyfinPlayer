//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

struct PortraitCompactOverlayView: View {

	@EnvironmentObject
	var itemRouter: ItemCoordinator.Router
	@ObservedObject
	private var viewModel: ItemViewModel
    
    init(viewModel: ItemViewModel) {
        self.viewModel = viewModel
    }
    
    @ViewBuilder
    private var rightShelfView: some View {
        VStack(alignment: .leading) {
            Spacer()

            // MARK: Name

            Text(viewModel.getItemDisplayName())
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            // MARK: Details

            HStack {
                if viewModel.item.unaired {
                    if let premiereDateLabel = viewModel.item.airDateLabel {
                        Text(premiereDateLabel)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                } else {
                    if let productionYear = viewModel.item.productionYear {
                        Text(String(productionYear))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                if let playButtonitem = viewModel.playButtonItem, let runtime = playButtonitem.getItemRuntime() {
                    Circle()
                        .foregroundColor(.secondary)
                        .frame(width: 2, height: 2)
                        .padding(.horizontal, 1)
                    
                    Text(runtime)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                if let officialRating = viewModel.item.officialRating {
                    Text(officialRating)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .padding(EdgeInsets(top: 1, leading: 4, bottom: 1, trailing: 4))
                        .overlay(RoundedRectangle(cornerRadius: 2)
                            .stroke(Color(UIColor.lightGray), lineWidth: 1))
                }

                if let selectedPlayerViewModel = viewModel.selectedVideoPlayerViewModel {
                    if !selectedPlayerViewModel.subtitleStreams.isEmpty {
                        Text("CC")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(EdgeInsets(top: 1, leading: 4, bottom: 1, trailing: 4))
                            .overlay(RoundedRectangle(cornerRadius: 2)
                                .stroke(Color(UIColor.lightGray), lineWidth: 1))
                    }
                }
            }
            
            if viewModel.videoPlayerViewModels.count > 1 {
                Menu {
                    ForEach(viewModel.videoPlayerViewModels, id: \.self) { viewModelOption in
                        Button {
                            viewModel.selectedVideoPlayerViewModel = viewModelOption
                        } label: {
                            if viewModelOption.versionName == viewModel.selectedVideoPlayerViewModel?.versionName {
                                Label(viewModelOption.versionName ?? L10n.noTitle, systemImage: "checkmark")
                            } else {
                                Text(viewModelOption.versionName ?? L10n.noTitle)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text(viewModel.selectedVideoPlayerViewModel?.versionName ?? L10n.noTitle)
                            .fontWeight(.semibold)
                            .fixedSize()
                        Image(systemName: "chevron.down")
                    }
                }
            }
        }
    }

	var body: some View {
        VStack(alignment: .leading, spacing: 10) {
			HStack(alignment: .bottom, spacing: 12) {

				// MARK: Portrait Image

				ImageView(viewModel.item.portraitHeaderViewURL(maxWidth: 130),
				          blurHash: viewModel.item.getPrimaryImageBlurHash())
					.portraitPoster(width: 130)
					.accessibilityIgnoresInvertColors()

				rightShelfView
                    .padding(.bottom)
			}

            // MARK: Play
            
            HStack(alignment: .center) {
                
                Button {
                    if let selectedVideoPlayerViewModel = viewModel.selectedVideoPlayerViewModel {
                        itemRouter.route(to: \.videoPlayer, selectedVideoPlayerViewModel)
                    } else {
                        LogManager.log.error("Attempted to play item but no playback information available")
                    }
                } label: {
                    ZStack {
                        Rectangle()
                            .foregroundColor(viewModel.playButtonItem == nil ? Color(UIColor.secondarySystemFill) : Color.jellyfinPurple)
                            .frame(width: 130, height: 40)
                            .cornerRadius(10)

                        HStack {
                            Image(systemName: "play.fill")
                                .font(.system(size: 20))
                            Text(viewModel.playButtonText())
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(viewModel.playButtonItem == nil ? Color(UIColor.secondaryLabel) : Color.white)
                    }
                }
                .contextMenu {
                    if viewModel.playButtonItem != nil, viewModel.item.userData?.playbackPositionTicks ?? 0 > 0 {
                        Button {
                            if let selectedVideoPlayerViewModel = viewModel.selectedVideoPlayerViewModel {
                                selectedVideoPlayerViewModel.injectCustomValues(startFromBeginning: true)
                                itemRouter.route(to: \.videoPlayer, selectedVideoPlayerViewModel)
                            } else {
                                LogManager.log.error("Attempted to play item but no playback information available")
                            }
                        } label: {
                            Label(L10n.playFromBeginning, systemImage: "gobackward")
                        }
                    }
                }
                
                Spacer()

                // MARK: Watched
                Button {
                    viewModel.toggleWatchState()
                } label: {
                    if viewModel.isWatched {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.jellyfinPurple)
                            .font(.system(size: 20))
                    } else {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(Color.primary)
                            .font(.system(size: 20))
                    }
                }
                .disabled(viewModel.isLoading)
                
                Button {
                    viewModel.toggleFavoriteState()
                } label: {
                    if viewModel.isFavorited {
                        Image(systemName: "heart.fill")
                            .foregroundColor(Color(UIColor.systemRed))
                            .font(.system(size: 20))
                    } else {
                        Image(systemName: "heart")
                            .foregroundColor(Color.primary)
                            .font(.system(size: 20))
                    }
                }
                .disabled(viewModel.isLoading)
            }
		}
		.padding(.horizontal)
        .background {
            Color.systemBackground
                .mask {
                    LinearGradient(gradient: Gradient(stops: [
                        .init(color: .white, location: 0),
                        .init(color: .white, location: 0.2),
                        .init(color: .white.opacity(0), location: 1),
                    ]), startPoint: .bottom, endPoint: .top)
                }
        }
	}
}