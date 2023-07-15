//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

extension UserSignInView {

    struct PublicUserSignInView: View {

        @ObservedObject
        var viewModel: UserSignInViewModel

        @State
        private var enteredPassword: String = ""

        let publicUser: UserDto

        var body: some View {
            DisclosureGroup {
                SecureField(L10n.password, text: $enteredPassword)
                Button {
                    viewModel.signIn(username: publicUser.name ?? .emptyDash, password: enteredPassword)
                } label: {
                    L10n.signIn.text
                }
            } label: {
                HStack {
                    ImageView(publicUser.profileImageSource(maxWidth: 50, maxHeight: 50))
                        .failure {
                            Image(systemName: "person.circle")
                                .resizable()
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())

                    Text(publicUser.name ?? .emptyDash)
                    Spacer()
                }
            }
        }
    }
}
