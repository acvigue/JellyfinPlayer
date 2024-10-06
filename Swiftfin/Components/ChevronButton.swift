//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import SwiftUI

struct ChevronButton: View {

    private let isExternal: Bool
    private let title: String
    private let subtitle: String?
    private var leadingView: () -> any View
    private var onSelect: () -> Void

    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack {

                leadingView()
                    .eraseToAnyView()

                Text(title)
                    .foregroundStyle(.primary)

                Spacer()

                if let subtitle {
                    Text(subtitle)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: isExternal ? "arrow.up.forward" : "chevron.right")
                    .font(.body.weight(.regular))
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(.primary, .secondary)
    }
}

extension ChevronButton {

    init(_ title: String, subtitle: String? = nil, external: Bool = false) {
        self.init(
            isExternal: external,
            title: title,
            subtitle: subtitle,
            leadingView: { EmptyView() },
            onSelect: {}
        )
    }

    func leadingView(@ViewBuilder _ content: @escaping () -> any View) -> Self {
        copy(modifying: \.leadingView, with: content)
    }

    func onSelect(_ action: @escaping () -> Void) -> Self {
        copy(modifying: \.onSelect, with: action)
    }
}
