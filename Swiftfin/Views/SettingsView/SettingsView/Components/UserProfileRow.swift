//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Factory
import SwiftUI

extension SettingsView {

    struct UserProfileRow: View {

        @Injected(UserSession.current)
        private var userSession: UserSession!

        let action: () -> Void

        @ViewBuilder
        private var imageView: some View {
//            ImageView(userSession.user.profileImageSource(client: userSession.client, maxWidth: 120))
//                .pipeline(.Swiftfin.branding)
//                .placeholder { _ in
//                    SystemImageContentView(systemName: "person.fill", ratio: 0.5)
//                }
//                .failure {
//                    SystemImageContentView(systemName: "person.fill", ratio: 0.5)
//                }
            Color.red
        }

        var body: some View {
            Button {
                action()
            } label: {
                HStack {
                    imageView
                        .aspectRatio(contentMode: .fill)
                        .clipShape(.circle)
                        .frame(width: 50, height: 50)

                    Text(userSession.user.username)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.body.weight(.regular))
                        .foregroundColor(.secondary)
                }
            }
            .foregroundStyle(.primary, .secondary)
        }
    }
}
