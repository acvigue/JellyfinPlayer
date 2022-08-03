//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import SwiftUI

struct UserListView: View {

    @EnvironmentObject
    private var userListRouter: UserListCoordinator.Router
    @ObservedObject
    var viewModel: UserListViewModel

    private var listView: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.users, id: \.id) { user in
                    Button {
                        viewModel.signIn(user: user)
                    } label: {
                        ZStack(alignment: Alignment.leading) {
                            Rectangle()
                                .foregroundColor(Color(UIColor.secondarySystemFill))
                                .frame(height: 50)
                                .cornerRadius(10)

                            HStack {
                                Text(user.username)
                                    .font(.title2)

                                Spacer()

                                if viewModel.isLoading {
                                    ProgressView()
                                }
                            }.padding(.leading)
                        }
                        .padding()
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.remove(user: user)
                        } label: {
                            Label(L10n.remove, systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    private var noUserView: some View {
        VStack {
            L10n.signInGetStarted.text
                .frame(minWidth: 50, maxWidth: 240)
                .multilineTextAlignment(.center)
            
            PrimaryButton(title: L10n.signIn) {
                userListRouter.route(to: \.userSignIn, viewModel.server)
            }
            .frame(maxWidth: 300)
            .frame(height: 50)
        }
    }

    @ViewBuilder
    private var innerBody: some View {
        if viewModel.users.isEmpty {
            noUserView
                .offset(y: -50)
        } else {
            listView
        }
    }

    @ViewBuilder
    private var toolbarContent: some View {
        HStack {
            Button {
                userListRouter.route(to: \.serverDetail, viewModel.server)
            } label: {
                Image(systemName: "info.circle.fill")
            }

            if !viewModel.users.isEmpty {
                Button {
                    userListRouter.route(to: \.userSignIn, viewModel.server)
                } label: {
                    Image(systemName: "person.crop.circle.fill.badge.plus")
                }
            }
        }
    }

    var body: some View {
        innerBody
            .navigationTitle(viewModel.server.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbarContent
                }
            }
            .onAppear {
                viewModel.fetchUsers()
            }
    }
}
