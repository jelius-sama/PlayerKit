//
//  ContentView.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 14/01/26.
//

import SwiftUI
import Combine

@MainActor
final class SidebarController: ObservableObject {
    @Published var columnVisibility: NavigationSplitViewVisibility = .all

    private var allowNextClose = false

    func closeSidebar() {
        allowNextClose = true
        columnVisibility = .detailOnly
    }

    func openSidebar() {
        columnVisibility = .all
    }

    func toggleSidebar() {
        if columnVisibility == .detailOnly {
            openSidebar()
        } else {
            closeSidebar()
        }
    }

    /// Used by ContentView to decide whether to “reopen” after a user drag collapse.
    func consumeAllowNextClose() -> Bool {
        defer { allowNextClose = false }
        return allowNextClose
    }
}

// TODO: Make the sidebar not collapsible by dragging.
struct ContentView: View {
    @State private var selection: SidebarItem? = .home
    @StateObject private var fullscreen = FullscreenController()
    @StateObject private var sidebar = SidebarController()

    var body: some View {
        NavigationSplitView(columnVisibility: $sidebar.columnVisibility) {
            SidebarView(selection: $selection)
                .navigationSplitViewColumnWidth(min: 250, ideal: 250, max: 250)
        } detail: {
            switch selection {
            case .home:
                HomeView()
                    .environmentObject(fullscreen)
                    .environmentObject(sidebar)
            case .settings:
                Text("Settings")
                    .environmentObject(sidebar)
            case .none:
                Text("Select an item")
                    .environmentObject(sidebar)
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
        .onChange(of: sidebar.columnVisibility) { _, newValue in
            guard newValue == .detailOnly else { return }

            // If it wasn’t closed via `closeSidebar()`, reopen it.
            if !sidebar.consumeAllowNextClose() {
                sidebar.columnVisibility = .all
            }
        }
    }
}
