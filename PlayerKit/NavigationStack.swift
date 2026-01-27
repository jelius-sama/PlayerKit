// SPDX-License-Identifier: See LICENSE
//
// NavigationStack.swift
// PlayerKit
//
// Copyright (c) 2026 Jelius <personal@jelius.dev>
//
// This file is part of PlayerKit.
// See the LICENSE file in the project root for license information.
//

import Combine
import SwiftUI

final class PlayerKitNavigationRouter: ObservableObject {
    @Published private(set) var stack: [AnyView] = []

    func push<V: View>(_ view: V) {
        stack.append(AnyView(view))
    }

    func pop() {
        _ = stack.popLast()
    }

    func popToRoot() {
        stack.removeAll()
    }

    var canGoBack: Bool {
        !stack.isEmpty
    }
}

// We have pre-prended the name with the app name otherwise
// it can be confused with the default NavigationStack
struct PlayerKitNavigationStack<Root: View>: View {
    let sidebarTab: SidebarTab
    @State private var prevSidebarTab: SidebarTab? = nil
    @EnvironmentObject private var fullscreen: FullscreenController
    @StateObject private var router = PlayerKitNavigationRouter()
    let root: Root

    init(sidebarTab: SidebarTab, @ViewBuilder root: () -> Root) {
        self.sidebarTab = sidebarTab
        self.root = root()
    }

    var body: some View {
        VStack(spacing: 0) {
            TopBar()
                .environmentObject(router)
                .environmentObject(fullscreen)

            ZStack(alignment: .top) {
                if let top = router.stack.last {
                    top
                } else {
                    root
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .environmentObject(router)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onChange(of: sidebarTab) { oldTab, newTab in
            handleTabChange(from: oldTab, to: newTab)
        }
        .onAppear {
            prevSidebarTab = sidebarTab
        }
    }

    private func handleTabChange(from oldTab: SidebarTab?, to newTab: SidebarTab) {
        if let oldTab = oldTab, oldTab != newTab {
            router.popToRoot()
        }
        prevSidebarTab = newTab
    }
}
