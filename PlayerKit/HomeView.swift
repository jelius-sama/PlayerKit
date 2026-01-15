//
//  HomeView.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 14/01/26.
//

import AppKit
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var fullscreen: FullscreenController
    @StateObject private var viewModel = DirectoryViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 12) {
                if viewModel.canNavigateBack() {
                    Button {
                        viewModel.navigateBack()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.borderless)
                    .help("Back")
                }

                if viewModel.currentDirectory != nil {
                    Button {
                        viewModel.navigateToHome()
                    } label: {
                        Image(systemName: "house")
                    }
                    .buttonStyle(.borderless)
                    .help("Home")
                }

                Text(viewModel.getCurrentDirectoryName())
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                if viewModel.isScanning {
                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(width: 20, height: 20)
                }

                Button {
                    openFolderPicker()
                } label: {
                    Label("Add Folder", systemImage: "folder.badge.plus")
                }
                .keyboardShortcut("o", modifiers: [.command])
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // Main content
            if viewModel.currentDirectory == nil {
                homeView
            } else {
                browserView
            }
        }
        .onChange(of: viewModel.selectedVideo) { _, newVideo in
            if let videoURL = newVideo {
                openVideoPlayerWindow(videoURL: videoURL)
                viewModel.selectedVideo = nil  // Reset immediately
            }
        }
    }

    private var homeView: some View {
        Group {
            if viewModel.savedDirectories.isEmpty {
                emptyStateView
            } else {
                savedDirectoriesView
            }
        }
    }

    private var emptyStateView: some View {
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

    private var savedDirectoriesView: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 180, maximum: 250), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(viewModel.savedDirectories) { directory in
                    DirectoryCard(directory: directory)
                        .onTapGesture {
                            viewModel.navigateToSavedDirectory(directory)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.removeDirectory(directory)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                }
            }
            .padding()
        }
    }

    private var browserView: some View {
        Group {
            if viewModel.items.isEmpty && !viewModel.isScanning {
                VStack(spacing: 16) {
                    Image(systemName: "film.stack")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No video files found in this folder")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(viewModel.items) { item in
                            BrowsableItemRow(item: item)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.openItem(item)
                                }
                        }
                    }
                }
            }
        }
    }

    private func openFolderPicker() {
        guard let window = NSApp.keyWindow else { return }

        let panel = NSOpenPanel()
        panel.title = "Select a Folder"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Add Folder"

        panel.beginSheetModal(for: window) { response in
            if response == .OK, let url = panel.url {
                viewModel.addDirectory(url: url)
            }
        }
    }

    private func openVideoPlayerWindow(videoURL: URL) {
        let playerView = VideoPlayerView(videoURL: videoURL)
        let hostingController = NSHostingController(rootView: playerView)

        let window = NSWindow(contentViewController: hostingController)
        window.title = videoURL.lastPathComponent
        window.setContentSize(NSSize(width: 1280, height: 720))
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.center()
        window.makeKeyAndOrderFront(nil)

        // Keep a strong reference to prevent deallocation
        WindowManager.shared.registerWindow(window)
    }
}
