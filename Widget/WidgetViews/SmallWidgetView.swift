import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: BibleWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text("Day \(entry.dayNumber)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.indigo)
                    .clipShape(Capsule())

                Spacer()

                if entry.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                }
            }

            Spacer()

            // Verse preview
            Text(entry.verseText)
                .font(.caption)
                .lineLimit(3)
                .foregroundStyle(.primary)

            Spacer()

            // Reference
            Text(entry.reference)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .widgetURL(URL(string: "biblechallenge://day/\(entry.dayNumber)"))
    }
}

#Preview(as: .systemSmall) {
    BibleWidget()
} timeline: {
    BibleWidgetEntry(
        date: Date(),
        dayNumber: 1,
        title: "In the Beginning",
        reference: "Genesis 1:1",
        verseText: "In the beginning God created the heavens and the earth.",
        theme: "Creation",
        isCompleted: false
    )
    BibleWidgetEntry(
        date: Date(),
        dayNumber: 22,
        title: "Born Again",
        reference: "John 3:16",
        verseText: "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.",
        theme: "New Life",
        isCompleted: true
    )
}
