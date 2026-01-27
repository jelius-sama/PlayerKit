// SPDX-License-Identifier: See LICENSE
//
// DirectoryView.swift
// PlayerKit
//
// Copyright (c) 2026 Jelius <personal@jelius.dev>
//
// This file is part of PlayerKit.
// See the LICENSE file in the project root for license information.
//

import SwiftUI

struct DirectoryGridView: View {
    let directories: [LibraryDirectory]

    @EnvironmentObject private var router: PlayerKitNavigationRouter

    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(directories) { directory in
                    Button {
                        let url = URL(fileURLWithPath: directory.path)

                        router.push(
                            DirectoryBrowserView(
                                directoryURL: url,
                                bookmark: directory.bookmark
                            )
                        )
                    } label: {
                        DirectoryCardView(directory: directory)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
}

struct DirectoryBrowserView: View, Identifiable {
    let id = UUID()
    let directoryURL: URL
    let bookmark: Data

    @EnvironmentObject private var router: PlayerKitNavigationRouter
    @State private var items: [FileSystemItem] = []

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 160), spacing: 16)],
                spacing: 20
            ) {
                ForEach(items) { item in
                    Button {
                        handleSelection(item)
                    } label: {
                        FileGridItemView(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            load()
        }
    }

    private func load() {
        do {
            let root = try BookmarkManager.resolveBookmark(bookmark)
            items = DirectoryEnumerator.contents(of: directoryURL)
            BookmarkManager.stopAccessing(root)
        } catch {
            items = []
        }
    }

    private func handleSelection(_ item: FileSystemItem) {
        guard item.type == .directory else {
            // video playback later
            return
        }

        router.push(
            DirectoryBrowserView(
                directoryURL: item.url,
                bookmark: bookmark
            )
        )
    }
}

struct DirectoryCardView: View {
    let directory: LibraryDirectory

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)

                Image(systemName: "folder.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
            }
            .aspectRatio(2.0 / 3.0, contentMode: .fit)

            Text(directoryName)
                .font(.subheadline)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var directoryName: String {
        URL(fileURLWithPath: directory.path)
            .lastPathComponent
    }
}
