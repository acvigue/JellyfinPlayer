//
// SwiftFin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2021 Jellyfin & Jellyfin Contributors
//

import Combine
import Foundation
import JellyfinAPI
import Stinsen

final class ConnectToServerViewModel: ViewModel {

	@RouterObject
	var router: ConnectToServerCoodinator.Router?
	@Published
	var discoveredServers: Set<ServerDiscovery.ServerLookupResponse> = []
	@Published
	var searching = false
	private let discovery = ServerDiscovery()

	var alertTitle: String {
		var message: String = ""
		if errorMessage?.code != ErrorMessage.noShowErrorCode {
			message.append(contentsOf: "\(errorMessage?.code ?? ErrorMessage.noShowErrorCode)\n")
		}
		message.append(contentsOf: "\(errorMessage?.title ?? "Unkown Error")")
		return message
	}

	func connectToServer(uri: String) {
		#if targetEnvironment(simulator)
			var uri = uri
			if uri == "localhost" {
				uri = "http://localhost:8096"
			}
		#endif

		LogManager.shared.log.debug("Attempting to connect to server at \"\(uri)\"", tag: "connectToServer")
		SessionManager.main.connectToServer(with: uri)
			.trackActivity(loading)
			.sink(receiveCompletion: { completion in
				self.handleAPIRequestError(displayMessage: "Unable to connect to server.", logLevel: .critical, tag: "connectToServer",
				                           completion: completion)
			}, receiveValue: { server in
				LogManager.shared.log.debug("Connected to server at \"\(uri)\"", tag: "connectToServer")
				self.router?.route(to: \.userSignIn, server)
			})
			.store(in: &cancellables)
	}

	func discoverServers() {
		discoveredServers.removeAll()
		searching = true

		// Timeout after 3 seconds
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			self.searching = false
		}

		discovery.locateServer { [self] server in
			if let server = server {
				discoveredServers.insert(server)
			}
		}
	}

	func cancelConnection() {
		for cancellable in cancellables {
			cancellable.cancel()
		}

		isLoading = false
	}
}
