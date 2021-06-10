/* JellyfinPlayer/Swiftfin is subject to the terms of the Mozilla Public
 * License, v2.0. If a copy of the MPL was not distributed with this
 * file, you can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * Copyright 2021 Aiden Vigue & Jellyfin Contributors
 */

import SwiftUI
import NukeUI
import JellyfinAPI

struct NextUpView: View {
    @EnvironmentObject var globalData: GlobalData
    
    @State private var items: [BaseItemDto] = []
    @State private var viewDidLoad: Bool = false;
    
    func onAppear() {
        if(viewDidLoad == true) {
            return
        }
        viewDidLoad = true;
        
        DispatchQueue.global(qos: .userInitiated).async {
            TvShowsAPI.getNextUp(userId: globalData.user.user_id!, limit: 12, fields: [.primaryImageAspectRatio,.seriesPrimaryImage,.seasonUserData,.overview,.genres,.people])
                .sink(receiveCompletion: { completion in
                    HandleAPIRequestCompletion(globalData: globalData, completion: completion)
                }, receiveValue: { response in
                    items = response.items ?? []
                })
                .store(in: &globalData.pendingAPIRequests)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if(items.count != 0) {
                Text("Next Up")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack() {
                        Spacer().frame(width:16)
                        ForEach(items, id: \.id) { item in
                            NavigationLink(destination: ItemView(item: item)) {
                                VStack(alignment: .leading) {
                                    LazyImage(source: item.getSeriesPrimaryImage(baseURL: globalData.server.baseURI!, maxWidth: 100))
                                        .placeholderAndFailure {
                                            Image(uiImage: UIImage(blurHash: item.getSeriesPrimaryImageBlurHash(), size: CGSize(width: 16, height: 20))!)
                                                .resizable()
                                                .frame(width: 100, height: 150)
                                                .cornerRadius(10)
                                        }
                                        .frame(width: 100, height: 150)
                                        .cornerRadius(10)
                                    Spacer().frame(height:5)
                                    Text(item.seriesName!)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Text("S\(item.parentIndexNumber ?? 0):E\(item.indexNumber ?? 0)")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }.frame(width: 100)
                                Spacer().frame(width:16)
                            }
                        }
                    }
                }
                .frame(height: 200)
            }
        }
        .onAppear(perform: onAppear)
        .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
    }
}
