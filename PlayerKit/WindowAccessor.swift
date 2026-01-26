//
//  WindowAccessor.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 14/01/26.
//

import AppKit
import SwiftUI

struct WindowAccessor: NSViewRepresentable {
    let callback: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                callback(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
