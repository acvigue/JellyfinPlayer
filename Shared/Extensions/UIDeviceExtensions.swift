//
// SwiftFin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2021 Jellyfin & Jellyfin Contributors
//

import UIKit

extension UIDevice {
	static var vendorUUIDString: String {
		return current.identifierForVendor!.uuidString
	}
}
