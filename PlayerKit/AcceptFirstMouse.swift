// SPDX-License-Identifier: See LICENSE
//
// AcceptFirstMouse.swift
// PlayerKit
//
// Copyright (c) 2026 Jelius <personal@jelius.dev>
//
// This file is part of PlayerKit.
// See the LICENSE file in the project root for license information.
//

import AppKit

final class AcceptFirstMouseView: NSView {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }
}

func enableAcceptFirstMouse(on window: NSWindow) {
    guard let contentView = window.contentView else { return }

    // Avoid double-wrapping if SwiftUI reattaches
    if contentView is AcceptFirstMouseView {
        return
    }

    let wrapper = AcceptFirstMouseView(frame: contentView.frame)
    wrapper.autoresizingMask = [.width, .height]

    contentView.autoresizingMask = [.width, .height]
    wrapper.addSubview(contentView)

    window.contentView = wrapper
}
