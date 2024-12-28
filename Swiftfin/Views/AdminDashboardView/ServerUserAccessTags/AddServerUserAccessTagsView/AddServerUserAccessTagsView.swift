//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

struct AddServerUserAccessTagsView: View {

    // MARK: - Observed & Environment Objects

    @EnvironmentObject
    private var router: BasicNavigationViewCoordinator.Router

    @ObservedObject
    private var viewModel: ServerUserAdminViewModel

    @ObservedObject
    private var tagViewModel: TagEditorViewModel

    // MARK: - Access Tag Variables

    @State
    private var tempPolicy: UserPolicy
    @State
    private var tempTag: String = ""
    @State
    private var access: Bool = false

    // MARK: - Trie Data Loaded

    @State
    private var loaded: Bool = false

    // MARK: - Error State

    @State
    private var error: Error?

    // MARK: - Name is Valid

    private var isValid: Bool {
        tempTag.isNotEmpty
    }

    // MARK: - Name Already Exists

    private var itemAlreadyExists: Bool {
        tagViewModel.trie.contains(key: tempTag.localizedLowercase)
    }

    // MARK: - Initializer

    init(viewModel: ServerUserAdminViewModel) {
        self.viewModel = viewModel
        self.tempPolicy = viewModel.user.policy!
        self.tagViewModel = TagEditorViewModel(item: .init())
    }

    // MARK: - Body

    var body: some View {
        contentView
            .navigationTitle(L10n.addAccessTag.localizedCapitalized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarCloseButton {
                router.dismissCoordinator()
            }
            .topBarTrailing {
                if viewModel.backgroundStates.contains(.refreshing) {
                    ProgressView()
                }
                if viewModel.backgroundStates.contains(.updating) {
                    Button(L10n.cancel) {
                        viewModel.send(.cancel)
                    }
                    .buttonStyle(.toolbarPill(.red))
                } else {
                    Button(L10n.save) {
                        if access {
                            // TODO: Enable on 10.10
                            /* tempPolicy.allowedTags = tempPolicy.allowedTags
                             .appendedOrInit(tempTag) */
                        } else {
                            tempPolicy.blockedTags = tempPolicy.blockedTags
                                .appendedOrInit(tempTag)
                        }

                        viewModel.send(.updatePolicy(tempPolicy))
                    }
                    .buttonStyle(.toolbarPill)
                    .disabled(!isValid)
                }
            }
            .onFirstAppear {
                tagViewModel.send(.load)
            }
            .onChange(of: tempTag) { _ in
                if !tagViewModel.backgroundStates.contains(.loading) {
                    tagViewModel.send(.search(tempTag))
                }
            }
            .onReceive(viewModel.events) { event in
                switch event {
                case let .error(eventError):
                    UIDevice.feedback(.error)
                    error = eventError
                case .updated:
                    UIDevice.feedback(.success)
                    router.dismissCoordinator()
                }
            }
            .onReceive(tagViewModel.events) { event in
                switch event {
                case .updated:
                    break
                case .loaded:
                    loaded = true
                    tagViewModel.send(.search(tempTag))
                case let .error(eventError):
                    UIDevice.feedback(.error)
                    error = eventError
                }
            }
            .errorMessage($error)
    }

    // MARK: - Content View

    private var contentView: some View {
        Form {
            TagInput(
                access: $access,
                tag: $tempTag,
                itemAlreadyExists: itemAlreadyExists
            )

            SearchResultsSection(
                tag: $tempTag,
                population: tagViewModel.matches,
                isSearching: tagViewModel.backgroundStates.contains(.searching)
            )
        }
    }
}
