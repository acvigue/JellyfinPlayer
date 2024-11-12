//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

extension ServerUserPermissionsView {

    struct UsernameSection: View {

        @Environment(\.isEditing)
        var isEditing

        @Binding
        var username: String
        @Binding
        var policy: UserPolicy

        var body: some View {
            Section(L10n.username) {
                TextField(L10n.name, text: Binding(
                    get: {
                        username
                    },
                    set: {
                        username = $0.isEmpty ? "" : $0
                    }
                ))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
            }
            .disabled(!isEditing)

            Toggle(L10n.active, isOn: Binding(
                get: { !(policy.isDisabled ?? false) },
                set: { policy.isDisabled = !$0 }
            ))
            .disabled(!isEditing)
        }
    }
}
