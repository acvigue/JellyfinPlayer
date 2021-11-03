//
// SwiftFin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2021 Jellyfin & Jellyfin Contributors
//

import Foundation
import JellyfinAPI

struct ErrorMessage: Identifiable {

	let code: Int
	let title: String
	let displayMessage: String
	let logConstructor: LogConstructor

	// Chosen value such that if an error has this code, don't show the code to the UI
	// This was chosen because of its unlikelyhood to ever be used
	static let noShowErrorCode = -69420

	var id: String {
		"\(code)\(title)\(logConstructor.message)"
	}

	/// If the custom displayMessage is `nil`, it will be set to the given logConstructor's message
	init(code: Int, title: String, displayMessage: String?, logConstructor: LogConstructor) {
		self.code = code
		self.title = title
		self.displayMessage = displayMessage ?? logConstructor.message
		self.logConstructor = logConstructor
	}
}
