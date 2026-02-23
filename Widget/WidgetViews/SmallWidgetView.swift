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

            if entry.isCompleted {
                // Show countdown or keep reading for completed
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text("Completed!")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                    }

                    if entry.isPremium {
                        // Pro members: Keep reading option
                        HStack(spacing: 4) {
                            Image(systemName: "book.fill")
                                .font(.caption2)
                            Text("Keep Reading")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.indigo)
                    } else {
                        // Countdown timer
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption2)
                            Text("Next in \(entry.countdownText)")
                                .font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            } else {
                // Verse preview
                Text(entry.verseText)
                    .font(.caption)
                    .lineLimit(3)
                    .foregroundStyle(.primary)
            }

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
        isCompleted: false,
        isPremium: false,
        nextDayDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date())!,
        remainingSessions: 5,
        timeUntilNextSession: nil
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
        nextDayDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date())!,
        remainingSessions: 0,
        timeUntilNextSession: 3600
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
        nextDayDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date())!,
        remainingSessions: Int.max,
        timeUntilNextSession: nil
    )
}
