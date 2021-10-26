//
// SwiftFin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2021 Jellyfin & Jellyfin Contributors
//

import Foundation
import JellyfinAPI

final class MainTabViewModel: ViewModel {
	@Published
	var backgroundURL: URL?
	@Published
	var lastBackgroundURL: URL?
	@Published
	var backgroundBlurHash: String = "001fC^"

	override init() {
		super.init()

		let nc = NotificationCenter.default
		nc.addObserver(self, selector: #selector(backgroundDidChange), name: Notification.Name("backgroundDidChange"), object: nil)
	}

	@objc
	func backgroundDidChange() {
		lastBackgroundURL = backgroundURL
		backgroundURL = BackgroundManager.current.backgroundURL
		backgroundBlurHash = BackgroundManager.current.blurhash
	}
}
