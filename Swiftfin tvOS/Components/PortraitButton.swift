//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import SwiftUI
import SwiftUICollection

struct PortraitButton<ItemType: PortraitImageStackable>: View {
    
    let item: ItemType
    let selectedAction: (ItemType) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Button {
                selectedAction(item)
            } label: {
                ImageView(item.imageURLConstructor(maxWidth: 300),
                          blurHash: item.blurHash,
                          failureView: {
                    InitialFailureView(item.failureInitials)
                })
                    .frame(width: 270, height: 405)
            }
            .buttonStyle(CardButtonStyle())

            VStack(alignment: .leading) {
                if item.showTitle {
                    HStack {
                        Text(item.title)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .frame(width: 250)
                        
                        Spacer()
                    }
                }
                
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .zIndex(-1)
            .frame(maxWidth: .infinity)
        }
    }
}
