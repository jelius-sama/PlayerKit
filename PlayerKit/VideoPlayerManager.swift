//
//  VideoPlayerManager.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 15/01/26.
//

import Foundation
import Combine
import VLCKit

class VideoPlayerManager: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = 0.7
    @Published var isMuted = false
    @Published var isFullscreen = false
    
    private(set) var player: VLCMediaPlayer?
    private var timer: Timer?
    
    var timeDisplay: String {
        let current = formatTime(currentTime)
        let total = formatTime(duration)
        return "\(current) / \(total)"
    }
    
    override init() {
        player = VLCMediaPlayer()
        super.init()
        player?.delegate = self
    }
    
    func loadVideo(url: URL) {
        let media = VLCMedia(url: url)
        player?.media = media
        player?.play()
        isPlaying = true
        
        // Start timer to update progress
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
        
        // Set initial volume
        player?.audio?.volume = Int32(volume * 100)
    }
    
    func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }
    
    func seek(to time: TimeInterval) {
        guard duration > 0 else { return }
        let position = Float(time / duration)
        player?.position = position
        currentTime = time
    }
    
    func skip(seconds: TimeInterval) {
        let newTime = currentTime + seconds
        seek(to: max(0, min(newTime, duration)))
    }
    
    func toggleMute() {
        isMuted.toggle()
        player?.audio?.isMuted = isMuted
    }
    
    func toggleFullscreen() {
        isFullscreen.toggle()
        // This will be handled by the parent view
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        player?.stop()
    }
    
    private func updateProgress() {
        guard let player = player else { return }
        
        if let media = player.media, duration == 0 {
            duration = TimeInterval(media.length.intValue) / 1000.0
        }
        
        if duration > 0 {
            currentTime = TimeInterval(player.position) * duration
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    deinit {
        stop()
    }
}

extension VideoPlayerManager: VLCMediaPlayerDelegate {
    func mediaPlayerStateChanged(_ aNotification: Notification) {
        guard let player = aNotification.object as? VLCMediaPlayer else { return }
        
        DispatchQueue.main.async { [weak self] in
            switch player.state {
            case .playing:
                self?.isPlaying = true
            case .paused, .stopped:
                self?.isPlaying = false
            default:
                break
            }
        }
    }
}
