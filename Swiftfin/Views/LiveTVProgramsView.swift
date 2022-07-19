//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Stinsen
import SwiftUI

struct LiveTVProgramsView: View {
	@EnvironmentObject
	var programsRouter: LiveTVProgramsCoordinator.Router
	@StateObject
	var viewModel = LiveTVProgramsViewModel()

	var body: some View {
		ScrollView {
			LazyVStack(alignment: .leading) {
				if !viewModel.recommendedItems.isEmpty,
				   let items = viewModel.recommendedItems
				{
                    PortraitImageHStack(title: "On Now",
                                        items: items) { item in
						if let chanId = item.channelId,
						   let chan = viewModel.findChannel(id: chanId)
						{
							self.viewModel.fetchVideoPlayerViewModel(item: chan) { playerViewModel in
								self.programsRouter.route(to: \.videoPlayer, playerViewModel)
							}
						}
					}
				}
                
				if !viewModel.seriesItems.isEmpty,
				   let items = viewModel.seriesItems
				{
                    PortraitImageHStack(title: "Shows",
                                        items: items) { item in
						if let chanId = item.channelId,
						   let chan = viewModel.findChannel(id: chanId)
						{
							self.viewModel.fetchVideoPlayerViewModel(item: chan) { playerViewModel in
								self.programsRouter.route(to: \.videoPlayer, playerViewModel)
							}
						}
					}
				}
				if !viewModel.movieItems.isEmpty,
				   let items = viewModel.movieItems
				{
                    PortraitImageHStack(title: "Movies",
                                        items: items) { item in
						if let chanId = item.channelId,
						   let chan = viewModel.findChannel(id: chanId)
						{
							self.viewModel.fetchVideoPlayerViewModel(item: chan) { playerViewModel in
								self.programsRouter.route(to: \.videoPlayer, playerViewModel)
							}
						}
					}
				}
				if !viewModel.sportsItems.isEmpty,
				   let items = viewModel.sportsItems
				{
                    PortraitImageHStack(title: "Sports",
                                        items: items) { item in
						if let chanId = item.channelId,
						   let chan = viewModel.findChannel(id: chanId)
						{
							self.viewModel.fetchVideoPlayerViewModel(item: chan) { playerViewModel in
								self.programsRouter.route(to: \.videoPlayer, playerViewModel)
							}
						}
					}
				}
				if !viewModel.kidsItems.isEmpty,
				   let items = viewModel.kidsItems
				{
                    PortraitImageHStack(title: "Kids",
                                        items: items) { item in
						if let chanId = item.channelId,
						   let chan = viewModel.findChannel(id: chanId)
						{
							self.viewModel.fetchVideoPlayerViewModel(item: chan) { playerViewModel in
								self.programsRouter.route(to: \.videoPlayer, playerViewModel)
							}
						}
					}
				}
				if !viewModel.newsItems.isEmpty,
				   let items = viewModel.newsItems
				{
                    PortraitImageHStack(title: "News",
                                        items: items) { item in
						if let chanId = item.channelId,
						   let chan = viewModel.findChannel(id: chanId)
						{
							self.viewModel.fetchVideoPlayerViewModel(item: chan) { playerViewModel in
								self.programsRouter.route(to: \.videoPlayer, playerViewModel)
							}
						}
					}
				}
			}
		}
	}
}
