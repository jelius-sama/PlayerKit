//
//  ContentView.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 14/01/26.
//

import AppKit
import Combine
import SwiftUI
import SwiftUIIntrospect

enum SidebarTab: String, CaseIterable, Hashable, Identifiable {
    case home, settings
    var id: String { self.rawValue }
    var title: String { self.rawValue.capitalized }
    var icon: String { self == .home ? "house.fill" : "gearshape.fill" }
}

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
            .toolbar(removing: .sidebarToggle)  // Prevents manual hide
            .navigationSplitViewColumnWidth(200)
        } detail: {
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
            WindowAccessor { window in
                fullscreen.attach(window: window)
            }
        )
    }
}
