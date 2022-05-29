//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import SwiftUI

struct PillHStackView<ItemType: PillStackable>: View {

	let title: String
	let items: [ItemType]
	let selectedAction: (ItemType) -> Void

	var body: some View {
		VStack(alignment: .leading) {
			Text(title)
                .font(.title3)
				.fontWeight(.semibold)
				.padding(.top)
                .padding(.leading)
				.accessibility(addTraits: [.isHeader])

			ScrollView(.horizontal, showsIndicators: false) {
				HStack {
					ForEach(items, id: \.title) { item in
						Button {
							selectedAction(item)
						} label: {
							ZStack {
								Color(UIColor.systemFill)
									.frame(maxWidth: .infinity, maxHeight: .infinity)
									.cornerRadius(10)

								Text(item.title)
									.font(.caption)
									.fontWeight(.semibold)
									.foregroundColor(.primary)
									.fixedSize()
                                    .padding(10)
							}
							.fixedSize()
						}
					}
				}
                .padding(.horizontal)
//				.padding(.leading, 16)
//				.padding(.trailing, UIDevice.current.userInterfaceIdiom == .pad ? 16 : 55)
			}
		}
	}
}
