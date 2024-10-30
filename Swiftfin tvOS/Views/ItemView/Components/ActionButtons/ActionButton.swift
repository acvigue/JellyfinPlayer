//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Defaults
import SwiftUI

extension ItemView {

    struct ActionButton: View {

        @Default(.accentColor)
        private var accentColor

        @Environment(\.isSelected)
        private var isSelected
        @FocusState
        private var isFocused: Bool

        let icon: String
        let selectedIcon: String
        let color: Color
        let onSelect: () -> Void

        // MARK: - Body

        var body: some View {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    onSelect()
                }
            }) {
                ZStack {
                    backgroundShape
                    foregroundIcon
                        .padding(30)
                }
                .frame(width: 100, height: 100)
                .scaleEffect(isFocused ? 1.1 : 1.0)
            }
            .buttonStyle(.borderless)
            .focused($isFocused)
            .padding(12.5)
        }

        // MARK: - Background Shape

        private var backgroundShape: some View {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(isFocused ? .primary : Color.clear)
                .shadow(color: isFocused ? .black.opacity(0.2) : .clear, radius: isFocused ? 4 : 2, x: 0, y: 2)
        }

        // MARK: - Foreground Icon

        private var foregroundIcon: some View {
            Image(systemName: isSelected ? selectedIcon : icon)
                .resizable()
                .foregroundStyle(
                    isFocused ? .black : .primary,
                    isFocused ? (isSelected ? color : .black) : (isSelected ? color : .primary)
                )
                .font(.title3)
                .shadow(color: isFocused || isSelected ? .clear : .black.opacity(0.3), radius: 2, x: 0, y: 2)
        }
    }
}
