//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Stinsen
import SwiftUI

extension VideoPlayer {

    struct LoadingView: View {

        @EnvironmentObject
        private var router: VideoPlayerCoordinator.Router

        var body: some View {
            ZStack {
                Color.black

                CancellableLoadingButton(L10n.retrievingMediaInformation) {
                    router.dismissCoordinator()
                }
                .foregroundStyle(.white)
            }
        }
    }
}
