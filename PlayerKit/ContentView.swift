//
//  ContentView.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 14/01/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: SidebarItem = .home
    @StateObject private var fullscreen = FullscreenController()

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selection: $selection)
                .frame(width: 220) // 🔒 Fixed, non-resizable
                .background(.ultraThinMaterial)

            Divider()

            Group {
                switch selection {
                case .home:
                    HomeView()
                        .environmentObject(fullscreen)
                case .settings:
                    Text("Settings")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 900, minHeight: 600)
        .background(
            WindowAccessor { window in
                fullscreen.attach(window: window)
            }
        )
    }
}
