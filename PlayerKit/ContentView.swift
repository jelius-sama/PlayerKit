//
//  ContentView.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 14/01/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var fullscreen = FullscreenController()

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            Text("PlayerKit")
                .font(.largeTitle)
                .bold()

            Button("Toggle Fullscreen") {
                fullscreen.toggle()
            }
            .keyboardShortcut("f", modifiers: [.command])
        }
        .padding()
        .background(
            WindowAccessor { window in
                fullscreen.attach(window: window)
            }
        )
        .frame(minWidth: 600, minHeight: 400)
    }
}

#Preview {
    ContentView()
}
