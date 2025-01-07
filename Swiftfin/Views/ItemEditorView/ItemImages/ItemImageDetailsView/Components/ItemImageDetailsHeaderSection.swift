//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2025 Jellyfin & Jellyfin Contributors
//

import Defaults
import JellyfinAPI
import SwiftUI

extension ItemImageDetailsView {

    struct HeaderSection: View {

        // MARK: - Image Info

        let imageSource: ImageSource
        let posterType: PosterDisplayType

        // MARK: - Header

        @ViewBuilder
        var body: some View {
            Section {
                ImageView(imageSource)
                    .placeholder { _ in
                        Image(systemName: "circle")
                    }
                    .failure {
                        Image(systemName: "circle")
                    }
            }
            .scaledToFit()
            .posterStyle(posterType)
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .listRowCornerRadius(0)
            .listRowInsets(.zero)
        }
    }
}
