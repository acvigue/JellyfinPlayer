//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

extension VideoPlayer.Overlay {

    struct ChapterTrackMask: View {
        
        @State
        private var contentSize: CGSize = .zero
        
        let chapters: [ChapterInfo.FullInfo]
        let item: BaseItemDto

        var body: some View {
            HStack(spacing: 0) {
                ForEach(chapters) { chapter in
                    HStack(spacing: 0) {
                        
                        if chapter.secondsRange.lowerBound != 0 {
                            Color.clear
                                .frame(width: 1.5)
                        }

                        Color.white
                    }
                    .frame(maxWidth: contentSize.width * (chapter.secondsRange.upperBound - chapter.secondsRange.lowerBound) / item.runTimeSeconds)
                }
            }
            .trackingSize($contentSize)
        }
    }
}
