//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import CoreStore
import Defaults
import Factory
import Logging
import Pulse
import PulseLogHandler
import SwiftUI

@main
struct SwiftfinApp: App {

    init() {

        // Logging
        LoggingSystem.bootstrap { label in

            var loggers: [LogHandler] = [PersistentLogHandler(label: label).withLogLevel(.trace)]

            #if DEBUG
            loggers.append(SwiftfinConsoleLogger())
            #endif

            return MultiplexLogHandler(loggers)
        }

        CoreStoreDefaults.dataStack = SwiftfinStore.dataStack
        CoreStoreDefaults.logger = SwiftfinCorestoreLogger()
    }

    var body: some Scene {
        WindowGroup {
            MainCoordinator()
                .view()
                .onNotification(UIApplication.didEnterBackgroundNotification) { _ in
                    Defaults[.backgroundTimeStamp] = Date.now
                }
                .onNotification(UIApplication.willEnterForegroundNotification) { _ in
                    // TODO: needs to check if any background playback is happening
                    let backgroundedInterval = Date.now.timeIntervalSince(Defaults[.backgroundTimeStamp])

                    if Defaults[.signOutOnBackground], backgroundedInterval > Defaults[.backgroundSignOutInterval] {
                        Defaults[.lastSignedInUserID] = nil
                        Container.userSession.reset()
                        Notifications[.didSignOut].post()
                    }
                }
                .onNotification(UIApplication.willTerminateNotification) { _ in
                    if Defaults[.signOutOnClose] {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            Defaults[.lastSignedInUserID] = nil
                            Container.userSession.reset()
                            Notifications[.didSignOut].post()
                        }
                    }
                }
        }
    }
}
