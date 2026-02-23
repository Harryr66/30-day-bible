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

                if entry.isCompleted {
                    // Countdown timer
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.caption2)
                        Text("Next: \(entry.countdownText)")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.orange)
                } else {
                    Text(entry.reference)
                        .font(.caption)
                        .foregroundStyle(.indigo)
                }
            }
            .frame(maxWidth: 100)

            // Divider
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(width: 1)

            // Right side - Verse or completion message
            VStack(alignment: .leading, spacing: 8) {
                if entry.isCompleted {
                    // Completed state
                    Spacer()

                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.green)

                        Text("Today's reading complete!")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)

                        if entry.isPremium {
                            HStack(spacing: 4) {
                                Image(systemName: "book.fill")
                                Text("Keep Reading")
                            }
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.indigo)
                            .clipShape(Capsule())
                        } else {
                            Text("New verse in \(entry.countdownText)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Spacer()
                } else {
                    // Normal state - show verse
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
        isCompleted: false,
        isPremium: false,
        nextDayDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date())!
    )
    BibleWidgetEntry(
        date: Date(),
        dayNumber: 22,
        title: "Born Again",
        reference: "John 3:16",
        verseText: "For God so loved the world, that he gave his only Son.",
        theme: "New Life",
        isCompleted: true,
        isPremium: false,
        nextDayDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date())!
    )
    BibleWidgetEntry(
        date: Date(),
        dayNumber: 22,
        title: "Born Again",
        reference: "John 3:16",
        verseText: "For God so loved the world, that he gave his only Son.",
        theme: "New Life",
        isCompleted: true,
        isPremium: true,
        nextDayDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date())!
    )
}
