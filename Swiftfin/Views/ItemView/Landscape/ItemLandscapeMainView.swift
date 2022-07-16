//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Stinsen
import SwiftUI

struct ItemLandscapeMainView: View {
    @EnvironmentObject
    var itemRouter: ItemCoordinator.Router
    @EnvironmentObject
    private var viewModel: ItemViewModel
    @State
    private var playButtonText: String = ""

    // MARK: innerBody

    private var innerBody: some View {
        HStack {
            // MARK: Sidebar Image

            VStack {
                ImageView(
                    viewModel.item.portraitHeaderViewURL(maxWidth: 130),
                    blurHash: viewModel.item.getPrimaryImageBlurHash()
                )
                .frame(width: 130, height: 195)
                .cornerRadius(10)
                .accessibilityIgnoresInvertColors()

                Spacer().frame(height: 15)

                // MARK: Play

                Button {
                    self.itemRouter.route(to: \.videoPlayer, viewModel.selectedVideoPlayerViewModel!)
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                            .foregroundColor(viewModel.playButtonItem == nil ? Color(UIColor.secondaryLabel) : Color.white)
                            .font(.system(size: 20))
                        Text(viewModel.playButtonText())
                            .foregroundColor(viewModel.playButtonItem == nil ? Color(UIColor.secondaryLabel) : Color.white)
                            .font(.callout)
                            .fontWeight(.semibold)
                    }
                    .frame(width: 130, height: 40)
                    .background(viewModel.playButtonItem == nil ? Color(UIColor.secondarySystemFill) : Color.jellyfinPurple)
                    .cornerRadius(10)
                }
                .disabled(viewModel.playButtonItem == nil || viewModel.selectedVideoPlayerViewModel == nil)
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
            }

            ScrollView {
                VStack(alignment: .leading) {
                    // MARK: ItemLandscapeTopBarView

                    ItemLandscapeTopBarView()
                        .environmentObject(viewModel)

                    // MARK: ItemViewBody

                    ItemViewBody()
                        .environmentObject(viewModel)
                }
            }
        }
        .onAppear {
            playButtonText = viewModel.playButtonText()
        }
    }

    // MARK: body

    var body: some View {
        VStack {
            ZStack {
                // MARK: Backdrop

                ImageView(
                    viewModel.item.getBackdropImage(maxWidth: 200),
                    blurHash: viewModel.item.getBackdropImageBlurHash()
                )
                .opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .blur(radius: 8)
                .layoutPriority(-1)
                .accessibilityIgnoresInvertColors()

                // iPadOS is making the view go all the way to the edge.
                // We have to accomodate this here
                if UIDevice.current.userInterfaceIdiom == .pad {
                    innerBody.padding(.horizontal, 25)
                } else {
                    innerBody
                }
            }
        }
    }
}
