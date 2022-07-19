//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import SwiftUI

extension ItemView {

    struct CompactPosterScrollView<Content: View>: View {

        @EnvironmentObject
        var itemRouter: ItemCoordinator.Router
        @ObservedObject
        var viewModel: ItemViewModel

        let content: () -> Content

        @ViewBuilder
        private var headerView: some View {
            VStack {
                ImageView(
                    viewModel.item.getBackdropImage(maxWidth: Int(UIScreen.main.bounds.width)),
                    blurHash: viewModel.item.getBackdropImageBlurHash()
                )

                Spacer()
                    .frame(height: 50)
            }
        }

        @ViewBuilder
        private var staticOverlayView: some View {
            StaticOverlayView(viewModel: viewModel)
        }

        var body: some View {
            ParallaxHeaderScrollView(
                header: headerView,
                staticOverlayView: staticOverlayView,
                headerHeight: UIScreen.main.bounds.height * 0.35
            ) {
                content()
                    .padding(.top)
            }
        }
    }
}

extension ItemView.CompactPosterScrollView {

    struct StaticOverlayView: View {

        @EnvironmentObject
        var itemRouter: ItemCoordinator.Router
        @ObservedObject
        var viewModel: ItemViewModel

        @ViewBuilder
        private var rightShelfView: some View {
            VStack(alignment: .leading) {
                Spacer()

                // MARK: Name

                Text(viewModel.item.displayName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                // MARK: Details

                DotHStack {
                    if viewModel.item.unaired {
                        if let premiereDateLabel = viewModel.item.airDateLabel {
                            Text(premiereDateLabel)
                        }
                    } else {
                        if let productionYear = viewModel.item.productionYear {
                            Text(String(productionYear))
                        }
                    }

                    if let playButtonitem = viewModel.playButtonItem, let runtime = playButtonitem.getItemRuntime() {
                        Text(runtime)
                    }
                }
                .lineLimit(1)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)

                ItemView.AttributesHStack(viewModel: viewModel)
            }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .bottom, spacing: 12) {

                    // MARK: Portrait Image

                    ImageView(
                        viewModel.item.portraitHeaderViewURL(maxWidth: 130),
                        blurHash: viewModel.item.getPrimaryImageBlurHash()
                    )
                    .portraitPoster(width: 130)
                    .accessibilityIgnoresInvertColors()

                    rightShelfView
                        .padding(.bottom)
                }

                // MARK: Play

                HStack(alignment: .center) {

                    ItemView.PlayButton(viewModel: viewModel)
                        .frame(width: 130, height: 40)

                    Spacer()

                    ItemView.ActionButtonHStack(viewModel: viewModel, equalSpacing: false)
                        .font(.title2)
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
}
