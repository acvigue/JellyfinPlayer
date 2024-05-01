//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import CoreStore
import Factory
import Foundation
import JellyfinAPI

typealias ServerModel = SwiftfinStore.V1.StoredServer
typealias UserModel = SwiftfinStore.V1.StoredUser

typealias ServerState = SwiftfinStore.State.Server
typealias UserState = SwiftfinStore.State.User

// MARK: Namespaces

enum SwiftfinStore {

    /// Namespace for V1 objects
    enum V1 {}

    /// Namespace for V2 objects
    enum V2 {}

    /// Namespace for state objects
    enum State {}
}

extension Container {

    static let dataStack = Factory<DataStack>(scope: .singleton) {
        SwiftfinStore.dataStack
    }
}

// MARK: dataStack

extension SwiftfinStore {

    static let dataStack: DataStack = {

        let _dataStack = DataStack(
            V1.schema
        )

        try! _dataStack.addStorageAndWait(SQLiteStore(
            fileName: "Swiftfin.sqlite",
            localStorageOptions: .recreateStoreOnModelMismatch
        ))

        return _dataStack
    }()
}
