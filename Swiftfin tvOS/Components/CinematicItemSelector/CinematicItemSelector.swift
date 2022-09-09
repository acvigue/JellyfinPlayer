//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Combine
import JellyfinAPI
import Nuke
import SwiftUI

struct CinematicItemSelector: View {
    
    @ObservedObject
    private var viewModel: CinematicBackgroundView.ViewModel = .init()
    
    private var onSelect: (BaseItemDto) -> Void
    let items: [BaseItemDto]
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            CinematicBackgroundView(viewModel: viewModel)
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                if let currentItem = viewModel.currentItem {
                    Text(currentItem.displayName)
                }
                
                PosterHStack(type: .landscape, items: items)
                    .onSelect(onSelect)
                    .onFocus { item in
                        self.viewModel.select(item: item)
                    }
                    .content { _ in
                        EmptyView()
                    }
            }
        }
        .frame(height: UIScreen.main.bounds.height - 100)
        .frame(maxWidth: .infinity)
        .mask {
            LinearGradient(
                stops: [
                    .init(color: .white, location: 0.9),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom)
        }
    }
    
    struct CinematicBackgroundView: UIViewRepresentable {

        @ObservedObject
        var viewModel: ViewModel
        
        @ViewBuilder
        private func imageView(for item: BaseItemDto?) -> some View {
            ImageView(item?.landscapePosterImageSources(maxWidth: UIScreen.main.bounds.width) ?? [])
        }

        func makeUIView(context: Context) -> UIRotateImageView {
            let hostingController = UIHostingController(rootView: imageView(for: viewModel.currentItem), ignoreSafeArea: true)
            return UIRotateImageView(initialView: hostingController.view)
        }

        func updateUIView(_ uiView: UIRotateImageView, context: Context) {
            let hostingController = UIHostingController(rootView: imageView(for: viewModel.currentItem), ignoreSafeArea: true)
            uiView.update(with: hostingController.view)
        }
        
        class ViewModel: ObservableObject {
            
            @Published
            var currentItem: BaseItemDto?
            private var cancellables = Set<AnyCancellable>()
            
            private var currentItemSubject = CurrentValueSubject<BaseItemDto?, Never>(nil)
            
            init() {
                currentItemSubject
                    .debounce(for: 0.5, scheduler: DispatchQueue.main)
                    .sink { newItem in
                        self.currentItem = newItem
                    }
                    .store(in: &cancellables)
            }
            
            func select(item: BaseItemDto) {
                guard currentItem != item else { return }
                currentItemSubject.send(item)
            }
        }
    }
    
    class UIRotateImageView: UIView {

        private var currentView: UIView?

        init(initialView: UIView) {
            super.init(frame: .zero)

            initialView.translatesAutoresizingMaskIntoConstraints = false
            initialView.alpha = 0

            addSubview(initialView)
            NSLayoutConstraint.activate([
                initialView.topAnchor.constraint(equalTo: topAnchor),
                initialView.bottomAnchor.constraint(equalTo: bottomAnchor),
                initialView.leftAnchor.constraint(equalTo: leftAnchor),
                initialView.rightAnchor.constraint(equalTo: rightAnchor),
            ])

            self.currentView = initialView
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func update(with newView: UIView) {
            newView.translatesAutoresizingMaskIntoConstraints = false
            newView.alpha = 0

            addSubview(newView)
            NSLayoutConstraint.activate([
                newView.topAnchor.constraint(equalTo: topAnchor),
                newView.bottomAnchor.constraint(equalTo: bottomAnchor),
                newView.leftAnchor.constraint(equalTo: leftAnchor),
                newView.rightAnchor.constraint(equalTo: rightAnchor),
            ])

            UIView.animate(withDuration: 0.3) {
                newView.alpha = 1
                self.currentView?.alpha = 0
            } completion: { _ in
                self.currentView?.removeFromSuperview()
                self.currentView = newView
            }
        }
    }
}

extension CinematicItemSelector {
    init(items: [BaseItemDto]) {
        self.items = items
        self.onSelect = { _ in }
        
        if let firstItem = items.first {
            viewModel.select(item: firstItem)
        }
    }
    
    func onSelect(_ action: @escaping (BaseItemDto) -> Void) -> Self {
        var copy = self
        copy.onSelect = action
        return copy
    }
}
