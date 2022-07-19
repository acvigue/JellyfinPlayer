//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Defaults
import Foundation
import SwiftUI

extension SeriesItemView {

	struct ContentView: View {

		@EnvironmentObject
		private var itemRouter: ItemCoordinator.Router

		@ObservedObject
		var viewModel: SeriesItemViewModel
		@State
		var scrollViewProxy: ScrollViewProxy
		@State
		var showLogo: Bool = false

		@ObservedObject
		var focusGuide = FocusGuide()

		var body: some View {
			VStack(spacing: 0) {

				ItemView.StaticOverlayView(viewModel: viewModel,
				                           scrollViewProxy: scrollViewProxy)
					.focusGuide(focusGuide, tag: "mediaButtons", bottom: "seasons")
					.frame(height: UIScreen.main.bounds.height - 150)
					.padding(.bottom, 50)

				VStack(spacing: 0) {

					Color.clear
						.frame(height: 0.5)
						.id("topContentDivider")

					if showLogo {
						ImageView(viewModel.item.getLogoImage(maxWidth: 500),
						          resizingMode: .aspectFit,
						          failureView: {
						          	Text(viewModel.item.displayName)
						          		.font(.largeTitle)
						          		.fontWeight(.semibold)
						          		.lineLimit(2)
						          		.multilineTextAlignment(.leading)
						          		.foregroundColor(.white)
						          })
						          .frame(width: 500, height: 150)
						          .padding(.top, 5)
					}

					SeriesEpisodesView(viewModel: viewModel)
						.environmentObject(focusGuide)

					PortraitImageHStack(title: L10n.recommended,
					                    items: viewModel.similarItems) { item in
						itemRouter.route(to: \.item, item)
					}
					.focusGuide(focusGuide, tag: "recommended", top: "seasons")

					Spacer()
				}
				.frame(minHeight: UIScreen.main.bounds.height)
			}
			.background {
				BlurView()
					.mask {
						VStack(spacing: 0) {
							LinearGradient(gradient: Gradient(stops: [
								.init(color: .white, location: 0),
								.init(color: .white.opacity(0.5), location: 0.2),
								.init(color: .white.opacity(0), location: 1),
							]), startPoint: .bottom, endPoint: .top)
								.frame(height: UIScreen.main.bounds.height - 150)

							Color.white
						}
					}
			}
			.onChange(of: focusGuide.focusedTag) { newTag in
				if newTag == "seasons" && !showLogo {
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
						withAnimation(.easeIn(duration: 0.35)) {
							scrollViewProxy.scrollTo("topContentDivider")
						}
					}
					withAnimation {
						self.showLogo = true
					}
				} else if newTag == "mediaButtons" {
					withAnimation {
						self.showLogo = false
					}
				}
			}
		}
	}
}
