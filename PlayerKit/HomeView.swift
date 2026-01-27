// SPDX-License-Identifier: See LICENSE
//
// HomeView.swift
// PlayerKit
//
// Copyright (c) 2026 Jelius <personal@jelius.dev>
//
// This file is part of PlayerKit.
// See the LICENSE file in the project root for license information.
//

import SwiftUI

struct HomeView: View {
    @State private var directories: [LibraryDirectory] = []

    var body: some View {
        Group {
            if directories.isEmpty {
                Button("Add Directory") {
                    pickDirectories { urls in
                        importDirectories(urls: urls)
                        reload()
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                DirectoryGridView(directories: directories)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            reload()
        }
    }

    private func reload() {
        directories = Database.shared.fetchDirectories()
    }

    private func pickDirectories(
        completion: @escaping ([URL]) -> Void
    ) {
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.title = "Select Directory"
            panel.prompt = "Add"
            panel.canChooseFiles = false
            panel.canChooseDirectories = true
            panel.allowsMultipleSelection = true
            panel.resolvesAliases = true

            panel.begin { response in
                if response == .OK {
                    completion(panel.urls)
                } else {
                    completion([])
                }
            }
        }
    }

    private func importDirectories(urls: [URL]) {
        for url in urls {
            guard url.hasDirectoryPath else { continue }

            do {
                let bookmark = try BookmarkManager.createBookmark(for: url)

                Database.shared.insertDirectory(
                    path: url.path,
                    bookmark: bookmark
                )
            } catch {
                // Ignore failed directories for now
                // Later we can surface errors to UI
                continue
            }
        }
    }
}
