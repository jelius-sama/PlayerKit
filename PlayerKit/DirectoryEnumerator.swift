// SPDX-License-Identifier: See LICENSE
//
// DirectoryEnumerator.swift
// PlayerKit
//
// Copyright (c) 2026 Jelius <personal@jelius.dev>
//
// This file is part of PlayerKit.
// See the LICENSE file in the project root for license information.
//

import AVFoundation
import Foundation
import UniformTypeIdentifiers

enum DirectoryEnumerator {
    static func isVideoFile(url: URL) -> Bool {
        guard let type = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType else {
            return false
        }

        return type.conforms(to: .movie)
    }

    static func contents(of url: URL) -> [FileSystemItem] {
        let keys: [URLResourceKey] = [
            .isDirectoryKey,
            .isRegularFileKey,
        ]

        guard
            let enumerator = FileManager.default.enumerator(
                at: url,
                includingPropertiesForKeys: keys,
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            )
        else {
            return []
        }

        var items: [FileSystemItem] = []

        for case let fileURL as URL in enumerator {
            guard let values = try? fileURL.resourceValues(forKeys: Set(keys)) else {
                continue
            }

            if values.isDirectory == true {
                items.append(
                    FileSystemItem(url: fileURL, type: .directory)
                )
                enumerator.skipDescendants()
            } else if values.isRegularFile == true,
                isVideoFile(url: fileURL)
            {
                items.append(
                    FileSystemItem(url: fileURL, type: .video)
                )
            }
        }

        return items.sorted {
            $0.url.lastPathComponent.lowercased()
                < $1.url.lastPathComponent.lowercased()
        }
    }
}
