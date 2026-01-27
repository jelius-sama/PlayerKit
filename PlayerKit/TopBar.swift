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
                        .padding(6)
                }
                .buttonStyle(.glass)
                .clipShape(Circle())
            }

            Spacer()

            if fullscreen.isInFullscreen {
                Button {
                    fullscreen.toggle()
                } label: {
                    Image(
                        systemName: fullscreen.isInFullscreen
                            ? "arrow.down.right.and.arrow.up.left"
                            : "arrow.up.left.and.arrow.down.right"
                    )
                    .padding(6)
                }
                .buttonStyle(.glass)
                .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .frame(height: fullscreen.isInFullscreen ? 44 * 2 : 44)
    }
}
