//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import SwiftUI

extension HomeView {
    
    struct ErrorView: View {
        
        let errorMessage: ErrorMessage
        @ObservedObject
        var viewModel: HomeViewModel
        
        var body: some View {
            VStack(spacing: 5) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(width: 100, height: 100)
                        .scaleEffect(2)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 72))
                        .foregroundColor(Color.red)
                        .frame(width: 100, height: 100)
                }

                Text("\(errorMessage.code)")
                Text(errorMessage.message)
                    .frame(minWidth: 50, maxWidth: 240)
                    .multilineTextAlignment(.center)

                PrimaryButtonView(title: L10n.retry) {
                    viewModel.refresh()
                }
            }
            .offset(y: -50)
        }
    }
}
