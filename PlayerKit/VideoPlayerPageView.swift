//
//  VideoPlayerPageView.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 16/01/26.
//

import SwiftUI

struct VideoPlayerPageView: View {
    let videoURL: URL
    let onClose: () -> Void
    
    @StateObject private var playerManager = VideoPlayerManager()
    @EnvironmentObject private var fullscreen: FullscreenController
    @EnvironmentObject private var sidebar: SidebarController
    @State private var showControls = true
    @State private var controlsTimer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(nsColor: .windowBackgroundColor)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Video player area
                    ZStack {
                        Color.black
                        
                        VLCPlayerView(playerManager: playerManager)
                            .onAppear {
                                playerManager.loadVideo(url: videoURL)
                            }
                            .onDisappear {
                                playerManager.stop()
                            }
                        
                        // Controls overlay
                        if showControls {
                            videoControlsOverlay
                        }
                    }
                    .frame(height: fullscreen.isInFullscreen ? geometry.size.height : geometry.size.height * 0.65)
                    .onTapGesture {
                        toggleControls()
                    }
                    .onHover { hovering in
                        if hovering {
                            showControls = true
                            resetControlsTimer()
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: fullscreen.isInFullscreen)
                    
                    // Video info section (hidden in fullscreen)
                    if !fullscreen.isInFullscreen {
                        videoInfoSection
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .windowToolbar)
    }
    
    private var videoControlsOverlay: some View {
        VStack {
            // Top bar
            HStack {
                Button {
                    if fullscreen.isInFullscreen {
                        fullscreen.toggle()
                        sidebar.openSidebar()
                    }
                    onClose()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .background(Color.black.opacity(0.5))
                .clipShape(Circle())
                .keyboardShortcut(.escape, modifiers: [])
                
                Spacer()
                
                if !fullscreen.isInFullscreen {
                    Text(videoURL.lastPathComponent)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Spacer()
                }
                
                Button {
                    fullscreen.toggle()
                    fullscreen.isInFullscreen ? sidebar.closeSidebar() : sidebar.openSidebar()
                } label: {
                    Image(systemName: fullscreen.isInFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .background(Color.black.opacity(0.5))
                .clipShape(Circle())
                .keyboardShortcut("f", modifiers: [])
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0.7), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            Spacer()
            
            // Bottom controls
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
                    .keyboardShortcut(.space, modifiers: [])
                    
                    // Skip backward
                    Button {
                        playerManager.skip(seconds: -10)
                    } label: {
                        Image(systemName: "gobackward.10")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.leftArrow, modifiers: [])
                    
                    // Skip forward
                    Button {
                        playerManager.skip(seconds: 10)
                    } label: {
                        Image(systemName: "goforward.10")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.rightArrow, modifiers: [])
                    
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
                            .onChange(of: playerManager.volume) { _, newValue in
                                playerManager.setVolume(newValue)
                            }
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
        .transition(.opacity)
    }
    
    private var videoInfoSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Video title
                Text(videoURL.lastPathComponent)
                    .font(.title2)
                    .bold()
                
                Divider()
                
                // Video details
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundStyle(.secondary)
                        Text("Location")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    
                    Text(videoURL.deletingLastPathComponent().path)
                        .font(.body)
                        .textSelection(.enabled)
                    
                    Button {
                        NSWorkspace.shared.activateFileViewerSelecting([videoURL])
                    } label: {
                        Label("Show in Finder", systemImage: "arrow.right.circle")
                    }
                    .buttonStyle(.link)
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
            if playerManager.isPlaying && !fullscreen.isInFullscreen {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showControls = false
                }
            }
        }
    }
}
