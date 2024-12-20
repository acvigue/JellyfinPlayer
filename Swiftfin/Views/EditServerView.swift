//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Factory
import SwiftUI

// TODO: change URL picker from menu to list with network-url mapping

/// - Note: Set the environment `isEditing` to `true` to
///         allow server deletion
struct EditServerView: View {

    @EnvironmentObject
    private var router: SelectUserCoordinator.Router

    @Environment(\.isEditing)
    private var isEditing

    @State
    private var currentServerURL: URL
    @State
    private var isPresentingConfirmDeletion: Bool = false

    @StateObject
    private var viewModel: ServerConnectionViewModel

    init(server: ServerState) {
        self._viewModel = StateObject(wrappedValue: ServerConnectionViewModel(server: server))
        self._currentServerURL = State(initialValue: server.currentURL)
    }

    var body: some View {
        List {
            Section {

                TextPairView(
                    leading: L10n.name,
                    trailing: viewModel.server.name
                )

                Picker(L10n.url, selection: $currentServerURL) {
                    ForEach(viewModel.server.urls.sorted(using: \.absoluteString), id: \.self) { url in
                        Text(url.absoluteString)
                            .tag(url)
                            .foregroundColor(.secondary)
                    }
                }
            }

            if isEditing {
                ListRowButton(L10n.delete) {
                    isPresentingConfirmDeletion = true
                }
                .foregroundStyle(.red, .red.opacity(0.2))
            }
        }
        .navigationTitle(L10n.server)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: currentServerURL) { newValue in
            viewModel.setCurrentURL(to: newValue)
        }
        .alert(L10n.deleteServer, isPresented: $isPresentingConfirmDeletion) {
            Button(L10n.delete, role: .destructive) {
                viewModel.delete()
                router.popLast()
            }
        } message: {
            Text("Are you sure you want to delete \(viewModel.server.name) and all of its connected users?")
        }
    }
}
