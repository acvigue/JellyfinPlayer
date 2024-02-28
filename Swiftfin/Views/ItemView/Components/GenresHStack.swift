//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

extension ItemView {

    struct GenresHStack: View {

        @EnvironmentObject
        private var router: ItemCoordinator.Router

        let genres: [ItemGenre]

        var body: some View {
            PillHStack(
                title: L10n.genres,
                items: genres
            ).onSelect { _ in
//                router.route(to: \.library, .init(filters: .init(genres: [genre.filter])))
            }
        }
    }
}
