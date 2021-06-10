/* JellyfinPlayer/Swiftfin is subject to the terms of the Mozilla Public
 * License, v2.0. If a copy of the MPL was not distributed with this
 * file, you can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * Copyright 2021 Aiden Vigue & Jellyfin Contributors
 */

import CoreData
import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var globalData: GlobalData
    @EnvironmentObject var jsi: justSignedIn
    
    @ObservedObject var viewModel: SettingsViewModel

    @Binding var close: Bool
    @State private var inNetworkStreamBitrate: Int = 40_000_000
    @State private var outOfNetworkStreamBitrate: Int = 40_000_000
    @State private var autoSelectSubtitles: Bool = false
    @State private var autoSelectSubtitlesLangcode: String = "none"

    func onAppear() {
        let defaults = UserDefaults.standard
        _inNetworkStreamBitrate.wrappedValue = defaults.integer(forKey: "InNetworkBandwidth")
        _outOfNetworkStreamBitrate.wrappedValue = defaults.integer(forKey: "OutOfNetworkBandwidth")
        _autoSelectSubtitles.wrappedValue = defaults.bool(forKey: "AutoSelectSubtitles")
        _autoSelectSubtitlesLangcode.wrappedValue = defaults.string(forKey: "AutoSelectSubtitlesLangcode") ?? ""
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Playback settings")) {
                    Picker("Default local quality", selection: $inNetworkStreamBitrate) {
                        ForEach(self.viewModel.bitrates, id: \.self) { bitrate in
                            Text(bitrate.name).tag(bitrate.value)
                        }
                    }.onChange(of: inNetworkStreamBitrate) { _ in
                        let defaults = UserDefaults.standard
                        defaults.setValue(_inNetworkStreamBitrate.wrappedValue, forKey: "InNetworkBandwidth")
                    }

                    Picker("Default remote quality", selection: $outOfNetworkStreamBitrate) {
                        ForEach(self.viewModel.bitrates, id: \.self) { bitrate in
                            Text(bitrate.name).tag(bitrate.value)
                        }
                    }.onChange(of: outOfNetworkStreamBitrate) { _ in
                        let defaults = UserDefaults.standard
                        defaults.setValue(_outOfNetworkStreamBitrate.wrappedValue, forKey: "OutOfNetworkBandwidth")
                    }
                }

                Section(header: Text("Accessibility")) {
                    Toggle("Automatically show subtitles", isOn: $autoSelectSubtitles).onChange(of: autoSelectSubtitles, perform: { _ in
                        let defaults = UserDefaults.standard
                        defaults.setValue(autoSelectSubtitles, forKey: "AutoSelectSubtitles")
                    })
                    Picker("Language preferences", selection: $autoSelectSubtitlesLangcode) {}
                }

                Section {
                    HStack {
                        Text("Signed in as \(globalData.user.username!)").foregroundColor(.primary)
                        Spacer()
                        Button {
                            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Server")
                            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

                            do {
                                try viewContext.execute(deleteRequest)
                            } catch _ as NSError {
                                // TODO: handle the error
                            }

                            let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "SignedInUser")
                            let deleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)

                            do {
                                try viewContext.execute(deleteRequest2)
                            } catch _ as NSError {
                                // TODO: handle the error
                            }

                            globalData.server = Server()
                            globalData.user = SignedInUser()
                            globalData.authToken = ""
                            globalData.authHeader = ""
                            jsi.did = true
                            // TODO: This should redirect to the server selection screen
                            exit(-1)
                        } label: {
                            Text("Log out").font(.callout)
                        }
                    }
                }
            }

            .navigationBarTitle("Settings", displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        close = false
                    } label: {
                        Text("Back").font(.callout)
                    }
                }
            }
        }.onAppear(perform: onAppear)
    }
}
