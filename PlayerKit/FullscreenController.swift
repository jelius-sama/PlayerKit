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

        window.titlebarAppearsTransparent = true
        window.collectionBehavior = [.managed]
        window.styleMask.remove(.fullScreen)

        hookGreenButton()
        installEscapeKeyHandler()
    }

    func toggle() {
        isFullscreen ? exit() : enter()
        isFullscreen.toggle()
    }
    
    private func animate(_ duration: TimeInterval = 0.25,
                         _ changes: @escaping () -> Void) {
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

        // Prepare window state BEFORE animation
        window.styleMask.remove([.titled, .closable, .miniaturizable, .resizable])
        window.styleMask.insert(.borderless)
        window.hasShadow = false
        window.level = .mainMenu

        NSApp.presentationOptions = [.hideMenuBar, .hideDock]

        // Animate frame change
        animate {
            window.animator().setFrame(screen.frame, display: true)
        }
    }

    private func exit() {
        guard let window,
              let frame = originalFrame else { return }

        window.level = .normal
        NSApp.presentationOptions = []

        // Animate back to original frame
        animate {
            window.animator().setFrame(frame, display: true)
            window.styleMask = self.originalStyle
        }

        // Restore chrome AFTER animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            window.styleMask.remove(.borderless)
            window.styleMask.insert([.titled, .closable, .miniaturizable, .resizable])
            window.hasShadow = true

            // Re-hook green button
            self.hookGreenButton()
        }
    }

    private func installEscapeKeyHandler() {
        guard escapeKeyMonitor == nil else { return }

        escapeKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }

            // ESC key
            if event.keyCode == 53, self.isFullscreen {
                self.exit()
                self.isFullscreen = false
                return nil // consume event
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
