//
//  VLCPlayerView.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 15/01/26.
//

import SwiftUI
import VLCKit

struct VLCPlayerView: NSViewRepresentable {
    let playerManager: VideoPlayerManager
    
    func makeNSView(context: Context) -> VLCVideoView {
        let view = VLCVideoView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
        
        if let player = playerManager.player {
            player.drawable = view
        }
        
        return view
    }
    
    func updateNSView(_ nsView: VLCVideoView, context: Context) {
        // Explicitly do nothing - we don't want to recreate the player
    }
    
    static func == (lhs: VLCPlayerView, rhs: VLCPlayerView) -> Bool {
        // Always return true to prevent re-rendering
        return true
    }
}

extension VLCPlayerView: Equatable {}

class VLCVideoView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
