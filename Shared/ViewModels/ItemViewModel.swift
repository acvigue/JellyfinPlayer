//
// SwiftFin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2021 Jellyfin & Jellyfin Contributors
//

import Foundation
import JellyfinAPI

class ItemViewModel: ViewModel {

	@Published
	var item: BaseItemDto
	@Published
	var playButtonItem: BaseItemDto?
	@Published
	var similarItems: [BaseItemDto] = []
	@Published
	var isWatched = false
	@Published
	var isFavorited = false

	init(item: BaseItemDto) {
		self.item = item

		switch item.itemType {
		case .episode, .movie:
			self.playButtonItem = item
		default: ()
		}

		self.isFavorited = item.userData?.isFavorite ?? false
		self.isWatched = item.userData?.played ?? false
		super.init()

		getSimilarItems()
	}

	func playButtonText() -> String {
		item.getItemProgressString() == "" ? "Play" : item.getItemProgressString()
	}

	func getItemDisplayName() -> String {
		item.name ?? ""
	}

	func shouldDisplayRuntime() -> Bool {
		true
	}

	func getSimilarItems() {
		LibraryAPI.getSimilarItems(itemId: item.id!, userId: SessionManager.main.currentLogin.user.id, limit: 20,
		                           fields: [.primaryImageAspectRatio, .seriesPrimaryImage, .seasonUserData, .overview, .genres, .people])
			.trackActivity(loading)
			.sink(receiveCompletion: { [weak self] completion in
				self?.handleAPIRequestError(completion: completion)
			}, receiveValue: { [weak self] response in
				self?.similarItems = response.items ?? []
			})
			.store(in: &cancellables)
	}

	func updateWatchState() {
		if isWatched {
			PlaystateAPI.markUnplayedItem(userId: SessionManager.main.currentLogin.user.id, itemId: item.id!)
				.trackActivity(loading)
				.sink(receiveCompletion: { [weak self] completion in
					self?.handleAPIRequestError(completion: completion)
				}, receiveValue: { [weak self] _ in
					self?.isWatched = false
				})
				.store(in: &cancellables)
		} else {
			PlaystateAPI.markPlayedItem(userId: SessionManager.main.currentLogin.user.id, itemId: item.id!)
				.trackActivity(loading)
				.sink(receiveCompletion: { [weak self] completion in
					self?.handleAPIRequestError(completion: completion)
				}, receiveValue: { [weak self] _ in
					self?.isWatched = true
				})
				.store(in: &cancellables)
		}
	}

	func updateFavoriteState() {
		if isFavorited {
			UserLibraryAPI.unmarkFavoriteItem(userId: SessionManager.main.currentLogin.user.id, itemId: item.id!)
				.trackActivity(loading)
				.sink(receiveCompletion: { [weak self] completion in
					self?.handleAPIRequestError(completion: completion)
				}, receiveValue: { [weak self] _ in
					self?.isFavorited = false
				})
				.store(in: &cancellables)
		} else {
			UserLibraryAPI.markFavoriteItem(userId: SessionManager.main.currentLogin.user.id, itemId: item.id!)
				.trackActivity(loading)
				.sink(receiveCompletion: { [weak self] completion in
					self?.handleAPIRequestError(completion: completion)
				}, receiveValue: { [weak self] _ in
					self?.isFavorited = true
				})
				.store(in: &cancellables)
		}
	}
}
