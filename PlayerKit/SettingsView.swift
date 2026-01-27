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
    @EnvironmentObject private var fullscreen: FullscreenController

    var body: some View {
        VStack {
            Image(systemName: "gearshape").font(.system(size: 40)).padding()
            NavigationLink(
                "Open Profile Settings",
                destination: (Text("This is a Settings Sub-Page"))
                    .toolbar(.hidden)
            )
            .buttonStyle(.bordered)
        }
    }
}
