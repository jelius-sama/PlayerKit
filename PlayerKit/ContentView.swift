//
//  ContentView.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 14/01/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: SidebarItem? = .home
    @StateObject private var fullscreen = FullscreenController()

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
        } detail: {
            switch selection {
            case .home:
                HomeView()
                    .environmentObject(fullscreen)
            case .settings:
                Text("Settings")
            case .none:
                Text("Select an item")
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .background(
            WindowAccessor { window in
                fullscreen.attach(window: window)
            }
        )
    }
}
