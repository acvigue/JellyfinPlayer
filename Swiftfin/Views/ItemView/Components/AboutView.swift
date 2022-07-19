//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

extension ItemView {

	struct AboutView: View {

		@EnvironmentObject
		var itemRouter: ItemCoordinator.Router
		@ObservedObject
		var viewModel: ItemViewModel

		var body: some View {
			VStack(alignment: .leading) {
				L10n.about.text
					.font(.title3)
					.fontWeight(.bold)
					.accessibility(addTraits: [.isHeader])
					.padding(.horizontal)

				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						ImageView(viewModel.item.portraitHeaderViewURL(maxWidth: 110),
						          blurHash: viewModel.item.getPrimaryImageBlurHash())
							.portraitPoster(width: 110)
							.accessibilityIgnoresInvertColors()

						Button {
							itemRouter.route(to: \.itemOverview, viewModel.item)
						} label: {
							ZStack {

								Color.secondarySystemFill
									.cornerRadius(10)

								VStack(alignment: .leading, spacing: 10) {
									Text(viewModel.item.displayName)
										.font(.title3)
										.fontWeight(.semibold)

									Spacer()

									if let overview = viewModel.item.overview {
										Text(overview)
											.lineLimit(4)
											.font(.footnote)
											.foregroundColor(.secondary)
									} else {
										L10n.noOverviewAvailable.text
											.font(.footnote)
											.foregroundColor(.secondary)
									}
								}
								.padding()
							}
							.frame(width: 330)
						}
						.buttonStyle(PlainButtonStyle())
					}
					.padding(.horizontal)
				}
			}
		}
	}
}
