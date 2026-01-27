// SPDX-License-Identifier: See LICENSE
//
// TopBar.swift
// PlayerKit
//
// Copyright (c) 2026 Jelius <personal@jelius.dev>
//
// This file is part of PlayerKit.
// See the LICENSE file in the project root for license information.
//

import SwiftUI

struct TopBar: View {
    @EnvironmentObject private var router: PlayerKitNavigationRouter
    @EnvironmentObject private var fullscreen: FullscreenController

    var body: some View {
        HStack {
            if router.canGoBack {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Text("PlayerKit")
                .font(.headline)

            Spacer()

            Button {
                fullscreen.toggle()
            } label: {
                Image(
                    systemName: fullscreen.isInFullscreen
                        ? "arrow.down.right.and.arrow.up.left"
                        : "arrow.up.left.and.arrow.down.right")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .frame(height: 44)
        .background(.ultraThinMaterial)
    }
}
