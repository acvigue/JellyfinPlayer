//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Defaults
import SwiftUI

struct ExperimentalSettingsView: View {

    @Default(.Experimental.forceDirectPlay)
    var forceDirectPlay
    @Default(.Experimental.syncSubtitleStateWithAdjacent)
    var syncSubtitleStateWithAdjacent
    @Default(.Experimental.nativePlayer)
    var nativePlayer

    @Default(.Experimental.liveTVAlphaEnabled)
    var liveTVAlphaEnabled
    @Default(.Experimental.liveTVForceDirectPlay)
    var liveTVForceDirectPlay
    @Default(.Experimental.liveTVNativePlayer)
    var liveTVNativePlayer

    var body: some View {
        Form {
            Section {

                Toggle("Force Direct Play", isOn: $forceDirectPlay)

                Toggle("Sync Subtitles with Adjacent Episodes", isOn: $syncSubtitleStateWithAdjacent)

                Toggle("Native Player", isOn: $nativePlayer)

            } header: {
                L10n.experimental.text
            }

            Section {

                Toggle("Live TV (Alpha)", isOn: $liveTVAlphaEnabled)

                Toggle("Live TV Force Direct Play", isOn: $liveTVForceDirectPlay)

                Toggle("Live TV Native Player", isOn: $liveTVNativePlayer)

            } header: {
                Text("Live TV")
            }
        }
    }
}
