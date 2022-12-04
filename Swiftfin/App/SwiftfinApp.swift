//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Defaults
import MessageUI
import Stinsen
import SwiftUI

@main
struct SwiftfinApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    init() {
        Task {
            for await newValue in Defaults.updates(.accentColor) {
                Self.setupAccentColor(with: newValue.uiColor)
                Self.setupNavigationBackButton(accentColor: newValue.uiColor)
            }
        }
        
        Task {
            for await newValue in Defaults.updates(.appAppearance) {
                Self.setupAppearance(with: newValue.style)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            PreferenceUIHostingControllerView {
                MainCoordinator()
                    .view()
            }
            .ignoresSafeArea()
            .onOpenURL { url in
                AppURLHandler.shared.processDeepLink(url: url)
            }
        }
    }
    
    private static func setupAppearance(with appearance: UIUserInterfaceStyle) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        windowScene?.windows.first?.overrideUserInterfaceStyle = appearance
    }
    
    private static func setupNavigationBackButton(accentColor: UIColor) {
        let config = UIImage.SymbolConfiguration(paletteColors: [accentColor.overlayColor, accentColor])
        let backButtonBackgroundImage = UIImage(systemName: "chevron.backward.circle.fill", withConfiguration: config)
        let barAppearance = UINavigationBar.appearance()
        barAppearance.backIndicatorImage = backButtonBackgroundImage
        barAppearance.backIndicatorTransitionMaskImage = backButtonBackgroundImage
    }
    
    private static func setupAccentColor(with accentColor: UIColor) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        windowScene?.windows.first?.tintColor = accentColor
    }
}

extension UINavigationController {
    // Remove back button text
    override open func viewWillLayoutSubviews() {
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}
