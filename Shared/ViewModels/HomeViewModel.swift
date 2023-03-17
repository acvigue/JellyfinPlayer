//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import ActivityIndicator
import Combine
import Foundation
import JellyfinAPI

final class HomeViewModel: ViewModel {

    @Published
    var resumeItems: [BaseItemDto] = []
    @Published
    var hasNextUp: Bool = false
    @Published
    var hasRecentlyAdded: Bool = false
    @Published
    var librariesShowRecentlyAddedIDs: [String] = []
    @Published
    var libraries: [BaseItemDto] = []

    override init() {
        super.init()
        refresh()

        // Nov. 6, 2021
        // This is a workaround since Stinsen doesn't have the ability to rebuild a root at the time of writing.
        // See ServerDetailViewModel.swift for feature request issue
        Notifications[.didSignIn].subscribe(self, selector: #selector(didSignIn))
        Notifications[.didSignOut].subscribe(self, selector: #selector(didSignOut))
    }

    @objc
    private func didSignIn() {
        for cancellable in cancellables {
            cancellable.cancel()
        }

        librariesShowRecentlyAddedIDs = []
        libraries = []
        resumeItems = []

        refresh()
    }

    @objc
    private func didSignOut() {
        for cancellable in cancellables {
            cancellable.cancel()
        }

        cancellables.removeAll()
    }

    @objc
    func refresh() {
        logger.debug("Refresh called.")

        refreshLibrariesLatest()
        refreshLatestAddedItems()
        refreshResumeItems()
        refreshNextUpItems()
    }

    // MARK: Libraries Latest Items

    private func refreshLibrariesLatest() {
        UserViewsAPI.getUserViews(userId: SessionManager.main.currentLogin.user.id)
            .trackActivity(loading)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: ()
                case .failure:
                    self.libraries = []
                }

                self.handleAPIRequestError(completion: completion)
            }, receiveValue: { response in

                var newLibraries: [BaseItemDto] = []

                response.items!.forEach { item in
                    self.logger
                        .debug("Retrieved user view: \(item.id!) (\(item.name ?? "nil")) with type \(item.collectionType ?? "nil")")
                    if item.collectionType == "movies" || item.collectionType == "tvshows" {
                        newLibraries.append(item)
                    }
                }

                UserAPI.getCurrentUser()
                    .trackActivity(self.loading)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished: ()
                        case .failure:
                            self.libraries = []
                            self.handleAPIRequestError(completion: completion)
                        }
                    }, receiveValue: { response in
                        let excludeIDs = response.configuration?.latestItemsExcludes != nil ? response.configuration!
                            .latestItemsExcludes! : []

                        for excludeID in excludeIDs {
                            newLibraries.removeAll { library in
                                library.id == excludeID
                            }
                        }

                        self.libraries = newLibraries
                    })
                    .store(in: &self.cancellables)
            })
            .store(in: &cancellables)
    }

    // MARK: Recently Added Items

    private func refreshLatestAddedItems() {
        UserLibraryAPI.getLatestMedia(
            userId: SessionManager.main.currentLogin.user.id,
            includeItemTypes: [.movie, .series],
            limit: 1
        )
        .sink { completion in
            switch completion {
            case .finished: ()
            case .failure:
                self.hasRecentlyAdded = false
                self.handleAPIRequestError(completion: completion)
            }
        } receiveValue: { items in
            self.hasRecentlyAdded = items.count > 0
        }
        .store(in: &cancellables)
    }

    // MARK: Resume Items

    private func refreshResumeItems() {
        ItemsAPI.getResumeItems(
            userId: SessionManager.main.currentLogin.user.id,
            limit: 20,
            fields: [
                .primaryImageAspectRatio,
                .seriesPrimaryImage,
                .seasonUserData,
                .overview,
                .genres,
                .people,
                .chapters,
            ],
            enableUserData: true
        )
        .trackActivity(loading)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished: ()
            case .failure:
                self.resumeItems = []
                self.handleAPIRequestError(completion: completion)
            }
        }, receiveValue: { response in
            self.logger.debug("Retrieved \(String(response.items!.count)) resume items")

            self.resumeItems = response.items ?? []
        })
        .store(in: &cancellables)
    }

    func refreshResumeItems(completion: @escaping ([BaseItemDto]) -> Void) {
        ItemsAPI.getResumeItems(
            userId: SessionManager.main.currentLogin.user.id,
            limit: 20,
            fields: [
                .primaryImageAspectRatio,
                .seriesPrimaryImage,
                .seasonUserData,
                .overview,
                .genres,
                .people,
                .chapters,
            ],
            enableUserData: true
        )
        .sink { sinkCompletion in
            switch sinkCompletion {
            case .finished: ()
            case .failure:
                completion([])
                self.handleAPIRequestError(completion: sinkCompletion)
            }
        } receiveValue: { response in
            completion(response.items ?? [])
        }
        .store(in: &cancellables)
    }

    func removeItemFromResume(_ item: BaseItemDto) {
        guard let itemID = item.id, resumeItems.contains(where: { $0.id == itemID }) else { return }

        PlaystateAPI.markUnplayedItem(
            userId: SessionManager.main.currentLogin.user.id,
            itemId: item.id!
        )
        .sink(receiveCompletion: { [weak self] completion in
            self?.handleAPIRequestError(completion: completion)
        }, receiveValue: { _ in
            self.refreshResumeItems()
            self.refreshNextUpItems()
        })
        .store(in: &cancellables)
    }

    // MARK: Next Up Items

    private func refreshNextUpItems() {
        TvShowsAPI.getNextUp(
            userId: SessionManager.main.currentLogin.user.id,
            limit: 1
        )
        .trackActivity(loading)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished: ()
            case .failure:
                self.hasNextUp = false
                self.handleAPIRequestError(completion: completion)
            }
        }, receiveValue: { response in
            self.hasNextUp = (response.items ?? []).count > 0
        })
        .store(in: &cancellables)
    }
}
