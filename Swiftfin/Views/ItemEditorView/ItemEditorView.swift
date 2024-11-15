//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Factory
import JellyfinAPI
import SwiftUI

struct ItemEditorView: View {

    @Injected(\.currentUserSession)
    private var userSession

    @EnvironmentObject
    private var router: ItemEditorCoordinator.Router

    @State
    var item: BaseItemDto

    // MARK: - Body

    var body: some View {
        contentView
            .navigationBarTitle(L10n.metadata)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarCloseButton {
                router.dismissCoordinator()
            }
            .onNotification(.itemMetadataDidChange) { notification in
                guard let newItem = notification.object as? BaseItemDto else { return }
                item = newItem
            }
    }

    // MARK: - Content View

    private var contentView: some View {
        List {
            ListTitleSection(
                item.name ?? L10n.unknown,
                description: item.path
            )

            Section {
                RefreshMetadataButton(item: item)
                    .environment(\.isEnabled, userSession?.user.isAdministrator ?? false)
            } footer: {
                LearnMoreButton(L10n.metadata) {
                    TextPair(
                        title: L10n.refresh,
                        subtitle: "Default refresh with the ability to override metadata without affecting existing images."
                    )
                    TextPair(
                        title: L10n.findMissing,
                        subtitle: "Find missing metadata and images."
                    )
                    TextPair(
                        title: L10n.replaceMetadata,
                        subtitle: "Replace unlocked metadata with new information."
                    )
                    TextPair(
                        title: L10n.replaceImages,
                        subtitle: "Replace all images with new images."
                    )
                    TextPair(
                        title: L10n.replaceAll,
                        subtitle: "Replace all unlocked metadata and images with new information"
                    )
                }
            }
        }
    }
}
