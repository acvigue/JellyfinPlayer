//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import SwiftUI

struct TypeSystemNameView<Item: Poster>: View {

    @State
    private var contentSize: CGSize = .zero

    let item: Item

    var body: some View {
        ZStack {
            Color.secondarySystemFill
                .opacity(0.5)

            if let typeSystemImage = item.typeSystemName {
                Image(systemName: typeSystemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
                    .frame(width: contentSize.width / 3.5, height: contentSize.height / 3)
            }
        }
        .onSizeChanged { newSize in
            contentSize = newSize
        }
    }
}
