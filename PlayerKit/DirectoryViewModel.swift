//
//  DirectoryViewModel.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 15/01/26.
//

import Combine
import Foundation

class DirectoryViewModel: ObservableObject {
    @Published var savedDirectories: [SavedDirectory] = []
    @Published var currentDirectory: URL?
    @Published var navigationStack: [URL] = []
    @Published var items: [BrowsableItem] = []
    @Published var isScanning = false
    @Published var selectedVideo: URL?

    private var currentAccessedURL: URL?

    init() {
        loadDirectories()
    }

    func loadDirectories() {
        savedDirectories = DatabaseManager.shared.getAllDirectories()
        print("Loaded \(savedDirectories.count) saved directories")
    }

    func addDirectory(url: URL) {
        print("Adding directory: \(url.path)")

        // Create security-scoped bookmark
        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )

            if DatabaseManager.shared.addDirectory(path: url.path, bookmark: bookmarkData) {
                loadDirectories()

                // Navigate to the newly added directory
                if let newDir = savedDirectories.first(where: { $0.path == url.path }) {
                    navigateToSavedDirectory(newDir)
                }
            }
        } catch {
            print("Failed to create bookmark: \(error.localizedDescription)")
        }
    }

    func removeDirectory(_ directory: SavedDirectory) {
        if DatabaseManager.shared.removeDirectory(path: directory.path) {
            loadDirectories()
            if let current = currentDirectory, current.path == directory.path {
                navigateToHome()
            }
        }
    }

    func navigateToSavedDirectory(_ directory: SavedDirectory) {
        print("Attempting to navigate to saved directory: \(directory.path)")

        guard let url = directory.resolveURL() else {
            print("Could not resolve URL for directory")
            return
        }

        // Stop accessing previous URL if any
        if let previousURL = currentAccessedURL {
            previousURL.stopAccessingSecurityScopedResource()
            print("Stopped accessing: \(previousURL.path)")
        }

        // Start accessing security-scoped resource
        if url.startAccessingSecurityScopedResource() {
            print("Successfully started accessing: \(url.path)")
            currentAccessedURL = url
            navigateToDirectory(url)
        } else {
            print("Failed to start accessing: \(url.path)")
        }
    }

    func navigateToDirectory(_ url: URL) {
        print("Navigating to: \(url.path)")

        if currentDirectory != url {
            navigationStack.append(url)
        }
        currentDirectory = url
        scanCurrentDirectory()
    }

    func navigateBack() {
        guard navigationStack.count > 1 else {
            navigateToHome()
            return
        }

        navigationStack.removeLast()
        if let previousDir = navigationStack.last {
            currentDirectory = previousDir
            scanCurrentDirectory()
        }
    }

    func navigateToHome() {
        // Stop accessing the security-scoped resource
        if let accessedURL = currentAccessedURL {
            accessedURL.stopAccessingSecurityScopedResource()
            print("Stopped accessing: \(accessedURL.path)")
            currentAccessedURL = nil
        }

        navigationStack.removeAll()
        currentDirectory = nil
        items = []
    }

    func openItem(_ item: BrowsableItem) {
        if item.isDirectory {
            navigateToDirectory(item.url)
        } else if item.isVideo {
            // print("TODO: Implement video player for: \(item.url.path)")
            selectedVideo = item.url
        }
    }

    private func scanCurrentDirectory() {
        guard let currentDir = currentDirectory else {
            items = []
            return
        }

        isScanning = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let scannedItems = FileScanner.scanDirectoryShallow(currentDir)

            DispatchQueue.main.async {
                self?.items = scannedItems
                self?.isScanning = false
                print("Found \(scannedItems.count) items in \(currentDir.lastPathComponent)")
            }
        }
    }

    func getCurrentDirectoryName() -> String {
        currentDirectory?.lastPathComponent ?? "PlayerKit"
    }

    func canNavigateBack() -> Bool {
        return !navigationStack.isEmpty
    }

    deinit {
        if let accessedURL = currentAccessedURL {
            accessedURL.stopAccessingSecurityScopedResource()
        }
    }
}
