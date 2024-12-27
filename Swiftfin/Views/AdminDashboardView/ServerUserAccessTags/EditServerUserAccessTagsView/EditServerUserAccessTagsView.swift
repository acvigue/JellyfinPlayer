//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Defaults
import JellyfinAPI
import SwiftUI

struct EditServerUserAccessTagsView: View {

    // MARK: - Defaults

    @Default(.accentColor)
    private var accentColor

    // MARK: - Observed, State, & Environment Objects

    @EnvironmentObject
    private var router: AdminDashboardCoordinator.Router

    @StateObject
    private var viewModel: ServerUserAdminViewModel

    // MARK: - Policy Variable

    @State
    private var tempPolicy: UserPolicy

    // MARK: - Dialog States

    @State
    private var isPresentingDeleteConfirmation = false
    @State
    private var isPresentingDeleteSelectionConfirmation = false

    // MARK: - Editing States

    @State
    private var selectedTags: Set<[String: Bool]> = []
    @State
    private var isEditing: Bool = false

    // MARK: - Error State

    @State
    private var error: Error?

    // MARK: - Computed Policy Tags

    private var policyTags: Set<[String: Bool]> {
        let blockedTags = viewModel.user.policy?.blockedTags?.map { [$0: false] } ?? []
        // let allowedTags = viewModel.user.policy?.allowedTags?.map { [$0: true] } ?? []

        // return Set(allowedTags + blockedTags)
        return Set(blockedTags)
    }

    // MARK: - Initializera

    init(viewModel: ServerUserAdminViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.tempPolicy = viewModel.user.policy ?? UserPolicy()
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .initial, .content:
                contentView
            case let .error(error):
                errorView(with: error)
            }
        }
        .navigationBarTitle("Access Tags")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if isEditing {
                    navigationBarSelectView
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if isEditing {
                    Button(L10n.cancel) {
                        if isEditing {
                            isEditing.toggle()
                        }
                        UIDevice.impact(.light)
                        selectedTags.removeAll()
                    }
                    .buttonStyle(.toolbarPill)
                    .foregroundStyle(accentColor)
                }
            }
            ToolbarItem(placement: .bottomBar) {
                if isEditing {
                    Button(L10n.delete) {
                        isPresentingDeleteSelectionConfirmation = true
                    }
                    .buttonStyle(.toolbarPill(.red))
                    .disabled(selectedTags.isEmpty)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .navigationBarMenuButton(
            isLoading: viewModel.backgroundStates.contains(.refreshing),
            isHidden: isEditing || (
                viewModel.user.policy?.blockedTags == [] &&
                    viewModel.user.policy?.blockedTags == []
            )
        ) {
            Button(L10n.add, systemImage: "plus") {
                router.route(to: \.userAddAccessTag, viewModel)
            }

            if viewModel.user.policy?.blockedTags?.isNotEmpty == true {
                Button(L10n.edit, systemImage: "checkmark.circle") {
                    isEditing = true
                }
            }
        }
        .onReceive(viewModel.events) { events in
            switch events {
            case let .error(eventError):
                error = eventError
            default:
                break
            }
        }
        .errorMessage($error)
        .confirmationDialog(
            L10n.delete,
            isPresented: $isPresentingDeleteSelectionConfirmation,
            titleVisibility: .visible
        ) {
            deleteSelectedConfirmationActions
        } message: {
            Text(L10n.deleteSelectedConfirmation)
        }
        .confirmationDialog(
            L10n.delete,
            isPresented: $isPresentingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            deleteConfirmationActions
        } message: {
            Text(L10n.deleteItemConfirmation)
        }
        .errorMessage($error)
    }

    // MARK: - ErrorView

    @ViewBuilder
    private func errorView(with error: some Error) -> some View {
        ErrorView(error: error)
            .onRetry {
                viewModel.send(.loadDetails)
            }
    }

    // MARK: - Content View

    private var contentView: some View {
        List {
            ListTitleSection(
                "Access Tags", // L10n.accessSchedules.localizedCapitalized,
                description: L10n.accessSchedulesDescription
            ) {
                UIApplication.shared.open(.jellyfinDocsManagingUsers)
            }

            if policyTags.isEmpty {
                Button(L10n.add) {
                    router.route(to: \.userAddAccessTag, viewModel)
                }
            } else {
                ForEach(policyTags.sorted(by: { $0.keys.first ?? "" < $1.keys.first ?? "" }), id: \.self) { tagEntry in
                    if let tag = tagEntry.keys.first, let access = tagEntry.values.first {
                        EditAccessTagRow(
                            item: tag,
                            access: access
                        ) {
                            if isEditing {
                                if selectedTags.contains(tagEntry) {
                                    selectedTags.remove(tagEntry)
                                } else {
                                    selectedTags.insert(tagEntry)
                                }
                            }
                        } onDelete: {
                            selectedTags.removeAll()
                            selectedTags.insert(tagEntry)
                            isPresentingDeleteConfirmation = true
                        }
                        .environment(\.isEditing, isEditing)
                        .environment(\.isSelected, selectedTags.contains(tagEntry))
                    }
                }
            }
        }
    }

    // MARK: - Select/Remove All Button

    @ViewBuilder
    private var navigationBarSelectView: some View {
        let isAllSelected = selectedTags.count == policyTags.count
        Button(isAllSelected ? L10n.removeAll : L10n.selectAll) {
            selectedTags = isAllSelected ? [] : policyTags
        }
        .buttonStyle(.toolbarPill)
        .disabled(!isEditing)
        .foregroundStyle(accentColor)
    }

    // MARK: - Delete Selected Confirmation Actions

    @ViewBuilder
    private var deleteSelectedConfirmationActions: some View {
        Button(L10n.cancel, role: .cancel) {}

        Button(L10n.confirm, role: .destructive) {
            for tagEntry in selectedTags {
                if let tag = tagEntry.keys.first, let isAllowed = tagEntry.values.first {
                    if isAllowed {
                        // tempPolicy.allowedTags?.removeAll { $0 == tag }
                    } else {
                        tempPolicy.blockedTags?.removeAll { $0 == tag }
                    }
                }
            }
            viewModel.send(.updatePolicy(tempPolicy))
            selectedTags.removeAll()
            isEditing = false
        }
    }

    // MARK: - Delete Single Confirmation Actions

    @ViewBuilder
    private var deleteConfirmationActions: some View {
        Button(L10n.cancel, role: .cancel) {}

        Button(L10n.delete, role: .destructive) {
            if let tagEntry = selectedTags.first, selectedTags.count == 1 {
                if let tag = tagEntry.keys.first, let isAllowed = tagEntry.values.first {
                    if isAllowed {
                        // tempPolicy.allowedTags?.removeAll { $0 == tag }
                    } else {
                        tempPolicy.blockedTags?.removeAll { $0 == tag }
                    }
                    viewModel.send(.updatePolicy(tempPolicy))
                    selectedTags.removeAll()
                    isEditing = false
                }
            }
        }
    }
}
