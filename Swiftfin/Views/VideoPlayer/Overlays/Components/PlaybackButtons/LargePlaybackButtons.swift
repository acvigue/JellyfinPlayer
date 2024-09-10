//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Defaults
import SwiftUI
import VLCUI

extension VideoPlayer.Overlay {

    struct LargePlaybackButtons: View {

        @Default(.VideoPlayer.jumpBackwardLength)
        private var jumpBackwardLength
        @Default(.VideoPlayer.jumpForwardLength)
        private var jumpForwardLength
        @Default(.VideoPlayer.showJumpButtons)
        private var showJumpButtons

        @EnvironmentObject
        private var timerProxy: DelayIntervalTimer
        @EnvironmentObject
        private var manager: MediaPlayerManager
        @EnvironmentObject
        private var vlcUIProxy: VLCVideoPlayer.Proxy

        @ViewBuilder
        private var jumpBackwardButton: some View {
            Button {
                vlcUIProxy.jumpBackward(Int(jumpBackwardLength.rawValue))
                timerProxy.delay(interval: 5)
            } label: {
                Image(systemName: jumpBackwardLength.backwardImageLabel)
                    .font(.system(size: 36, weight: .regular, design: .default))
                    .padding()
                    .contentShape(Rectangle())
            }
            .contentShape(Rectangle())
            .buttonStyle(ScalingButtonStyle(scale: 0.9))
        }

        @ViewBuilder
        private var playButton: some View {
            Button {
                switch manager.state {
                case .playing:
                    vlcUIProxy.pause()
                default:
                    vlcUIProxy.play()
                }
                timerProxy.delay(interval: 5)
            } label: {
                Group {
                    switch manager.state {
                    case .paused:
                        Image(systemName: "play.fill")
                    case .playing:
                        Image(systemName: "pause.fill")
                    default:
                        ProgressView()
                            .scaleEffect(2)
                    }
                }
                .font(.system(size: 56, weight: .bold, design: .default))
                .padding()
                .transition(.opacity.combined(with: .scale).animation(.bouncy))
                .contentShape(Rectangle())
            }
            .contentShape(Rectangle())
            .buttonStyle(ScalingButtonStyle(scale: 0.9))
        }

        @ViewBuilder
        private var jumpForwardButton: some View {
            Button {
                vlcUIProxy.jumpForward(Int(jumpForwardLength.rawValue))
                timerProxy.delay(interval: 5)
            } label: {
                Image(systemName: jumpForwardLength.forwardImageLabel)
                    .font(.system(size: 36, weight: .regular, design: .default))
                    .padding()
                    .contentShape(Rectangle())
            }
            .contentShape(Rectangle())
            .buttonStyle(ScalingButtonStyle(scale: 0.9))
        }

        var body: some View {
            HStack(spacing: 0) {

//                Spacer(minLength: 100)
//
//                if showJumpButtons {
//                    jumpBackwardButton
//                }

                playButton
//                    .frame(minWidth: 100, maxWidth: 300)

//                if showJumpButtons {
//                    jumpForwardButton
//                }

//                Spacer(minLength: 100)
            }
            .tint(Color.white)
            .foregroundColor(Color.white)
        }
    }
}
