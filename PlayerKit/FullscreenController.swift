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

final class FullscreenController: ObservableObject {
    private weak var window: NSWindow?
    private var originalFrame: NSRect?
    private var originalStyle: NSWindow.StyleMask = []
    private var isFullscreen = false
    private var titleObserver = WindowTitleObserver()
    let defaultBackgroundColor = NSColor.windowBackgroundColor

    @Published var isInFullscreen = false

    private var escapeKeyMonitor: Any?

    @objc private func handleGreenButton() {
        toggle()
    }

    // SwiftUI's declarative nature re-creates the traffic light
    // buttons when re-rendering the window so we may have to
    // re-hook for the green button to function as expected again.
    private func hookGreenButton() {
        guard let window else { return }

        if let zoom = window.standardWindowButton(.zoomButton) {
            zoom.target = self
            zoom.action = #selector(handleGreenButton)
        }
    }

    // In future if we create a new window (other than the main window)
    // make sure to attach this to the window if the window is allowed
    // to go full screen otherwise it is not needed to do so.
    // It basically sets up the custom full screen for that window.
    // I'm also not sure if SwiftUI already inherits this function
    // from the parent window but in such case we don't need to
    // attach this to each window we create.
    func attach(window: NSWindow) {
        self.window = window

        titleObserver.observe(window: window)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.collectionBehavior = [.managed]
        window.styleMask.remove(.fullScreen)

        hookGreenButton()
        installEscapeKeyHandler()
    }

    func toggle() {
        isFullscreen ? exit() : enter()
        isFullscreen.toggle()
        isInFullscreen = isFullscreen
    }

    // When we enter our custom full screen mode the act of
    // going full screen doesn't animate at all therefore
    // we have to implement it ourself explicitly.
    private func animate(
        _ duration: TimeInterval = 0.25,
        _ changes: @escaping () -> Void
    ) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            changes()
        }
    }

    // Hack to make the window feel like it entered full screen.
    // Not sure why we call it a hack because it is an actual
    // full screen if we look at it from Linux/Windows point of
    // view.
    // Who creates a new space when entering full screen anyways,
    // it is terrible UX just follow the industry standard Tim-Apple.
    private func enter() {
        guard let window else { return }

        originalFrame = window.frame
        originalStyle = window.styleMask

        guard let screen = window.screen else { return }

        // Remove all window chrome BEFORE animation
        window.styleMask = [.borderless, .fullSizeContentView]
        window.hasShadow = false
        window.level = .mainMenu
        window.backgroundColor = defaultBackgroundColor

        NSApp.presentationOptions = [.hideMenuBar, .hideDock, .autoHideToolbar]

        // Animate frame change to cover entire screen
        animate {
            window.animator().setFrame(screen.frame, display: true, animate: true)
        }
    }

    private func exit() {
        guard let window,
            let frame = originalFrame
        else { return }

        window.level = .normal
        window.backgroundColor = defaultBackgroundColor
        NSApp.presentationOptions = []

        // Animate back to original frame
        animate {
            window.animator().setFrame(frame, display: true, animate: true)
        }

        // Restore chrome AFTER animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            window.styleMask = self.originalStyle
            window.hasShadow = true

            // SwiftUI's re-creates the title bar
            // Re-hook green button
            self.hookGreenButton()
        }
    }

    // There's no title bar when we are in full screen mode
    // I'm not sure how good of an UX it is but pressing ESC
    // exits full screen mode. Some may not know that we use
    // ESC for this purpose, maybe we should add some indication
    // or a dedicated button in our to-be-implemented navigation
    // bar utilizing our custom navigation stack.
    private func installEscapeKeyHandler() {
        guard escapeKeyMonitor == nil else { return }

        escapeKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            [weak self] event in
            guard let self else { return event }

            // ESC key
            if event.keyCode == 53, self.isFullscreen {
                self.exit()
                self.isFullscreen = false
                return nil  // consume event
            }

            return event
        }
    }

    deinit {
        if let monitor = escapeKeyMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

// Observer class to watch title visibility changes
//
// We do this because when a sidebar is present, the default sidebar toggle
// button is placed in the title bar alongside the traffic-light controls.
// In fullscreen mode this button becomes neither visible nor clickable,
// so it is better to remove it entirely. Doing so also means the sidebar
// must be non-resizable (i.e. fixed/static).
//
// However, when the sidebar button is hidden, the space reserved for it
// is not reclaimed by the layout system. As a result, the window title
// ends up in an awkward position — neither centered nor aligned with the
// traffic lights, but somewhere in between. To avoid this visual glitch,
// we disable the title entirely.
class WindowTitleObserver: NSObject, ObservableObject {
    private var observation: NSKeyValueObservation?
    private weak var window: NSWindow?

    func observe(window: NSWindow) {
        self.window = window
        window.titleVisibility = .hidden

        // Observe changes to titleVisibility
        observation = window.observe(\.titleVisibility, options: [.new]) { window, change in
            if window.titleVisibility != .hidden {
                window.titleVisibility = .hidden
            }
        }
    }

    deinit {
        observation?.invalidate()
    }
}
