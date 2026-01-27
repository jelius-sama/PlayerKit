// SPDX-License-Identifier: See LICENSE
//
// FileGridItemView.swift
// PlayerKit
//
// Copyright (c) 2026 Jelius <personal@jelius.dev>
//
// This file is part of PlayerKit.
// See the LICENSE file in the project root for license information.
//

import AVFoundation
import AppKit
import Foundation
import SwiftUI

enum FileSystemItemType {
    case directory
    case video
}

struct FileSystemItem: Identifiable {
    let id = UUID()
    let url: URL
    let type: FileSystemItemType
}

struct FileGridItemView: View {
    let item: FileSystemItem

    @State private var thumbnail: NSImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)

                if let thumbnail {
                    Image(nsImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .cornerRadius(12)
                } else {
                    Image(systemName: fallbackIcon)
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                }
            }
            .aspectRatio(2.0 / 3.0, contentMode: .fit)
            .onAppear {
                loadThumbnailIfNeeded()
            }

            Text(item.url.lastPathComponent)
                .font(.subheadline)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var fallbackIcon: String {
        switch item.type {
        case .directory:
            return "folder.fill"
        case .video:
            return "film.fill"
        }
    }

    private func loadThumbnailIfNeeded() {
        guard item.type == .video, thumbnail == nil else { return }

        Task { @MainActor in
            let image = await generateThumbnail(
                for: item.url,
                size: CGSize(width: 400, height: 600)
            )

            self.thumbnail = image
        }
    }

    private func generateThumbnail(
        for url: URL,
        size: CGSize
    ) async -> NSImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)

        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = size

        let time = CMTime(seconds: 1, preferredTimescale: 600)

        do {
            let (cgImage, _) = try await generator.image(at: time)
            return NSImage(cgImage: cgImage, size: size)
        } catch {
            return nil
        }
    }
}
