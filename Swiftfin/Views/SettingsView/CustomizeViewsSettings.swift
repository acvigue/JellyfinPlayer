//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Defaults
import SwiftUI

struct CustomizeViewsSettings: View {

    @Default(.Customization.showFlattenView)
    var showFlattenView
    @Default(.Customization.itemViewType)
    var itemViewType
    
    @Default(.shouldShowMissingSeasons)
    var shouldShowMissingSeasons
    @Default(.shouldShowMissingEpisodes)
    var shouldShowMissingEpisodes
    
    @Default(.Customization.showPosterLabels)
    var showPosterLabels
    @Default(.Customization.nextUpPosterType)
    var nextUpPosterType
    @Default(.Customization.recentlyAddedPosterType)
    var recentlyAddedPosterType
    @Default(.Customization.latestInLibraryPosterType)
    var latestInLibraryPosterType
    @Default(.Customization.recommendedPosterType)
    var recommendedPosterType

    var body: some View {
        List {
            Section {

                Toggle(L10n.showFlattenView, isOn: $showFlattenView)
                
                Picker(L10n.items, selection: $itemViewType) {
                    ForEach(ItemViewType.allCases, id: \.self) { type in
                        Text(type.localizedName).tag(type.rawValue)
                    }
                }
                
            } header: {
                EmptyView()
            }
            
            Section {
                Toggle(L10n.showMissingSeasons, isOn: $shouldShowMissingSeasons)
                Toggle(L10n.showMissingEpisodes, isOn: $shouldShowMissingEpisodes)
            } header: {
                L10n.missingItems.text
            }
            
            Section {

                Toggle(L10n.showPosterLabels, isOn: $showPosterLabels)

                Picker(L10n.nextUp, selection: $nextUpPosterType) {
                    ForEach(PosterType.allCases, id: \.self) { type in
                        Text(type.localizedName).tag(type.rawValue)
                    }
                }
                
                Picker(L10n.recentlyAdded, selection: $recentlyAddedPosterType) {
                    ForEach(PosterType.allCases, id: \.self) { type in
                        Text(type.localizedName).tag(type.rawValue)
                    }
                }
                
                Picker(L10n.library, selection: $latestInLibraryPosterType) {
                    ForEach(PosterType.allCases, id: \.self) { type in
                        Text(type.localizedName).tag(type.rawValue)
                    }
                }
  
                // TODO: Take time to do this for a lot of views
//                Picker(L10n.recommended, selection: $recommendedPosterType) {
//                    ForEach(PosterType.allCases, id: \.self) { type in
//                        Text(type.localizedName).tag(type.rawValue)
//                    }
//                }
                
            } header: {
                Text("Posters")
            }
        }
        .navigationTitle(L10n.customize)
    }
}
