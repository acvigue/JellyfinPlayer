//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Combine
import Foundation
import JellyfinAPI
import OrderedCollections
import SwiftUI

final class DevicesViewModel: ViewModel, Stateful {

    // MARK: - Action

    enum Action: Equatable {
        case getDevices(_ userID: String?)
        case setCustomName(id: String, newName: String)
        case deleteDevice(id: String)
        case deleteDevices(ids: [String])
        case deleteAllDevices
    }

    // MARK: - BackgroundState

    enum BackgroundState: Hashable {
        case gettingDevices
        case settingCustomName
        case deletingDevices
    }

    // MARK: - State

    enum State: Hashable {
        case content
        case error(JellyfinAPIError)
        case initial
    }

    @Published
    final var backgroundStates: OrderedSet<BackgroundState> = []
    @Published
    final var devices: OrderedDictionary<String, BindingBox<DeviceInfo?>> = [:]
    @Published
    final var state: State = .initial

    private var deviceTask: AnyCancellable?

    // MARK: - Respond to Action

    func respond(to action: Action) -> State {
        switch action {
        case let .getDevices(userID):
            deviceTask?.cancel()

            backgroundStates.append(.gettingDevices)

            deviceTask = Task { [weak self] in
                do {
                    try await self?.loadDevices(userID: userID)
                    await MainActor.run {
                        self?.state = .content
                    }
                } catch {
                    guard let self else { return }
                    await MainActor.run {
                        self.state = .error(.init(error.localizedDescription))
                    }
                }

                await MainActor.run {
                    self?.backgroundStates.remove(.gettingDevices)
                }
            }
            .asAnyCancellable()

            return state

        case let .setCustomName(id, newName):
            deviceTask?.cancel()

            backgroundStates.append(.settingCustomName)

            deviceTask = Task { [weak self] in
                do {
                    try await self?.setCustomName(id: id, newName: newName)
                    await MainActor.run {
                        self?.state = .content
                    }
                } catch {
                    guard let self else { return }
                    await MainActor.run {
                        self.state = .error(.init(error.localizedDescription))
                    }
                }

                await MainActor.run {
                    self?.backgroundStates.remove(.settingCustomName)
                }
            }
            .asAnyCancellable()

            return state

        case let .deleteDevice(id):
            deviceTask?.cancel()

            backgroundStates.append(.deletingDevices)

            deviceTask = Task { [weak self] in
                do {
                    try await self?.deleteDevice(id: id)
                    await MainActor.run {
                        self?.state = .content
                    }
                } catch {
                    guard let self else { return }
                    await MainActor.run {
                        self.state = .error(.init(error.localizedDescription))
                    }
                }

                await MainActor.run {
                    self?.backgroundStates.remove(.deletingDevices)
                }
            }
            .asAnyCancellable()

            return state

        case let .deleteDevices(ids):
            deviceTask?.cancel()

            backgroundStates.append(.deletingDevices)

            deviceTask = Task { [weak self] in
                do {
                    try await self?.deleteDevices(ids: ids)
                    await MainActor.run {
                        self?.state = .content
                    }
                } catch {
                    guard let self else { return }
                    await MainActor.run {
                        self.state = .error(.init(error.localizedDescription))
                    }
                }

                await MainActor.run {
                    self?.backgroundStates.remove(.deletingDevices)
                }
            }
            .asAnyCancellable()

            return state

        case .deleteAllDevices:
            deviceTask?.cancel()

            backgroundStates.append(.deletingDevices)

            deviceTask = Task { [weak self] in
                do {
                    try await self?.deleteDevices(
                        ids: Array(self?.devices.keys ?? [])
                    )
                    await MainActor.run {
                        self?.state = .content
                    }
                } catch {
                    guard let self else { return }
                    await MainActor.run {
                        self.state = .error(.init(error.localizedDescription))
                    }
                }

                await MainActor.run {
                    self?.backgroundStates.remove(.deletingDevices)
                }
            }
            .asAnyCancellable()

            return state
        }
    }

    // MARK: - Load Devices

    private func loadDevices(userID: String?) async throws {
        var request = Paths.getDevices()

        if let userID = userID {
            request = Paths.getDevices(userID: userID)
        }

        let response = try await userSession.client.send(request)

        guard let devices = response.value.items else {
            return
        }

        await MainActor.run {
            for device in devices {
                guard let id = device.id else { continue }

                if let existingDevice = self.devices[id] {
                    existingDevice.value = device
                } else {
                    self.devices[id] = BindingBox<DeviceInfo?>(
                        source: .init(get: { device }, set: { _ in })
                    )
                }
            }

            self.devices.sort { x, y in
                let device0 = x.value.value
                let device1 = y.value.value
                return (device0?.dateLastActivity ?? Date()) > (device1?.dateLastActivity ?? Date())
            }
        }
    }

    // MARK: - Set Custom Name

    private func setCustomName(id: String, newName: String) async throws {
        let request = Paths.updateDeviceOptions(id: id, DeviceOptionsDto(customName: newName))
        try await userSession.client.send(request)

        if let device = self.devices[id]?.value {
            await MainActor.run {
                self.devices[id]?.value?.name = newName
            }
        }
    }

    // MARK: - Delete Device

    private func deleteDevice(id: String) async throws {
        // Don't allow self-deletion
        guard id != userSession.client.configuration.deviceID else {
            return
        }

        let request = Paths.deleteDevice(id: id)
        try await userSession.client.send(request)

        await MainActor.run {
            self.devices.removeValue(forKey: id)
        }
    }

    // MARK: - Delete Devices

    private func deleteDevices(ids: [String]) async throws {
        guard !ids.isEmpty else {
            return
        }

        let deviceIdsToDelete = ids.filter { $0 != userSession.client.configuration.deviceID }

        try await withThrowingTaskGroup(of: Void.self) { group in
            for deviceId in deviceIdsToDelete {
                group.addTask {
                    try await self.deleteDevice(id: deviceId)
                }
            }

            try await group.waitForAll()
        }

        await MainActor.run {
            self.devices = self.devices.filter {
                !deviceIdsToDelete.contains($0.key)
            }
        }
    }
}
