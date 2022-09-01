//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import SwiftUI
import JellyfinAPI

extension ItemView {
    struct CastAndCrewHStack: View {
        
        @EnvironmentObject
        private var router: ItemCoordinator.Router
        let people: [BaseItemPerson]
        
        var body: some View {
            PosterHStack(title: L10n.castAndCrew,
                         type: .portrait,
                         items: people)
                .onSelect { person in
                    router.route(to: \.library, .init(parent: person, type: .person, filters: .init()))
                }
        }
    }
}
