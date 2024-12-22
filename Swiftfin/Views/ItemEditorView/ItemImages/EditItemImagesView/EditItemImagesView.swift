//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import BlurHashKit
import CollectionVGrid
import Combine
import Defaults
import JellyfinAPI
import SwiftUI

struct EditItemImagesView: View {

    // MARK: - Selected Image Object

    private struct SelectedImage: Identifiable {
        let id = UUID()
        var image: UIImage
        var type: ImageType
        var index: Int
    }

    // MARK: - Defaults

    @Default(.accentColor)
    private var accentColor

    // MARK: - Observed & Environment Objects

    @EnvironmentObject
    private var router: ItemEditorCoordinator.Router

    @StateObject
    var viewModel: ItemImagesViewModel

    // MARK: - Dialog State

    @State
    private var isImportingImage = false
    @State
    private var selectedImage: SelectedImage?

    // MARK: - Error State

    @State
    private var error: Error?

    // MARK: - Computed Properties

    private var orderedItems: [ImageType] {
        ImageType.allCases.sorted { lhs, rhs in
            if lhs == .primary { return true }
            if rhs == .primary { return false }
            return lhs.rawValue.localizedCaseInsensitiveCompare(rhs.rawValue) == .orderedAscending
        }
    }

    // MARK: - Body

    var body: some View {
        contentView
            .navigationBarTitle(L10n.images)
            .navigationBarTitleDisplayMode(.inline)
            .onFirstAppear {
                viewModel.send(.refresh)
            }
            .sheet(item: $selectedImage) { input in
                deletionSheet(input.image, type: input.type, index: input.index)
            }
            .fileImporter(
                isPresented: $isImportingImage,
                allowedContentTypes: [.image],
                allowsMultipleSelection: false
            ) {
                switch $0 {
                case let .success(urls):
                    if let url = urls.first {
                        do {
                            let data = try Data(contentsOf: url)
                            if let image = UIImage(data: data) {
                                viewModel.send(.uploadImage(image: image, type: .primary))
                            }
                        } catch {
                            self.error = JellyfinAPIError("Failed to load image data")
                        }
                    }
                case let .failure(fileError):
                    self.error = fileError
                }
            }
            .onReceive(viewModel.events) { event in
                switch event {
                case .updated:
                    viewModel.send(.refresh)
                case .deleted:
                    break
                case let .error(eventError):
                    self.error = eventError
                }
            }
            .errorMessage($error)
    }

    // MARK: - Content View

    private var contentView: some View {
        ScrollView {
            ForEach(orderedItems, id: \.self) { imageType in
                Section {
                    imageScrollView(for: imageType)
                    Divider().padding(.vertical, 16)
                } header: {
                    sectionHeader(for: imageType)
                }
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func imageScrollView(for imageType: ImageType) -> some View {
        if let images = viewModel.images[imageType.rawValue] {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(images.indices, id: \.self) { index in
                        let image = images[index]
                        imageButton(image) {
                            selectedImage = .init(
                                image: image,
                                type: imageType,
                                index: index
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    @ViewBuilder
    private func sectionHeader(for imageType: ImageType) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Text(imageType.rawValue.localizedCapitalized)
            Spacer()
            Button(action: {
                router.route(
                    to: \.addImage,
                    RemoteImageInfoViewModel(
                        item: viewModel.item,
                        imageType: imageType
                    )
                )
            }) {
                Image(systemName: "magnifyingglass")
            }
            Button(action: { isImportingImage = true }) {
                Image(systemName: "plus")
            }
        }
        .font(.headline)
        .padding(.horizontal, 30)
    }

    // MARK: - Image Button

    private func imageButton(_ image: UIImage, onSelect: @escaping () -> Void) -> some View {
        Button(action: onSelect) {
            ZStack {
                Color.secondarySystemFill
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
            .posterStyle(image.size.height > image.size.width ? .portrait : .landscape)
            .frame(maxHeight: 150)
            .shadow(radius: 4)
            .padding(16)
        }
    }

    // MARK: - Delete Image Confirmation

    @ViewBuilder
    private func deletionSheet(_ image: UIImage, type: ImageType, index: Int) -> some View {
        NavigationView {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()

                Text("\(Int(image.size.width)) x \(Int(image.size.height))")
                    .font(.headline)
            }
            .padding(.horizontal)
            .navigationTitle(L10n.deleteImage)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarCloseButton {
                selectedImage = nil
            }
            .topBarTrailing {
                Button(L10n.delete, role: .destructive) {
                    viewModel.send(.deleteImage(type: type, index: index))
                    selectedImage = nil
                }
                .buttonStyle(.toolbarPill(.red))
            }
        }
    }
}
