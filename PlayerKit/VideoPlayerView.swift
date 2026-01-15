//
//  VideoPlayerView.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 15/01/26.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoURL: URL
    @Environment(\.dismiss) private var dismiss
    @StateObject private var playerManager = VideoPlayerManager()
    @State private var showControls = true
    @State private var controlsTimer: Timer?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            // Video content
            VLCPlayerView(playerManager: playerManager)
                .onAppear {
                    playerManager.loadVideo(url: videoURL)
                }
                .onDisappear {
                    playerManager.stop()
                }
            
            // Controls overlay
            if showControls {
                VStack {
                    // Top bar
                    topBar
                    
                    Spacer()
                    
                    // Bottom controls
                    bottomControls
                }
                .transition(.opacity)
            }
        }
        .onTapGesture {
            toggleControls()
        }
        .onHover { hovering in
            if hovering {
                showControls = true
                resetControlsTimer()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .background(Color.black.opacity(0.5))
            .clipShape(Circle())
            
            Spacer()
            
            Text(videoURL.lastPathComponent)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(1)
            
            Spacer()
            
            Button {
                playerManager.toggleFullscreen()
            } label: {
                Image(systemName: playerManager.isFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .background(Color.black.opacity(0.5))
            .clipShape(Circle())
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.7), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var bottomControls: some View {
        VStack(spacing: 12) {
            // Progress bar
            VideoProgressBar(
                currentTime: playerManager.currentTime,
                duration: playerManager.duration,
                onSeek: { time in
                    playerManager.seek(to: time)
                }
            )
            
            // Playback controls
            HStack(spacing: 24) {
                // Play/Pause
                Button {
                    playerManager.togglePlayPause()
                } label: {
                    Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                
                // Skip backward
                Button {
                    playerManager.skip(seconds: -10)
                } label: {
                    Image(systemName: "gobackward.10")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                
                // Skip forward
                Button {
                    playerManager.skip(seconds: 10)
                } label: {
                    Image(systemName: "goforward.10")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Time display
                Text(playerManager.timeDisplay)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .monospacedDigit()
                
                // Volume control
                HStack(spacing: 8) {
                    Image(systemName: playerManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .foregroundStyle(.white)
                        .onTapGesture {
                            playerManager.toggleMute()
                        }
                    
                    Slider(value: $playerManager.volume, in: 0...1)
                        .frame(width: 100)
                        .tint(.white)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private func toggleControls() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showControls.toggle()
        }
        if showControls {
            resetControlsTimer()
        }
    }
    
    private func resetControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            if playerManager.isPlaying {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showControls = false
                }
            }
        }
    }
}
