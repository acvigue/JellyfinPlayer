//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import CollectionHStack
import Defaults
import JellyfinAPI
import OrderedCollections
import SwiftUI

protocol MediaPlayerQueue: MediaPlayerListener, MediaPlayerSupplement {
    
    var hasNextItem: Bool { get }
    var hasPreviousItem: Bool { get }
    
    var items: OrderedSet<BaseItemDto> { get set }
    
    var nextItem: BaseItemDto? { get }
    var previousItem: BaseItemDto? { get }
    
    func playNextItem()
    func playPreviousItem()
}

extension MediaPlayerQueue {
    
    var hasNextItem: Bool {
        guard let currentItem = manager?.item else { return false }
        return items.last != currentItem
    }
    
    var hasPreviousItem: Bool {
        guard let currentItem = manager?.item else { return false }
        return items.first != currentItem
    }
    
    var nextItem: BaseItemDto? {
        guard let currentItem = manager?.item,
              let i = items.firstIndex(where: { $0.id == currentItem.id }),
              i != items.endIndex else { return items.first }
        return items[items.index(after: i)]
    }
    
    var previousItem: BaseItemDto? {
        guard let currentItem = manager?.item,
              let i = items.firstIndex(where: { $0.id == currentItem.id }),
              i != items.startIndex else { return nil }
        return items[items.index(before: i)]
    }
}

class EpisodeMediaPlayerQueue: ViewModel, MediaPlayerQueue {
    
    weak var manager: MediaPlayerManager?
    
    var items: OrderedSet<BaseItemDto> = []
    let title: String = "Episodes"
    
    private let seriesViewModel: SeriesItemViewModel
    
    var id: String {
        "EpisodeMediaPlayerQueue"
    }
    
    init(episode: BaseItemDto) {
        self.seriesViewModel = SeriesItemViewModel(episode: episode)
        super.init()
        
        seriesViewModel.$seasons.sink { seasons in
            
        }
        .store(in: &cancellables)
        
        Task {
            await seriesViewModel.send(.refresh)
        }
    }
    
    private func setup(with manager: MediaPlayerManager) {
        cancellables = []

//        manager.$playbackItem.sink(receiveValue: playbackItemDidChange).store(in: &cancellables)
//        manager.$seconds.sink(receiveValue: secondsDidChange).store(in: &cancellables)
//        manager.$playbackRequestStatus.sink(receiveValue: playbackStatusDidChange).store(in: &cancellables)
    }
    
    func playNextItem() {
        
    }
    
    func playPreviousItem() {
        
    }
    
    @ViewBuilder
    func videoPlayerBody() -> some View {
        _View(viewModel: seriesViewModel)
            .frame(height: 150)
    }
    
    struct _View: View {
        
        @EnvironmentObject
        private var manager: MediaPlayerManager
        
        @ObservedObject
        var viewModel: SeriesItemViewModel
        
        @State
        private var selection: SeasonItemViewModel?
        
        var body: some View {
            ZStack {
                if let selection {
                    CollectionHStack(selection.elements) { item in
                        EpisodeButton(item: item)
                            .frame(height: 150)
                    }
                    .insets(horizontal: .zero)
                    .debugBackground(.green.opacity(0.5))
                    .frame(maxHeight: .infinity)
                } else {
                    CollectionHStack(0 ..< Int.random(in: 2 ..< 5)) { _ in
                        Color.secondarySystemFill
                            .opacity(0.75)
                            .posterStyle(.landscape)
                            .frame(height: 150)
                    }
                    .insets(horizontal: .zero)
                    .debugBackground()
                }
            }
            .frame(height: 150)
            .onReceive(viewModel.playButtonItem.publisher) { newValue in
                if let season = viewModel.seasons.first(where: { $0.season.id == newValue.seasonID }) {
                    selection = season
                } else {
                    selection = viewModel.seasons.first
                }
            }
            .onChange(of: selection) { newValue in
                guard let newValue else {
                    manager.queue?.items.removeAll()
                    return
                }
                
                manager.queue?.items = newValue.elements

                if newValue.state == .initial {
                    newValue.send(.refresh)
                }
            }
            .onChange(of: selection?.elements) { newValue in
                guard let newValue else { return }
                
                manager.queue?.items = newValue
            }
        }
    }
    
    struct EpisodeButton: View {
        
        @Default(.accentColor)
        private var accentColor
        
        @EnvironmentObject
        private var manager: MediaPlayerManager
        
        let item: BaseItemDto
        
        var body: some View {
            Button {
//                manager.set(seconds: chapter.secondsRange.lowerBound)
//                manager.proxy?.setTime(chapter.secondsRange.lowerBound)
                
                manager.send(.playNew(item: item))
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    ZStack {
                        Color.clear
                        
                        ImageView(item.imageSource(.primary, maxWidth: 150))
                            .failure {
                                SystemImageContentView(systemName: item.systemImage)
                            }
                    }
                    .overlay {
                        if manager.item.id == item.id {
                            Rectangle()
                                .stroke(accentColor, lineWidth: 8)
                                .cornerRadius(ratio: 1 / 30, of: \.width)
                        }
                    }
                    .aspectRatio(1.77, contentMode: .fill)
                    .posterBorder(ratio: 1 / 30, of: \.width)
                    .cornerRadius(ratio: 1 / 30, of: \.width)
                    
                    Text(item.displayTitle)
                        .lineLimit(1)
                        .foregroundStyle(.white)
                        .frame(height: 15)
                    
                    Text(item.seasonEpisodeLabel ?? .emptyDash)
                        .frame(height: 20)
                        .foregroundStyle(Color(UIColor.systemBlue))
                        .padding(.horizontal, 4)
                        .background {
                            Color(.darkGray)
                                .opacity(0.2)
                                .cornerRadius(4)
                        }
                }
                .font(.subheadline.weight(.semibold))
            }
        }
    }
}
