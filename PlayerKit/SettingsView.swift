// SPDX-License-Identifier: See LICENSE
//
// SettingsView.swift
// PlayerKit
//
// Copyright (c) 2026 Jelius <personal@jelius.dev>
//
// This file is part of PlayerKit.
// See the LICENSE file in the project root for license information.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var router: PlayerKitNavigationRouter
    @EnvironmentObject private var fullscreen: FullscreenController

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gearshape").font(.system(size: 40))

            Button("Open Profile Settings") {
                router.push(ProfileView())
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct ProfileView: View {
    var body: some View {
        Text("This is a Profile Page")
            .font(.title)
            .padding()
    }
}
