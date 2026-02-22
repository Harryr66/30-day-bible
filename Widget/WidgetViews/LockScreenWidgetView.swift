import SwiftUI
import WidgetKit

struct LockScreenWidgetView: View {
    let entry: BibleWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryRectangular:
            rectangularView
        case .accessoryInline:
            inlineView
        default:
            circularView
        }
    }

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 2) {
                Image(systemName: "book.fill")
                    .font(.system(size: 14))

                Text("\(entry.dayNumber)")
                    .font(.system(size: 16, weight: .bold))

                if entry.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8))
                }
            }
        }
        .widgetURL(URL(string: "biblechallenge://day/\(entry.dayNumber)"))
    }

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "book.fill")
                    .font(.caption2)
                Text("Day \(entry.dayNumber)")
                    .font(.caption2)
                    .fontWeight(.semibold)

                Spacer()

                if entry.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                }
            }

            Text(truncatedVerse)
                .font(.caption)
                .lineLimit(2)

            Text(entry.reference)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .widgetURL(URL(string: "biblechallenge://day/\(entry.dayNumber)"))
    }

    private var inlineView: some View {
        HStack {
            Image(systemName: "book.fill")
            Text("Day \(entry.dayNumber): \(entry.reference)")
        }
        .widgetURL(URL(string: "biblechallenge://day/\(entry.dayNumber)"))
    }

    private var truncatedVerse: String {
        if entry.verseText.count > 60 {
            return String(entry.verseText.prefix(57)) + "..."
        }
        return entry.verseText
    }
}

#Preview(as: .accessoryCircular) {
    BibleLockScreenWidget()
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
}

#Preview(as: .accessoryRectangular) {
    BibleLockScreenWidget()
} timeline: {
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

#Preview(as: .accessoryInline) {
    BibleLockScreenWidget()
} timeline: {
    BibleWidgetEntry(
        date: Date(),
        dayNumber: 8,
        title: "The Lord is My Shepherd",
        reference: "Psalm 23:1",
        verseText: "The LORD is my shepherd; I shall not want.",
        theme: "Guidance",
        isCompleted: false
    )
}
