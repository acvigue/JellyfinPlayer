//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Combine
import Factory
import Foundation

class ViewModel: ObservableObject {

    @Injected(Container.dataStack)
    var dataStack

    @Injected(LogManager.service)
    var logger

    /// The current *signed in* user session
    @Injected(Container.userSession)
    var userSession: SwiftfinSession!

    var cancellables = Set<AnyCancellable>()

    private var userSessionResolverCancellable: AnyCancellable?

    init() {
        userSessionResolverCancellable = Notifications[.didChangeCurrentServerURL]
            .publisher
            .sink { [weak self] _ in
                self?.$userSession.resolve(reset: .scope)
            }
    }
}
