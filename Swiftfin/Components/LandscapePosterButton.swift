//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import SwiftUI

struct LandscapePosterButton<Item: LandscapePoster, Content: View, ImageOverlay: View, ContextMenu: View>: View {

    @ScaledMetric(relativeTo: .largeTitle)
    private var baseImageWidth = 200.0

    private let item: Item
    private let itemScale: CGFloat
    private let horizontalAlignment: HorizontalAlignment
    private let content: (Item) -> Content
    private let imageOverlay: (Item) -> ImageOverlay
    private let contextMenu: (Item) -> ContextMenu
    private let selectedAction: (Item) -> Void

    private var itemWidth: CGFloat {
        baseImageWidth * itemScale
    }

    private init(
        item: Item,
        itemScale: CGFloat,
        horizontalAlignment: HorizontalAlignment,
        @ViewBuilder content: @escaping (Item) -> Content,
        @ViewBuilder imageOverlay: @escaping (Item) -> ImageOverlay,
        @ViewBuilder contextMenu: @escaping (Item) -> ContextMenu,
        selectedAction: @escaping (Item) -> Void
    ) {
        self.item = item
        self.itemScale = itemScale
        self.horizontalAlignment = horizontalAlignment
        self.content = content
        self.imageOverlay = imageOverlay
        self.contextMenu = contextMenu
        self.selectedAction = selectedAction
    }

    var body: some View {
        VStack(alignment: horizontalAlignment) {
            Button {
                selectedAction(item)
            } label: {
                ImageView(item.landscapePosterImageSources(maxWidth: itemWidth))
                    .overlay(imageOverlay(item))
                    .landscapePoster(width: itemWidth)
            }
            .contextMenu(menuItems: {
                contextMenu(item)
            })
            .posterShadow()

            content(item)
        }
    }
}

extension LandscapePosterButton where Content == PosterButtonDefaultContentView<Item>,
    ImageOverlay == EmptyView,
    ContextMenu == EmptyView
{
    init(item: Item) {
        self.init(
            item: item,
            itemScale: 1,
            horizontalAlignment: .leading,
            content: { PosterButtonDefaultContentView(item: $0) },
            imageOverlay: { _ in EmptyView() },
            contextMenu: { _ in EmptyView() },
            selectedAction: { _ in }
        )
    }
}

extension LandscapePosterButton {
    @ViewBuilder
    func horizontalAlignment(_ alignment: HorizontalAlignment) -> LandscapePosterButton {
        LandscapePosterButton(
            item: item,
            itemScale: itemScale,
            horizontalAlignment: alignment,
            content: content,
            imageOverlay: imageOverlay,
            contextMenu: contextMenu,
            selectedAction: selectedAction
        )
    }

    @ViewBuilder
    func scaleItem(_ scale: CGFloat) -> LandscapePosterButton {
        LandscapePosterButton(
            item: item,
            itemScale: scale,
            horizontalAlignment: horizontalAlignment,
            content: content,
            imageOverlay: imageOverlay,
            contextMenu: contextMenu,
            selectedAction: selectedAction
        )
    }

    @ViewBuilder
    func content<C: View>(@ViewBuilder _ content: @escaping (Item) -> C) -> LandscapePosterButton<Item, C, ImageOverlay, ContextMenu> {
        LandscapePosterButton<Item, C, ImageOverlay, ContextMenu>(
            item: item,
            itemScale: itemScale,
            horizontalAlignment: horizontalAlignment,
            content: content,
            imageOverlay: imageOverlay,
            contextMenu: contextMenu,
            selectedAction: selectedAction
        )
    }

    @ViewBuilder
    func imageOverlay<O: View>(@ViewBuilder _ imageOverlay: @escaping (Item) -> O) -> LandscapePosterButton<Item, Content, O, ContextMenu> {
        LandscapePosterButton<Item, Content, O, ContextMenu>(
            item: item,
            itemScale: itemScale,
            horizontalAlignment: horizontalAlignment,
            content: content,
            imageOverlay: imageOverlay,
            contextMenu: contextMenu,
            selectedAction: selectedAction
        )
    }

    @ViewBuilder
    func contextMenu<M: View>(@ViewBuilder _ contextMenu: @escaping (Item) -> M) -> LandscapePosterButton<Item, Content, ImageOverlay, M> {
        LandscapePosterButton<Item, Content, ImageOverlay, M>(
            item: item,
            itemScale: itemScale,
            horizontalAlignment: horizontalAlignment,
            content: content,
            imageOverlay: imageOverlay,
            contextMenu: contextMenu,
            selectedAction: selectedAction
        )
    }

    @ViewBuilder
    func selectedAction(_ action: @escaping (Item) -> Void) -> LandscapePosterButton {
        LandscapePosterButton(
            item: item,
            itemScale: itemScale,
            horizontalAlignment: horizontalAlignment,
            content: content,
            imageOverlay: imageOverlay,
            contextMenu: contextMenu,
            selectedAction: action
        )
    }
}