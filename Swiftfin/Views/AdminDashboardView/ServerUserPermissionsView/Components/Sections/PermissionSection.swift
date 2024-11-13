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

    struct PermissionSection: View {

        @Binding
        var policy: UserPolicy

        var body: some View {
            Section(L10n.permissions) {
                Toggle(L10n.allowMediaDownloads, isOn: Binding(
                    get: { policy.enableContentDownloading ?? false },
                    set: { policy.enableContentDownloading = $0 }
                ))

                Toggle(L10n.hideUserFromLoginScreen, isOn: Binding(
                    get: { policy.isHidden ?? false },
                    set: { policy.isHidden = $0 }
                ))
            }
        }
    }
}
