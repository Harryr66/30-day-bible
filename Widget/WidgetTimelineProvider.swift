import WidgetKit
import SwiftUI

struct BibleWidgetEntry: TimelineEntry {
    let date: Date
    let dayNumber: Int
    let title: String
    let reference: String
    let verseText: String
    let theme: String
    let isCompleted: Bool
}

struct BibleWidgetTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> BibleWidgetEntry {
        BibleWidgetEntry(
            date: Date(),
            dayNumber: 1,
            title: "Daily Verse",
            reference: "Loading...",
            verseText: "Your daily verse will appear here.",
            theme: "Faith",
            isCompleted: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (BibleWidgetEntry) -> Void) {
        let entry = createEntry(for: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BibleWidgetEntry>) -> Void) {
        let currentDate = Date()
        let entry = createEntry(for: currentDate)

        // Refresh at midnight
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: currentDate)!)

        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }

    private func createEntry(for date: Date) -> BibleWidgetEntry {
        let today = getTodayReading()
        let verse = getMemoryVerse(for: today)
        let isCompleted = checkIfCompleted(day: today.id)

        return BibleWidgetEntry(
            date: date,
            dayNumber: today.id,
            title: today.title,
            reference: today.memoryVerse,
            verseText: verse,
            theme: today.theme,
            isCompleted: isCompleted
        )
    }

    private func getTodayReading() -> ReadingDay {
        ReadingPlan.today()
    }

    private func getMemoryVerse(for day: ReadingDay) -> String {
        // Return well-known verses for known days
        switch day.id {
        case 1:
            return "In the beginning God created the heavens and the earth."
        case 8:
            return "The LORD is my shepherd; I shall not want."
        case 11:
            return "Trust in the LORD with all your heart, and do not lean on your own understanding."
        case 22:
            return "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life."
        case 28:
            return "So now faith, hope, and love abide, these three; but the greatest of these is love."
        case 29:
            return "But the fruit of the Spirit is love, joy, peace, patience, kindness, goodness, faithfulness, gentleness, self-control."
        case 30:
            return "Put on the whole armor of God, that you may be able to stand against the schemes of the devil."
        default:
            return "Read today's passage in the app."
        }
    }

    private func checkIfCompleted(day: Int) -> Bool {
        // Check shared progress from App Group
        guard let progress = SharedProgress.load() else { return false }
        return progress.completedDays.contains(day)
    }
}

// Simplified SharedProgress for widget (mirrors main app model)
struct SharedProgress: Codable {
    var completedDays: [Int]
    var currentStreak: Int
    var lastReadDate: Date?
    var isPremium: Bool

    static let appGroupIdentifier = "group.com.biblechallenge.shared"

    static func load() -> SharedProgress? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            return nil
        }
        let fileURL = containerURL.appendingPathComponent("progress.json")
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return try? JSONDecoder().decode(SharedProgress.self, from: data)
    }
}

// Simplified ReadingDay for widget
struct ReadingDay: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let theme: String
    let book: String
    let startChapter: Int
    let startVerse: Int
    let endChapter: Int
    let endVerse: Int
    let memoryVerse: String
}

