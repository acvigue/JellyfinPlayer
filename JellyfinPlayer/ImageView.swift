//
 /* 
  * SwiftFin is subject to the terms of the Mozilla Public
  * License, v2.0. If a copy of the MPL was not distributed with this
  * file, you can obtain one at https://mozilla.org/MPL/2.0/.
  *
  * Copyright 2021 Aiden Vigue & Jellyfin Contributors
  */

import SwiftUI
import NukeUI

struct ImageView: View {
    private var source: URL = URL(string: "https://example.com")!
    private var blurhash: String = "001fC^"

    init(src: URL) {
        self.source = src
    }

    init(src: URL, bh: String) {
        self.source = src
        self.blurhash = bh
    }

    var body: some View {
        LazyImage(source: source, content: { state in
            if let image = state.image {
                image.resizingMode(.aspectFill)
            } else if state.error != nil {
                Image(uiImage: UIImage(blurHash: "001fC^", size: CGSize(width: 1, height: 1))!)
                    .resizable()
            } else {
                Image(uiImage: UIImage(blurHash: blurhash, size: CGSize(width: 16, height: 16))!)
                    .resizable()
            }
        })
    }
}
