import SwiftUI

struct BrowsableItemRow: View {
    let item: BrowsableItem
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.isDirectory ? "folder.fill" : "play.rectangle.fill")
                .foregroundStyle(item.isDirectory ? .blue : .green)
                .font(.title2)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .lineLimit(1)
                    .font(.body)

                if let size = item.displaySize {
                    Text(size)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if item.isDirectory {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isHovered ? Color(nsColor: .controlAccentColor).opacity(0.08) : Color.clear)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