struct ReadingPlan {
    static let days: [ReadingDay] = [
        ReadingDay(id: 1, title: "In the Beginning", theme: "Creation", book: "Genesis", startChapter: 1, startVerse: 1, endChapter: 1, endVerse: 31, memoryVerse: "Genesis 1:1"),
        ReadingDay(id: 2, title: "God's Image", theme: "Humanity", book: "Genesis", startChapter: 2, startVerse: 4, endChapter: 2, endVerse: 25, memoryVerse: "Genesis 1:27"),
        ReadingDay(id: 3, title: "The Fall", theme: "Sin", book: "Genesis", startChapter: 3, startVerse: 1, endChapter: 3, endVerse: 24, memoryVerse: "Genesis 3:15"),
        ReadingDay(id: 4, title: "God's Promise", theme: "Covenant", book: "Genesis", startChapter: 12, startVerse: 1, endChapter: 12, endVerse: 9, memoryVerse: "Genesis 12:2"),
        ReadingDay(id: 5, title: "Faith Tested", theme: "Faith", book: "Genesis", startChapter: 22, startVerse: 1, endChapter: 22, endVerse: 19, memoryVerse: "Genesis 22:8"),
        ReadingDay(id: 6, title: "Deliverance", theme: "Salvation", book: "Exodus", startChapter: 14, startVerse: 10, endChapter: 14, endVerse: 31, memoryVerse: "Exodus 14:14"),
        ReadingDay(id: 7, title: "The Ten Commandments", theme: "Law", book: "Exodus", startChapter: 20, startVerse: 1, endChapter: 20, endVerse: 21, memoryVerse: "Exodus 20:3"),
        ReadingDay(id: 8, title: "The Lord is My Shepherd", theme: "Guidance", book: "Psalms", startChapter: 23, startVerse: 1, endChapter: 23, endVerse: 6, memoryVerse: "Psalms 23:1"),
        ReadingDay(id: 9, title: "A Clean Heart", theme: "Repentance", book: "Psalms", startChapter: 51, startVerse: 1, endChapter: 51, endVerse: 19, memoryVerse: "Psalms 51:10"),
        ReadingDay(id: 10, title: "God's Word", theme: "Scripture", book: "Psalms", startChapter: 119, startVerse: 1, endChapter: 119, endVerse: 16, memoryVerse: "Psalms 119:11"),
        ReadingDay(id: 11, title: "Trust in the Lord", theme: "Trust", book: "Proverbs", startChapter: 3, startVerse: 1, endChapter: 3, endVerse: 12, memoryVerse: "Proverbs 3:5-6"),
        ReadingDay(id: 12, title: "Wisdom's Call", theme: "Wisdom", book: "Proverbs", startChapter: 8, startVerse: 1, endChapter: 8, endVerse: 21, memoryVerse: "Proverbs 9:10"),
        ReadingDay(id: 13, title: "The Suffering Servant", theme: "Prophecy", book: "Isaiah", startChapter: 53, startVerse: 1, endChapter: 53, endVerse: 12, memoryVerse: "Isaiah 53:5"),
        ReadingDay(id: 14, title: "New Heart", theme: "Transformation", book: "Ezekiel", startChapter: 36, startVerse: 22, endChapter: 36, endVerse: 32, memoryVerse: "Ezekiel 36:26"),
        ReadingDay(id: 15, title: "Birth of Jesus", theme: "Incarnation", book: "Luke", startChapter: 2, startVerse: 1, endChapter: 2, endVerse: 20, memoryVerse: "Luke 2:11"),
        ReadingDay(id: 16, title: "The Beatitudes", theme: "Kingdom Living", book: "Matthew", startChapter: 5, startVerse: 1, endChapter: 5, endVerse: 16, memoryVerse: "Matthew 5:16"),
        ReadingDay(id: 17, title: "The Lord's Prayer", theme: "Prayer", book: "Matthew", startChapter: 6, startVerse: 5, endChapter: 6, endVerse: 15, memoryVerse: "Matthew 6:9-13"),
        ReadingDay(id: 18, title: "Do Not Worry", theme: "Peace", book: "Matthew", startChapter: 6, startVerse: 25, endChapter: 6, endVerse: 34, memoryVerse: "Matthew 6:33"),
        ReadingDay(id: 19, title: "The Good Samaritan", theme: "Love", book: "Luke", startChapter: 10, startVerse: 25, endChapter: 10, endVerse: 37, memoryVerse: "Luke 10:27"),
        ReadingDay(id: 20, title: "The Prodigal Son", theme: "Grace", book: "Luke", startChapter: 15, startVerse: 11, endChapter: 15, endVerse: 32, memoryVerse: "Luke 15:24"),
        ReadingDay(id: 21, title: "The Word Made Flesh", theme: "Divinity", book: "John", startChapter: 1, startVerse: 1, endChapter: 1, endVerse: 18, memoryVerse: "John 1:14"),
        ReadingDay(id: 22, title: "Born Again", theme: "New Life", book: "John", startChapter: 3, startVerse: 1, endChapter: 3, endVerse: 21, memoryVerse: "John 3:16"),
        ReadingDay(id: 23, title: "The Good Shepherd", theme: "Protection", book: "John", startChapter: 10, startVerse: 1, endChapter: 10, endVerse: 18, memoryVerse: "John 10:10"),
        ReadingDay(id: 24, title: "The Way, Truth, Life", theme: "Salvation", book: "John", startChapter: 14, startVerse: 1, endChapter: 14, endVerse: 14, memoryVerse: "John 14:6"),
        ReadingDay(id: 25, title: "The Resurrection", theme: "Victory", book: "John", startChapter: 20, startVerse: 1, endChapter: 20, endVerse: 18, memoryVerse: "John 11:25"),
        ReadingDay(id: 26, title: "Justification by Faith", theme: "Righteousness", book: "Romans", startChapter: 5, startVerse: 1, endChapter: 5, endVerse: 11, memoryVerse: "Romans 5:8"),
        ReadingDay(id: 27, title: "More Than Conquerors", theme: "Assurance", book: "Romans", startChapter: 8, startVerse: 28, endChapter: 8, endVerse: 39, memoryVerse: "Romans 8:28"),
        ReadingDay(id: 28, title: "The Love Chapter", theme: "Love", book: "1 Corinthians", startChapter: 13, startVerse: 1, endChapter: 13, endVerse: 13, memoryVerse: "1 Corinthians 13:13"),
        ReadingDay(id: 29, title: "Fruit of the Spirit", theme: "Character", book: "Galatians", startChapter: 5, startVerse: 16, endChapter: 5, endVerse: 26, memoryVerse: "Galatians 5:22-23"),
        ReadingDay(id: 30, title: "Armor of God", theme: "Spiritual Warfare", book: "Ephesians", startChapter: 6, startVerse: 10, endChapter: 6, endVerse: 20, memoryVerse: "Ephesians 6:11")
    ]

    static func dayFor(date: Date) -> ReadingDay {
        let calendar = Calendar.current
        let startOfYear = calendar.startOfDay(for: calendar.date(from: DateComponents(year: calendar.component(.year, from: date), month: 1, day: 1))!)
        let dayOfYear = calendar.dateComponents([.day], from: startOfYear, to: date).day ?? 0
        let dayIndex = dayOfYear % 30
        return days[dayIndex]
    }

    static func today() -> ReadingDay {
        dayFor(date: Date())
    }
}
