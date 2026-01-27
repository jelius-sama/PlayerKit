// SPDX-License-Identifier: See LICENSE
//
// HomeView.swift
// PlayerKit
//
// Copyright (c) 2026 Jelius <personal@jelius.dev>
//
// This file is part of PlayerKit.
// See the LICENSE file in the project root for license information.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: PlayerKitNavigationRouter
    @EnvironmentObject private var fullscreen: FullscreenController

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "house")
                .font(.system(size: 40))

            Button("Go to Sub-Page") {
                router.push(HomeSubView())
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct HomeSubView: View {
    var body: some View {
        Text("This is a Home Sub-Page")
            .font(.title)
            .padding()
    }
}
