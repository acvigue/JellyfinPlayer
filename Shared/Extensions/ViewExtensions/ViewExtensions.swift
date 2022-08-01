//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Foundation
import SwiftUI

extension View {
    @inlinable
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }

    public func inverseMask<M: View>(_ mask: M) -> some View {
        // exchange foreground and background
        let inversed = mask
            .foregroundColor(.black) // hide foreground
            .background(Color.white) // let the background stand out
            .compositingGroup()
            .luminanceToAlpha()
        return self.mask(inversed)
    }

    // From: https://www.avanderlee.com/swiftui/conditional-view-modifier/
    @ViewBuilder
    @inlinable
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder
    @inlinable
    func `if`<Content: View>(_ condition: Bool, transformIf: (Self) -> Content, transformElse: (Self) -> Content) -> some View {
        if condition {
            transformIf(self)
        } else {
            transformElse(self)
        }
    }

    /// Applies Portrait Poster frame with proper corner radius ratio against the width
    func portraitPoster(width: CGFloat) -> some View {
        self.frame(width: width, height: width * 1.5)
            .cornerRadius((width * 1.5) / 40)
    }

    @inlinable
    func padding2(_ edges: Edge.Set = .all) -> some View {
        self.padding(edges)
            .padding(edges)
    }

    func scrollViewOffset(_ scrollViewOffset: Binding<CGFloat>) -> some View {
        self.modifier(ScrollViewOffsetModifier(scrollViewOffset: scrollViewOffset))
    }

    func navBarOffset(_ scrollViewOffset: Binding<CGFloat>, start: CGFloat, end: CGFloat) -> some View {
        self.modifier(NavBarOffsetModifier(scrollViewOffset: scrollViewOffset, start: start, end: end))
    }

    func backgroundParallaxHeader<Header: View>(
        _ scrollViewOffset: Binding<CGFloat>,
        height: CGFloat,
        multiplier: CGFloat = 1,
        @ViewBuilder header: @escaping () -> Header
    ) -> some View {
        self.modifier(BackgroundParallaxHeaderModifier(scrollViewOffset, height: height, multiplier: multiplier, header: header))
    }

    func bottomEdgeGradient(bottomColor: Color) -> some View {
        self.modifier(BottomEdgeGradientModifier(bottomColor: bottomColor))
    }
}
