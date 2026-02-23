import WidgetKit
import SwiftUI

struct BibleWidget: Widget {
    let kind: String = "BibleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BibleWidgetTimelineProvider()) { entry in
            BibleWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Daily Verse")
        .description("See today's Bible verse at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct BibleLockScreenWidget: Widget {
    let kind: String = "BibleLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BibleWidgetTimelineProvider()) { entry in
            LockScreenWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Daily Verse")
        .description("Today's verse on your lock screen.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct BibleWidgetEntryView: View {
    var entry: BibleWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
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
        nextDayDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date())!
    )
    BibleWidgetEntry(
        date: Date(),
        dayNumber: 1,
        title: "In the Beginning",
        reference: "Genesis 1:1",
        verseText: "In the beginning God created the heavens and the earth.",
        theme: "Creation",
        isCompleted: true,
        isPremium: false,
        nextDayDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date())!
    )
    BibleWidgetEntry(
        date: Date(),
        dayNumber: 1,
        title: "In the Beginning",
        reference: "Genesis 1:1",
        verseText: "In the beginning God created the heavens and the earth.",
        theme: "Creation",
        isCompleted: true,
        isPremium: true,
        nextDayDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date())!
    )
}

#Preview(as: .systemMedium) {
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
