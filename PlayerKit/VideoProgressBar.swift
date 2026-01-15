//
//  VideoProgressBar.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 15/01/26.
//

import SwiftUI

struct VideoProgressBar: View {
    let currentTime: TimeInterval
    let duration: TimeInterval
    let onSeek: (TimeInterval) -> Void
    
    @State private var isDragging = false
    @State private var draggedTime: TimeInterval = 0
    
    private var progress: Double {
        guard duration > 0 else { return 0 }
        let time = isDragging ? draggedTime : currentTime
        return time / duration
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 4)
                
                // Progress track
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * progress, height: 4)
                
                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .offset(x: geometry.size.width * progress - 6)
                    .opacity(isDragging ? 1 : 0)
            }
            .frame(height: 20)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        let x = max(0, min(value.location.x, geometry.size.width))
                        let newProgress = x / geometry.size.width
                        draggedTime = duration * newProgress
                    }
                    .onEnded { value in
                        isDragging = false
                        let x = max(0, min(value.location.x, geometry.size.width))
                        let newProgress = x / geometry.size.width
                        let newTime = duration * newProgress
                        onSeek(newTime)
                    }
            )
        }
        .frame(height: 20)
        .padding(.horizontal)
    }
}
