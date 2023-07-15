//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

struct UserProfileButton: View {

    @FocusState
    private var isFocused: Bool

    let user: UserDto
    private var action: () -> Void

    init(user: UserDto) {
        self.user = user
        self.action = {}
    }

    init(user: SwiftfinStore.State.User) {
        self.init(user: .init(name: user.username, id: user.id))
    }

    var body: some View {
        VStack(alignment: .center) {
            Button {
                action()
            } label: {
                ImageView(user.profileImageSource(maxWidth: 250, maxHeight: 250))
                    .failure {
                        Image(systemName: "person.fill")
                            .resizable()
                            .padding2()
                    }
                    .frame(width: 200, height: 200)
            }
            .buttonStyle(.card)
            .focused($isFocused)

            Text(user.name ?? .emptyDash)
                .foregroundColor(isFocused ? .primary : .secondary)
        }
    }
}

extension UserProfileButton {
    func onSelect(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.action = action
        return copy
    }
}
