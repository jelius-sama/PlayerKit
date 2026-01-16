//
//  Models.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 15/01/26.
//

import Foundation

struct SavedDirectory: Identifiable, Equatable {
    let id: Int
    let path: String
    let bookmarkData: Data
    let addedDate: Date

    var displayName: String {
        URL(fileURLWithPath: path).lastPathComponent
    }

    // Remove the old `url` property and add this method instead:
    func resolveURL() -> URL? {
        var isStale = false
        do {
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )

            if isStale {
                print("Bookmark is stale for: \(path)")
            }

            return url
        } catch {
            print("Failed to resolve bookmark for \(path): \(error.localizedDescription)")
            return nil
        }
    }

    static func == (lhs: SavedDirectory, rhs: SavedDirectory) -> Bool {
        lhs.id == rhs.id
    }
}

struct VideoFile: Identifiable, Equatable {
    let id = UUID()
    let url: URL
    let name: String
    let size: Int64

    var displaySize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    static func == (lhs: VideoFile, rhs: VideoFile) -> Bool {
        lhs.url == rhs.url
    }
}

struct BrowsableItem: Identifiable, Equatable, Hashable {
    let id = UUID()
    let url: URL
    let name: String
    let isDirectory: Bool
    let isVideo: Bool
    let size: Int64?
    
    var displaySize: String? {
        guard let size = size else { return nil }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    static func == (lhs: BrowsableItem, rhs: BrowsableItem) -> Bool {
        lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}
