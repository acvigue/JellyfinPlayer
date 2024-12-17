//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

extension UserSignInView {

    struct PublicUserButton: View {

        // MARK: - Environment Variables

        @Environment(\.isEnabled)
        var isEnabled: Bool

        // MARK: - Public User Variables

        private let user: UserDto
        private let client: JellyfinClient
        private let action: () -> Void

        // MARK: - Initializer

        init(
            user: UserDto,
            client: JellyfinClient,
            action: @escaping () -> Void
        ) {
            self.user = user
            self.client = client
            self.action = action
        }

        // MARK: - Fallback Person View

        @ViewBuilder
        private var fallbackPersonView: some View {
            ZStack {
                Color.secondarySystemFill

                RelativeSystemImageView(systemName: "person.fill", ratio: 0.5)
                    .foregroundStyle(.secondary)
            }
            .clipShape(.circle)
            .aspectRatio(1, contentMode: .fill)
        }

        // MARK: - Person View

        @ViewBuilder
        private var personView: some View {
            ZStack {
                Color.clear

                ImageView(user.profileImageSource(client: client, maxWidth: 120))
                    .image { image in
                        image
                            .posterBorder(ratio: 0.5, of: \.width)
                    }
                    .placeholder { _ in
                        fallbackPersonView
                    }
                    .failure {
                        fallbackPersonView
                    }
            }
        }

        // MARK: - Body

        var body: some View {
            Button {
                action()
            } label: {
                VStack(alignment: .center) {
                    personView
                        .aspectRatio(1, contentMode: .fill)
                        .posterShadow()
                        .clipShape(.circle)
                        .frame(width: 150, height: 150)
                        .padding()

                    Text(user.name ?? .emptyDash)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .padding(.bottom)
                }
            }
            .disabled(!isEnabled)
            .buttonStyle(.card)
            .foregroundStyle(.primary)
        }
    }
}
