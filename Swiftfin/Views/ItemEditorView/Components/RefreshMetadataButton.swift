//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

extension ItemEditorView {

    struct RefreshMetadataButton: View {

        // Bug in SwiftUI where Menu item icons will be black in dark mode
        // when a HierarchicalShapeStyle is applied to the Buttons
        @Environment(\.colorScheme)
        private var colorScheme: ColorScheme

        @StateObject
        private var viewModel: RefreshMetadataViewModel

        @State
        private var isPresentingEventAlert = false
        @State
        private var error: JellyfinAPIError?

        // MARK: - Initializer

        init(item: BaseItemDto) {
            _viewModel = StateObject(wrappedValue: RefreshMetadataViewModel(item: item))
        }

        // MARK: - Body

        var body: some View {
            Menu {
                Group {
                    Button(L10n.refresh, systemImage: "arrow.clockwise") {
                        viewModel.send(
                            .refreshMetadata(
                                metadataRefreshMode: .default,
                                imageRefreshMode: .default,
                                replaceMetadata: true,
                                replaceImages: false
                            )
                        )
                    }

                    Button(L10n.findMissing, systemImage: "magnifyingglass") {
                        viewModel.send(
                            .refreshMetadata(
                                metadataRefreshMode: .fullRefresh,
                                imageRefreshMode: .fullRefresh,
                                replaceMetadata: false,
                                replaceImages: false
                            )
                        )
                    }

                    Button(L10n.replaceMetadata, systemImage: "document") {
                        viewModel.send(
                            .refreshMetadata(
                                metadataRefreshMode: .fullRefresh,
                                imageRefreshMode: .none,
                                replaceMetadata: true,
                                replaceImages: false
                            )
                        )
                    }

                    Button(L10n.replaceImages, systemImage: "photo") {
                        viewModel.send(
                            .refreshMetadata(
                                metadataRefreshMode: .none,
                                imageRefreshMode: .fullRefresh,
                                replaceMetadata: false,
                                replaceImages: true
                            )
                        )
                    }

                    Button(L10n.replaceAll, systemImage: "staroflife") {
                        viewModel.send(
                            .refreshMetadata(
                                metadataRefreshMode: .fullRefresh,
                                imageRefreshMode: .fullRefresh,
                                replaceMetadata: true,
                                replaceImages: true
                            )
                        )
                    }
                }
                .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
            } label: {
                HStack {
                    Text(L10n.refreshMetadata)
                        .foregroundStyle(.primary)

                    Spacer()

                    if viewModel.state == .refreshing {
                        ProgressView(value: viewModel.progress)
                            .progressViewStyle(.gauge)
                            .transition(.opacity.combined(with: .scale).animation(.bouncy))
                            .frame(width: 25, height: 25)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(.secondary)
                            .backport
                            .fontWeight(.semibold)
                    }
                }
            }
            .foregroundStyle(.primary, .secondary)
            .disabled(viewModel.state == .refreshing || isPresentingEventAlert)
            .onReceive(viewModel.events) { event in
                switch event {
                case let .error(eventError):
                    error = eventError
                    isPresentingEventAlert = true
                case let .refreshTriggered(triggerDate):
                    // TODO: Do something with this date if needed
                    UIDevice.impact(.light)
                }
            }
            .alert(
                L10n.error,
                isPresented: $isPresentingEventAlert,
                presenting: error
            ) { _ in

            } message: { error in
                Text(error.localizedDescription)
            }
        }
    }
}
