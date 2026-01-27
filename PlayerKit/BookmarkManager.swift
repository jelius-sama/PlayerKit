// SPDX-License-Identifier: See LICENSE
//
// BookmarkManager.swift
// PlayerKit
//
// Copyright (c) 2026 Jelius <personal@jelius.dev>
//
// This file is part of PlayerKit.
// See the LICENSE file in the project root for license information.
//

import Foundation

enum BookmarkError: Error {
    case creationFailed
    case resolutionFailed
}

final class BookmarkManager {
    // Create a security-scoped bookmark for a directory URL
    static func createBookmark(for url: URL) throws -> Data {
        do {
            return try url.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
        } catch {
            throw BookmarkError.creationFailed
        }
    }

    // Resolve a bookmark and start accessing the resource
    static func resolveBookmark(_ data: Data) throws -> URL {
        var isStale = false

        let url = try URL(
            resolvingBookmarkData: data,
            options: [.withSecurityScope],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )

        if isStale {
            // We could regenerate the bookmark here later
            // For now, just continue with the resolved URL
        }

        guard url.startAccessingSecurityScopedResource() else {
            throw BookmarkError.resolutionFailed
        }

        return url
    }

    // Stop accessing a previously resolved bookmark
    static func stopAccessing(_ url: URL) {
        url.stopAccessingSecurityScopedResource()
    }
}
