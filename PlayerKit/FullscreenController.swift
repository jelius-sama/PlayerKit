//
//  FullscreenController.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 14/01/26.
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

    private func hookGreenButton() {
        guard let window else { return }

        if let zoom = window.standardWindowButton(.zoomButton) {
            zoom.target = self
            zoom.action = #selector(handleGreenButton)
        }
    }

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

            // Re-hook green button
            self.hookGreenButton()
        }
    }

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
