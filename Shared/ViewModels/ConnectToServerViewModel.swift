//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Combine
import Factory
import Foundation
import JellyfinAPI
import Stinsen

struct AddServerURIPayload: Identifiable {

    let server: SwiftfinStore.State.Server
    let uri: String

    var id: String {
        server.id.appending(uri)
    }
}

final class ConnectToServerViewModel: ViewModel {
    
    @Injected(WebSockets.service)
    private var webSocketService

    @RouterObject
    var router: ConnectToServerCoodinator.Router?
    @Published
    var discoveredServers: Set<SwiftfinStore.State.Server> = []
    @Published
    var searching = false
    @Published
    var addServerURIPayload: AddServerURIPayload?
    var backAddServerURIPayload: AddServerURIPayload?

    var alertTitle: String {
        var message: String = ""
        if errorMessage?.code != ErrorMessage.noShowErrorCode {
            message.append(contentsOf: "\(errorMessage?.code ?? ErrorMessage.noShowErrorCode)\n")
        }
        message.append(contentsOf: "\(errorMessage?.title ?? L10n.unknownError)")
        return message
    }

    func connectToServer(uri: String, redirectCount: Int = 0) {

        let uri = uri.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .objectReplacement)

        logger.debug("Attempting to connect to server at \"\(uri)\"", tag: "connectToServer")
        SessionManager.main.connectToServer(with: uri)
            .trackActivity(loading)
            .sink(receiveCompletion: { completion in
                // This is disgusting. ViewModel Error handling overall needs to be refactored
                switch completion {
                case .finished: ()
                case let .failure(error):
                    switch error {
                    case is ErrorResponse:
                        let errorResponse = error as! ErrorResponse
                        switch errorResponse {
                        case let .error(_, _, response, _):
                            // a url in the response is the result if a redirect
                            if let newURL = response?.url {
                                if redirectCount > 2 {
                                    self.handleAPIRequestError(displayMessage: L10n.tooManyRedirects, completion: completion)
                                } else {
                                    self
                                        .connectToServer(
                                            uri: newURL.absoluteString
                                                .removeRegexMatches(pattern: "/web/index.html"),
                                            redirectCount: redirectCount + 1
                                        )
                                }
                            } else {
                                self.handleAPIRequestError(completion: completion)
                            }
                        }
                    case is SwiftfinStore.Error:
                        let swiftfinError = error as! SwiftfinStore.Error
                        switch swiftfinError {
                        case let .existingServer(server):
                            self.addServerURIPayload = AddServerURIPayload(server: server, uri: uri)
                            self.backAddServerURIPayload = AddServerURIPayload(server: server, uri: uri)
                        default:
                            self.handleAPIRequestError(displayMessage: L10n.unableToConnectServer, completion: completion)
                        }
                    default:
                        self.handleAPIRequestError(displayMessage: L10n.unableToConnectServer, completion: completion)
                    }
                }
            }, receiveValue: { server in
                self.logger.debug("Connected to server at \"\(uri)\"", tag: "connectToServer")
                self.router?.route(to: \.userSignIn, server)
            })
            .store(in: &cancellables)
    }

    func discoverServers() {
        discoveredServers.removeAll()
        searching = true
        
        webSocketService.searchLocalServers()
            .receive(on: RunLoop.main)
            .sink { completion in
                if case let Subscribers.Completion.failure(error) = completion {
                    self.logger.error(error.localizedDescription)
                }
            } receiveValue: { response in
                print("Discovered server: \(response.name)")
                self.discoveredServers.insert(response.asStateServer)
            }
            .store(in: &cancellables)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.searching = false
            self.webSocketService.cancelLocalServerSearch()
        }
    }

    func addURIToServer(addServerURIPayload: AddServerURIPayload) {
        SessionManager.main.addURIToServer(server: addServerURIPayload.server, uri: addServerURIPayload.uri)
            .sink { completion in
                self.handleAPIRequestError(displayMessage: L10n.unableToConnectServer, completion: completion)
            } receiveValue: { server in
                SessionManager.main.setServerCurrentURI(server: server, uri: addServerURIPayload.uri)
                    .sink { completion in
                        self.handleAPIRequestError(displayMessage: L10n.unableToConnectServer, completion: completion)
                    } receiveValue: { _ in
                        self.router?.dismissCoordinator()
                    }
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }

    func cancelConnection() {
        for cancellable in cancellables {
            cancellable.cancel()
        }

        self.isLoading = false
    }
}
