//
//  FileScanner.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 15/01/26.
//

import Foundation

class FileScanner {
    static let videoExtensions: Set<String> = [
        "mp4", "mov", "m4v", "avi", "mkv", "wmv", "flv", "webm",
        "mpg", "mpeg", "3gp", "ts", "m2ts", "mts",
    ]

    static func isVideoFile(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return videoExtensions.contains(ext)
    }

    static func scanDirectoryShallow(_ url: URL) -> [BrowsableItem] {
        var items: [BrowsableItem] = []
        let fileManager = FileManager.default

        guard
            let contents = try? fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey, .isRegularFileKey, .fileSizeKey],
                options: [.skipsHiddenFiles]
            )
        else {
            print("Failed to read directory contents at: \(url.path)")
            return items
        }

        for fileURL in contents {
            guard
                let resourceValues = try? fileURL.resourceValues(
                    forKeys: [.isDirectoryKey, .isRegularFileKey, .fileSizeKey]
                )
            else { continue }

            let isDirectory = resourceValues.isDirectory ?? false
            let isRegularFile = resourceValues.isRegularFile ?? false

            if isDirectory {
                // Check if directory contains any videos
                if hasVideoFiles(in: fileURL) {
                    items.append(
                        BrowsableItem(
                            url: fileURL,
                            name: fileURL.lastPathComponent,
                            isDirectory: true,
                            isVideo: false,
                            size: nil
                        ))
                }
            } else if isRegularFile && isVideoFile(fileURL) {
                let size = resourceValues.fileSize ?? 0
                items.append(
                    BrowsableItem(
                        url: fileURL,
                        name: fileURL.lastPathComponent,
                        isDirectory: false,
                        isVideo: true,
                        size: Int64(size)
                    ))
            }
        }

        return items.sorted { item1, item2 in
            if item1.isDirectory != item2.isDirectory {
                return item1.isDirectory
            }
            return item1.name.localizedStandardCompare(item2.name) == .orderedAscending
        }
    }

    static func hasVideoFiles(in url: URL) -> Bool {
        let fileManager = FileManager.default

        guard
            let enumerator = fileManager.enumerator(
                at: url,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )
        else { return false }

        for case let fileURL as URL in enumerator {
            if isVideoFile(fileURL) {
                return true
            }
        }

        return false
    }
}
