//
/*
 * SwiftFin is subject to the terms of the Mozilla Public
 * License, v2.0. If a copy of the MPL was not distributed with this
 * file, you can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * Copyright 2021 Aiden Vigue & Jellyfin Contributors
 */

import Foundation
import Introspect
import SwiftUI

struct HomeView: View {

    @EnvironmentObject var homeRouter: HomeCoordinator.Router
    @StateObject var viewModel = HomeViewModel()

    private let refreshHelper = RefreshHelper()

    @ViewBuilder
    var innerBody: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                    if !viewModel.resumeItems.isEmpty {
                        ContinueWatchingView(items: viewModel.resumeItems)
                    }
                    if !viewModel.nextUpItems.isEmpty {
                        NextUpView(items: viewModel.nextUpItems)
                    }

                    ForEach(viewModel.libraries, id: \.self) { library in
                        HStack {
                            Text("Latest \(library.name ?? "")")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Button {
                                homeRouter
                                    .route(to: \.library, (viewModel: .init(parentID: library.id!,
                                                                            filters: viewModel.recentFilterSet),
                                                           title: library.name ?? ""))
                            } label: {
                                HStack {
                                    Text("See All").font(.subheadline).fontWeight(.bold)
                                    Image(systemName: "chevron.right").font(Font.subheadline.bold())
                                }
                            }
                        }.padding(.leading, 16)
                            .padding(.trailing, 16)
                        LatestMediaView(viewModel: .init(libraryID: library.id!))
                    }
                }
                .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 30)
            }
            .introspectScrollView { scrollView in
                let control = UIRefreshControl()

                refreshHelper.refreshControl = control
                refreshHelper.refreshAction = viewModel.refresh

                control.addTarget(refreshHelper, action: #selector(RefreshHelper.didRefresh), for: .valueChanged)
                scrollView.refreshControl = control
            }
        }
    }

    var body: some View {
        innerBody
            .navigationTitle(NSLocalizedString("Home", comment: ""))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        homeRouter.route(to: \.settings)
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
    }
}
