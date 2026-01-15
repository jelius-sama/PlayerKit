//
//  WindowManager.swift
//  PlayerKit
//
//  Manages video player windows
//

import AppKit

class WindowManager {
    static let shared = WindowManager()
    private var windows: [NSWindow] = []

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowWillClose(_:)),
            name: NSWindow.willCloseNotification,
            object: nil
        )
    }

    func registerWindow(_ window: NSWindow) {
        windows.append(window)
    }

    @objc private func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            windows.removeAll { $0 == window }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
