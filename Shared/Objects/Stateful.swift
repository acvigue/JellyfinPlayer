//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Foundation
import OrderedCollections

// TODO: documentation

protocol Stateful: AnyObject {

    associatedtype Action: Equatable
    associatedtype BackgroundState: Hashable = Never
    associatedtype State: Hashable

    /// Background states that the conformer can be in.
    /// Usually used to indicate background events that shouldn't
    /// set the conformer to a primary state.
    var backgroundStates: OrderedSet<BackgroundState> { get set }

    var lastAction: Action? { get set }
    var state: State { get set }

    /// Respond to a sent action and return the new state
    @MainActor
    func respond(to action: Action) -> State

    /// Send an action to the `Stateful` object, which will
    /// `respond` to the action and set the new state.
    @MainActor
    func send(_ action: Action)
}

extension Stateful {

    @MainActor
    func send(_ action: Action) {
        state = respond(to: action)
        lastAction = action
    }
}

extension Stateful where BackgroundState == Never {

    var backgroundStates: OrderedSet<Never> {
        get {
            assertionFailure("Attempted to access `backgroundStates` when there are none")
            return []
        }
        set { assertionFailure("Attempted to set `backgroundStates` when there are none") }
    }
}
