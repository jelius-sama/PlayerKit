//
//  ContentView.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 14/01/26.
//

import SwiftUI

// TODO: Make the sidebar not collapsible by dragging.
struct ContentView: View {
    @State private var selection: SidebarItem? = .home
    @StateObject private var fullscreen = FullscreenController()
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selection: $selection)
                .navigationSplitViewColumnWidth(min: 250, ideal: 250, max: 250)
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
        .navigationSplitViewStyle(.balanced)
        .toolbar(.hidden)
        // The following works with a caveat of still allowing what should ideally be disallowed
        .onChange(of: columnVisibility) { _, newValue in
            if newValue == .detailOnly {
                columnVisibility = .all
            }
        }
    }
}
