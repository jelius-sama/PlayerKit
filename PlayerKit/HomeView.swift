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

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var fullscreen: FullscreenController

    var body: some View {
        VStack {
            Image(systemName: "house").font(.system(size: 40)).padding()
            NavigationLink(
                "Go to Sub-Page",
                destination: (Text("This is a Home Sub-Page"))
                    .toolbar(.hidden)
            )
            .buttonStyle(.borderedProminent)
        }
    }
}
