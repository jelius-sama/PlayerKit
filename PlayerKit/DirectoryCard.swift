import SwiftUI

struct DirectoryCard: View {
    let directory: SavedDirectory
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "folder.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(directory.displayName)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(directory.path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isHovered
                        ? Color(nsColor: .controlAccentColor).opacity(0.1)
                        : Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color(nsColor: .separatorColor), lineWidth: 1)
        )
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
