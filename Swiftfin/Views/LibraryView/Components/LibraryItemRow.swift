//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

struct LibraryItemRow: View {

    @EnvironmentObject
    private var router: LibraryCoordinator.Router

    let item: BaseItemDto
    private var onSelect: () -> Void

    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(alignment: .bottom) {
                PosterButton(item: item, type: .portrait)
                    .scaleItem(0.6)
                    .content { _ in }

                VStack(alignment: .leading) {
                    Text(item.displayName)
                        .foregroundColor(.primary)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    DotHStack {
                        if let premiereYear = item.premiereDateYear {
                            Text(premiereYear)
                        }

                        if let runtime = item.getItemRuntime() {
                            Text(runtime)
                        }

                        if let officialRating = item.officialRating {
                            Text(officialRating)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(Color(UIColor.lightGray))
                }
                .padding(.vertical)

                Spacer()
            }
        }
    }
}

extension LibraryItemRow {
    init(item: BaseItemDto) {
        self.item = item
        self.onSelect = {}
    }

    func onSelect(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onSelect = action
        return copy
    }
}
