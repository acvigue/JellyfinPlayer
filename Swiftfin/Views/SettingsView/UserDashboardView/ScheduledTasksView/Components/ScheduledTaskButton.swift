//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import Stinsen
import SwiftUI

extension ScheduledTasksView {

    struct ScheduledTaskButton: View {

        @EnvironmentObject
        private var router: SettingsCoordinator.Router

        @ObservedObject
        var observer: ServerTaskObserver

        @State
        private var currentDate: Date = .now
        @State
        private var isPresentingConfirmation = false

        private let timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()

        // MARK: - Task Details Section

        @ViewBuilder
        private var taskView: some View {
            VStack(alignment: .leading, spacing: 4) {

                Text(observer.task.name ?? L10n.unknown)
                    .fontWeight(.semibold)

                taskResultView
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }

        // MARK: - Task Status Section

        @ViewBuilder
        private var statusView: some View {
            switch observer.state {
            case .running:
                ZStack {
                    Image(systemName: "stop.fill")
                        .foregroundStyle(.secondary)
                        .padding(6)
                        .overlay {
                            ProgressView(value: (observer.task.currentProgressPercentage ?? 0) / 100)
                                .progressViewStyle(.gauge(lineWidthRatio: 8))
                        }
                }
                .transition(.opacity.combined(with: .scale).animation(.bouncy))
            default:
                Image(systemName: "play.fill")
                    .foregroundStyle(.secondary)
                    .transition(.opacity.combined(with: .scale).animation(.bouncy))
            }
        }

        // MARK: - Task Status View

        @ViewBuilder
        private var taskResultView: some View {
            if observer.state == .running {
                Text(L10n.running)
            } else if observer.task.state == .cancelling {
                Text(L10n.cancelling)
            } else {
                if let taskEndTime = observer.task.lastExecutionResult?.endTimeUtc {
                    Text("\(L10n.lastRun) \(taskEndTime, format: .relative(presentation: .numeric, unitsStyle: .narrow))")
                        .id(currentDate)
                        .monospacedDigit()
                } else {
                    Text(L10n.neverRun)
                }

                if let status = observer.task.lastExecutionResult?.status, status != .completed {
                    Label(
                        status.description,
                        systemImage: "exclamationmark.circle.fill"
                    )
                    .labelStyle(.sectionFooterWithImage(imageStyle: .orange))
                    .foregroundStyle(.orange)
                    .backport
                    .fontWeight(.semibold)
                }
            }
        }

        @ViewBuilder
        var body: some View {
            Button {
                isPresentingConfirmation = true
            } label: {
                HStack {
                    taskView

                    Spacer()

                    statusView
                }
            }
            .animation(.linear(duration: 0.1), value: observer.state)
            .foregroundStyle(.primary, .secondary)
            .onReceive(timer) { newValue in
                currentDate = newValue
            }
            .confirmationDialog(
                observer.task.name ?? .emptyDash,
                isPresented: $isPresentingConfirmation,
                titleVisibility: .visible
            ) {
                Group {
                    if observer.state == .running {
                        Button(L10n.stop) {
                            observer.send(.stop)
                        }
                    } else {
                        Button(L10n.run) {
                            observer.send(.start)
                        }
                    }
                }
                .disabled(observer.task.state == .cancelling)

                Button(L10n.edit) {
                    router.route(to: \.editScheduledTask, observer)
                }
            } message: {
                if let description = observer.task.description {
                    Text(description)
                }
            }
        }
    }
}