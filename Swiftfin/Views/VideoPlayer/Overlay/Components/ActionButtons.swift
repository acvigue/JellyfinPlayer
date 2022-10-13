//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import SwiftUI
import VLCUI

extension ItemVideoPlayer.Overlay {

    struct ActionButtons: View {

        @EnvironmentObject
        private var videoPlayerManager: VideoPlayerManager
        @EnvironmentObject
        private var viewModel: ItemVideoPlayerViewModel
        @EnvironmentObject
        private var videoPlayerProxy: VLCVideoPlayer.Proxy

        @ViewBuilder
        private var barButtons: some View {
            HStack(spacing: 0) {
                
                Button {
                    videoPlayerManager.selectPreviousViewModel()
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .frame(width: 50, height: 50)
                }
                .disabled(videoPlayerManager.previousViewModel == nil)

                Button {
                    videoPlayerManager.selectNextViewModel()
                } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .frame(width: 50, height: 50)
                }
                .disabled(videoPlayerManager.nextViewModel == nil)

//                if !viewModel.subtitleStreams.isEmpty {
//                    Button {
//                        viewModel.subtitlesEnabled.toggle()
//                    } label: {
//                        if viewModel.subtitlesEnabled {
//                            Image(systemName: "captions.bubble.fill")
//                        } else {
//                            Image(systemName: "captions.bubble")
//                        }
//                    }
//                    .disabled(viewModel.selectedSubtitleTrackIndex == -1)
//                    .foregroundColor(viewModel.selectedSubtitleTrackIndex == -1 ? .gray : .white)
//                    .frame(width: 50, height: 50)
//                }
//                
//                Button {
//                    if viewModel.isAspectFilled {
//                        viewModel.isAspectFilled.toggle()
//                        UIView.animate(withDuration: 0.2) {
//                            vlcVideoPlayerProxy.aspectFill(0)
//                        }
//                    } else {
//                        viewModel.isAspectFilled.toggle()
//                        UIView.animate(withDuration: 0.2) {
//                            vlcVideoPlayerProxy.aspectFill(1)
//                        }
//                    }
//                } label: {
//                    Group {
//                        if viewModel.isAspectFilled {
//                            Image(systemName: "arrow.down.right.and.arrow.up.left")
//                        } else {
//                            Image(systemName: "arrow.up.left.and.arrow.down.right")
//                        }
//                    }
//                    .frame(width: 50, height: 50)
//                }
            }
        }

        var body: some View {
            HStack(spacing: 0) {
                barButtons

                OverlayMenu()
            }
        }
    }
}
