//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import SwiftUI

struct PillHStack<Item: PillStackable>: View {

    let title: String
    let items: [Item]
    let selectedAction: (Item) -> Void

    private init(
        title: String,
        items: [Item],
        selectedAction: @escaping (Item) -> Void
    ) {
        self.title = title
        self.items = items
        self.selectedAction = selectedAction
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .accessibility(addTraits: [.isHeader])
                .padding(.leading)
                .if(UIDevice.isIPad) { view in
                    view.padding(.leading)
                }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(items, id: \.title) { item in
                        Button {
                            selectedAction(item)
                        } label: {
                            Text(item.title)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(10)
                                .background {
                                    Color.systemFill
                                        .cornerRadius(10)
                                }
                        }
                    }
                }
                .padding(.horizontal)
                .if(UIDevice.isIPad) { view in
                    view.padding(.horizontal)
                }
            }
        }
    }
}

extension PillHStack {

    init(title: String, items: [Item]) {
        self.init(title: title, items: items, selectedAction: { _ in })
    }

    @ViewBuilder
    func selectedAction(_ selectedAction: @escaping (Item) -> Void) -> PillHStack {
        PillHStack(
            title: title,
            items: items,
            selectedAction: selectedAction
        )
    }
}
