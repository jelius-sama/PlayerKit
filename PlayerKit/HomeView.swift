//
//  HomeView.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 14/01/26.
//

import SwiftUI
import AppKit

struct HomeView: View {
    @EnvironmentObject private var fullscreen: FullscreenController

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "film.stack")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            Text("Welcome to PlayerKit")
                .font(.largeTitle)
                .bold()

            Text("Add a folder to start watching your videos.")
                .foregroundStyle(.secondary)

            Button {
                openFolderPicker()
            } label: {
                Label("Add Local Folder", systemImage: "folder.badge.plus")
                    .font(.headline)
            }
            .keyboardShortcut("o", modifiers: [.command])
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func openFolderPicker() {
        guard let window = NSApp.keyWindow else { return }

        let panel = NSOpenPanel()
        panel.title = "Select a Folder"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        // Present as a sheet attached to the window
        panel.beginSheetModal(for: window) { response in
            if response == .OK, let url = panel.url {
                print("Selected folder path:")
                print(url.path)
            }
        }
    }
}
