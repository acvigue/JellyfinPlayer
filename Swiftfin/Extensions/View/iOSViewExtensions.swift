//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Defaults
import SwiftUI

extension View {

    func detectOrientation(_ orientation: Binding<UIDeviceOrientation>) -> some View {
        modifier(DetectOrientation(orientation: orientation))
    }

    // TODO: rename `navigationBarOffset`
    func navBarOffset(_ scrollViewOffset: Binding<CGFloat>, start: CGFloat, end: CGFloat) -> some View {
        modifier(NavBarOffsetModifier(scrollViewOffset: scrollViewOffset, start: start, end: end))
    }

    // TODO: rename `navigationBarDrawer`
    func navBarDrawer<Drawer: View>(@ViewBuilder _ drawer: @escaping () -> Drawer) -> some View {
        modifier(NavBarDrawerModifier(drawer: drawer))
    }

    func onAppDidEnterBackground(_ action: @escaping () -> Void) -> some View {
        modifier(
            OnReceiveNotificationModifier(
                notification: UIApplication.didEnterBackgroundNotification,
                onReceive: action
            )
        )
    }

    func onAppWillResignActive(_ action: @escaping () -> Void) -> some View {
        modifier(
            OnReceiveNotificationModifier(
                notification: UIApplication.willResignActiveNotification,
                onReceive: action
            )
        )
    }

    func onAppWillTerminate(_ action: @escaping () -> Void) -> some View {
        modifier(
            OnReceiveNotificationModifier(
                notification: UIApplication.willTerminateNotification,
                onReceive: action
            )
        )
    }

    // TODO: rename `navigationBarCloseButton`
    func navigationCloseButton(accentColor: Color = Defaults[.accentColor], _ action: @escaping () -> Void) -> some View {
        toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button {
                    action()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .accentSymbolRendering(accentColor: accentColor)
                }
            }
        }
    }
}
