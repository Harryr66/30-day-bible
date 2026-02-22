import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: BibleWidgetEntry

    var body: some View {
        HStack(spacing: 16) {
            // Left side - Day info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Day \(entry.dayNumber)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.indigo)
                        .clipShape(Capsule())

                    if entry.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                }

                Text(entry.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(entry.theme)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(entry.reference)
                    .font(.caption)
                    .foregroundStyle(.indigo)
            }
            .frame(maxWidth: 100)

            // Divider
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(width: 1)

            // Right side - Verse
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "quote.opening")
                    .font(.caption)
                    .foregroundStyle(.indigo.opacity(0.5))

                Text(entry.verseText)
                    .font(.callout)
                    .lineLimit(4)
                    .foregroundStyle(.primary)

                Spacer()

                HStack {
                    Spacer()
                    Text("Read more")
                        .font(.caption2)
                        .foregroundStyle(.indigo)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.indigo)
                }
            }
        }
        .padding()
        .widgetURL(URL(string: "biblechallenge://day/\(entry.dayNumber)"))
    }
}

#Preview(as: .systemMedium) {
    BibleWidget()
} timeline: {
    BibleWidgetEntry(
        date: Date(),
        dayNumber: 22,
        title: "Born Again",
        reference: "John 3:16",
        verseText: "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.",
        theme: "New Life",
        isCompleted: false
    )
}
