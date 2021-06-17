/* JellyfinPlayer/Swiftfin is subject to the terms of the Mozilla Public
 * License, v2.0. If a copy of the MPL was not distributed with this
 * file, you can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * Copyright 2021 Aiden Vigue & Jellyfin Contributors
 */

import JellyfinAPI
import SwiftUI

struct ConnectToServerView: View {
    @StateObject var viewModel = ConnectToServerViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.isConnectedServer {
                if viewModel.publicUsers.isEmpty {
                    Section(header: Text(viewModel.lastPublicUsers.isEmpty || viewModel.username == "" ? "Login to \(ServerEnvironment.current.server.name ?? "")": "")) {
                        if viewModel.lastPublicUsers.isEmpty || viewModel.username == "" {
                            TextField("Username", text: $viewModel.username)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                        } else {
                            HStack {
                                Spacer()
                                ImageView(src: URL(string: "\(ServerEnvironment.current.server.baseURI ?? "")/Users/\(viewModel.selectedPublicUser.id ?? "")/Images/Primary?width=500&quality=80&tag=\(viewModel.selectedPublicUser.primaryImageTag ?? "")")!)
                                    .frame(width: 250, height: 250)
                                    .cornerRadius(125.0)
                                Spacer()
                            }
                        }

                        SecureField("Password (optional)", text: $viewModel.password)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }

                    Section {
                        HStack {
                            Button {
                                if !viewModel.lastPublicUsers.isEmpty {
                                    viewModel.username = ""
                                    viewModel.showPublicUsers()
                                } else {
                                    viewModel.isConnectedServer = false
                                }
                            } label: {
                                Spacer()
                                HStack {
                                    Text("Back")
                                }
                                Spacer()
                            }

                            Button {
                                viewModel.login()
                            } label: {
                                Spacer()
                                if viewModel.isLoading {
                                    ProgressView()
                                } else {
                                    Text("Login")
                                }
                                Spacer()
                            }.disabled(viewModel.isLoading || viewModel.username.isEmpty)
                        }
                    }
                } else {
                    VStack {
                        HStack {
                            ForEach(viewModel.publicUsers, id: \.id) { publicUser in
                                Button(action: {
                                    if SessionManager.current.doesUserHaveSavedSession(userID: publicUser.id!) {
                                        let user = SessionManager.current.getSavedSession(userID: publicUser.id!)
                                        SessionManager.current.loginWithSavedSession(user: user)
                                    } else {
                                        viewModel.username = publicUser.name ?? ""
                                        viewModel.selectedPublicUser = publicUser
                                        viewModel.hidePublicUsers()
                                        if !(publicUser.hasPassword ?? true) {
                                            viewModel.password = ""
                                            viewModel.login()
                                        }
                                    }
                                }) {
                                    VStack {
                                        if publicUser.primaryImageTag != nil {
                                            ImageView(src: URL(string: "\(ServerEnvironment.current.server.baseURI ?? "")/Users/\(publicUser.id ?? "")/Images/Primary?width=500&quality=80&tag=\(publicUser.primaryImageTag!)")!)
                                                .frame(width: 250, height: 250)
                                                .cornerRadius(125.0)
                                        } else {
                                            Image(systemName: "person.fill")
                                                .foregroundColor(Color(red: 1, green: 1, blue: 1).opacity(0.8))
                                                .font(.system(size: 35))
                                                .frame(width: 250, height: 250)
                                                .background(Color(red: 98 / 255, green: 121 / 255, blue: 205 / 255))
                                                .cornerRadius(125.0)
                                                .shadow(radius: 6)
                                        }
                                        Text(publicUser.name ?? "").font(.headline).fontWeight(.semibold)
                                    }
                                }
                            }
                        }
                        HStack {
                            Spacer()
                            Button {
                                viewModel.hidePublicUsers()
                                viewModel.username = ""
                            } label: {
                                Text("Other User").font(.headline).fontWeight(.semibold)
                            }
                            Spacer()
                        }.padding(.top, 12)
                    }
                }
            } else {
                Form {
                    Section(header: Text("Server Information")) {
                        TextField("Jellyfin Server URL", text: $viewModel.uri)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                        Button {
                            viewModel.connectToServer()
                        } label: {
                            HStack {
                                Text("Connect")
                                Spacer()
                            }
                            if viewModel.isLoading {
                                ProgressView()
                            }
                        }
                        .disabled(viewModel.isLoading || viewModel.uri.isEmpty)
                    }
                }
            }
        }
        .padding(.leading, 90)
        .padding(.trailing, 90)
        .alert(item: $viewModel.errorMessage) { _ in
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("Ok")))
        }
        .navigationTitle(viewModel.isConnectedServer ? "Who's watching?" : "Connect to Jellyfin")
    }
}
