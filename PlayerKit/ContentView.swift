// SPDX-License-Identifier: See LICENSE
//
// ContentView.swift
// PlayerKit
//
// Copyright (c) 2026 Jelius <personal@jelius.dev>
//
// This file is part of PlayerKit.
// See the LICENSE file in the project root for license information.
//

import AppKit
import Combine
import SwiftUI
import SwiftUIIntrospect

// TODO: This needs to be improved while maintaing
//       backwards compatibility.
enum SidebarTab: String, CaseIterable, Hashable, Identifiable {
    case home, settings
    var id: String { self.rawValue }
    var title: String { self.rawValue.capitalized }
    var icon: String { self == .home ? "house.fill" : "gearshape.fill" }
}

// For those unfamilier with Apple's UI Frameworks
// this is the entry point for the main app window.
struct ContentView: View {
    @State private var selectedTab: SidebarTab = .home
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var searchText = ""
    @State private var sortOption = "Date"
    @StateObject private var fullscreen = FullscreenController()

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(SidebarTab.allCases, selection: $selectedTab) { tab in
                Label(tab.title, systemImage: tab.icon).tag(tab)
            }
            .toolbar(removing: .sidebarToggle)  // We don't want the sidebar to be closed.
            .navigationSplitViewColumnWidth(200)
        } detail: {
            // TODO: Implement a custom navigation stack so we can control routing
            //       more explicitly, instead of relying on the default navigation stack.
            //       The default navigation stack places its buttons in the title bar,
            //       next to the traffic light buttons. These buttons become hidden when we
            //       enter our custom full screen mode. Because of this, we need to
            //       implement our own navigation stack and position it slightly lower.
            NavigationStack {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                            .environmentObject(fullscreen)
                    case .settings:
                        SettingsView()
                            .environmentObject(fullscreen)
                    }
                }
            }
        }
        // Since SwiftUI doesn't provide a built-in solution to stop sidebar from ever collapsing
        // we go raw and deep inside to fix it.
        .introspect(.navigationSplitView, on: .macOS(.v13, .v14, .v15, .v26)) { splitView in
            if let splitViewController = splitView.delegate as? NSSplitViewController {
                if let sidebarItem = splitViewController.splitViewItems.first {
                    sidebarItem.canCollapse = false  // Disables drag-to-hide
                    sidebarItem.canCollapseFromWindowResize = false
                }
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .background(
            // I don't like how macOS creates a new space when entering full screen mode
            // we have implemented a custom full screen handler and here we attach it to
            // the main app window (patches the green button in the traffic lights).
            WindowAccessor { window in
                fullscreen.attach(window: window)
            }
        )
    }
}
