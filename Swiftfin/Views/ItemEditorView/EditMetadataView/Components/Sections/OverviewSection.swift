//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Combine
import JellyfinAPI
import SwiftUI

extension EditMetadataView {

    struct OverviewSection: View {

        @Binding
        var item: BaseItemDto

        let itemType: BaseItemKind

        private var showTaglines: Bool {
            [
                BaseItemKind.movie,
                .series,
                .audioBook,
                .book,
                .audio,
            ].contains(itemType)
        }

        var body: some View {
            if showTaglines {
                // There doesn't seem to be a usage anywhere of more than 1 tagline?
                Section(L10n.taglines) {
                    TextField(
                        L10n.tagline,
                        value: $item.taglines
                            .map(
                                getter: { $0 == nil ? "" : $0!.first },
                                setter: { $0 == nil ? [] : [$0!] }
                            ),
                        format: .nilIfEmptyString
                    )
                }
            }

            // TODO: Size Up / Down with Text
            Section(L10n.overview) {
                TextEditor(text: $item.overview.coalesce(""))
                    .frame(minHeight: 100, maxHeight: .infinity)
            }
        }
    }
}
