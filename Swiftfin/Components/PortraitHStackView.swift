//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import SwiftUI

struct PortraitImageHStackView<TopBarView: View, ItemType: PortraitImageStackable>: View {

	let items: [ItemType]
	let textAlignment: TextAlignment
	let topBarView: () -> TopBarView
	let selectedAction: (ItemType) -> Void

	init(items: [ItemType],
	     textAlignment: TextAlignment = .leading,
	     topBarView: @escaping () -> TopBarView,
	     selectedAction: @escaping (ItemType) -> Void)
	{
		self.items = items
		self.textAlignment = textAlignment
		self.topBarView = topBarView
		self.selectedAction = selectedAction
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			topBarView()

			ScrollView(.horizontal, showsIndicators: false) {
				HStack(alignment: .top, spacing: 15) {
					ForEach(items, id: \.self.portraitImageID) { item in
						Button {
							selectedAction(item)
						} label: {
                            VStack(alignment: .leading) {
								ImageView(item.imageURLConstructor(maxWidth: 110),
								          blurHash: item.blurHash,
								          failureView: {
								          	InitialFailureView(item.failureInitials)
								          })
								          .portraitPoster(width: 110)
								          .accessibilityIgnoresInvertColors()

								if item.showTitle {
									Text(item.title)
										.font(.footnote)
										.fontWeight(.regular)
										.foregroundColor(.primary)
										.multilineTextAlignment(textAlignment)
										.fixedSize(horizontal: false, vertical: true)
										.lineLimit(2)
								}

								if let description = item.subtitle {
									Text(description)
										.font(.caption)
										.fontWeight(.medium)
										.foregroundColor(.secondary)
										.multilineTextAlignment(textAlignment)
										.fixedSize(horizontal: false, vertical: true)
										.lineLimit(2)
								}
							}
							.frame(width: 110)
						}
						.padding(.bottom)
					}
				}
				.padding(.horizontal)
			}
		}
	}
}
