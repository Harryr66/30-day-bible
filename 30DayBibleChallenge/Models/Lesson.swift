import Foundation

/// Categories for organizing Bible lessons
enum LessonCategory: String, Codable, CaseIterable, Identifiable {
    case foundation = "Foundation"
    case gospels = "Gospels"
    case epistles = "Epistles"
    case prophets = "Prophets"
    case wisdom = "Wisdom"
    case history = "History"
    case psalms = "Psalms"
    case revelation = "Revelation"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .foundation: return "building.columns.fill"
        case .gospels: return "book.fill"
        case .epistles: return "envelope.fill"
        case .prophets: return "megaphone.fill"
        case .wisdom: return "lightbulb.fill"
        case .history: return "clock.fill"
        case .psalms: return "music.note"
        case .revelation: return "sparkles"
        }
    }

    var color: String {
        switch self {
        case .foundation: return "appBrown"
        case .gospels: return "appBlue"
        case .epistles: return "appPurple"
        case .prophets: return "appOrange"
        case .wisdom: return "appYellow"
        case .history: return "appGreen"
        case .psalms: return "appTeal"
        case .revelation: return "appRed"
        }
    }

    var description: String {
        switch self {
        case .foundation: return "Core stories and concepts"
        case .gospels: return "The life and teachings of Jesus"
        case .epistles: return "Letters to early churches"
        case .prophets: return "Messages from God's prophets"
        case .wisdom: return "Proverbs, wisdom, and guidance"
        case .history: return "Historical narratives"
        case .psalms: return "Songs, prayers, and poetry"
        case .revelation: return "End times and prophecy"
        }
    }
}

/// Difficulty levels for lessons
enum LessonDifficulty: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var icon: String {
        switch self {
        case .beginner: return "1.circle.fill"
        case .intermediate: return "2.circle.fill"
        case .advanced: return "3.circle.fill"
        }
    }

    var estimatedMinutes: Int {
        switch self {
        case .beginner: return 3
        case .intermediate: return 5
        case .advanced: return 8
        }
    }
}

/// A dynamic lesson that can be loaded from the Bible API
struct Lesson: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let theme: String
    let book: String
    let startChapter: Int
    let startVerse: Int
    let endChapter: Int
    let endVerse: Int
    let memoryVerseReference: String
    let category: LessonCategory
    let difficulty: LessonDifficulty
    let description: String?
    let tags: [String]

    var reference: String {
        if startChapter == endChapter {
            if startVerse == endVerse {
                return "\(book) \(startChapter):\(startVerse)"
            }
            return "\(book) \(startChapter):\(startVerse)-\(endVerse)"
        }
        return "\(book) \(startChapter):\(startVerse)-\(endChapter):\(endVerse)"
    }

    var estimatedMinutes: Int {
        let verseCount = estimatedVerseCount
        let baseTime = difficulty.estimatedMinutes
        return max(baseTime, verseCount / 3 + 1)
    }

    private var estimatedVerseCount: Int {
        if startChapter == endChapter {
            return endVerse - startVerse + 1
        }
        // Rough estimate for multi-chapter passages
        return (endChapter - startChapter + 1) * 15
    }

    init(
        id: String? = nil,
        title: String,
        theme: String,
        book: String,
        startChapter: Int,
        startVerse: Int,
        endChapter: Int,
        endVerse: Int,
        memoryVerseReference: String,
        category: LessonCategory,
        difficulty: LessonDifficulty = .beginner,
        description: String? = nil,
        tags: [String] = []
    ) {
        self.id = id ?? "\(book.lowercased().replacingOccurrences(of: " ", with: "_"))_\(startChapter)_\(startVerse)"
        self.title = title
        self.theme = theme
        self.book = book
        self.startChapter = startChapter
        self.startVerse = startVerse
        self.endChapter = endChapter
        self.endVerse = endVerse
        self.memoryVerseReference = memoryVerseReference
        self.category = category
        self.difficulty = difficulty
        self.description = description
        self.tags = tags
    }

    /// Create a Lesson from a ReadingDay (for backwards compatibility)
    static func from(readingDay: ReadingDay) -> Lesson {
        let category = categoryFor(book: readingDay.book)
        return Lesson(
            id: "day_\(readingDay.id)",
            title: readingDay.title,
            theme: readingDay.theme,
            book: readingDay.book,
            startChapter: readingDay.startChapter,
            startVerse: readingDay.startVerse,
            endChapter: readingDay.endChapter,
            endVerse: readingDay.endVerse,
            memoryVerseReference: readingDay.memoryVerse,
            category: category,
            difficulty: .beginner
        )
    }

    private static func categoryFor(book: String) -> LessonCategory {
        switch book {
        case "Genesis", "Exodus":
            return .foundation
        case "Matthew", "Mark", "Luke", "John":
            return .gospels
        case "Romans", "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians",
             "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians",
             "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews", "James",
             "1 Peter", "2 Peter", "1 John", "2 John", "3 John", "Jude":
            return .epistles
        case "Isaiah", "Jeremiah", "Ezekiel", "Daniel", "Hosea", "Joel", "Amos",
             "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk", "Zephaniah",
             "Haggai", "Zechariah", "Malachi":
            return .prophets
        case "Proverbs", "Ecclesiastes", "Job", "Song of Solomon":
            return .wisdom
        case "Psalms", "Lamentations":
            return .psalms
        case "Revelation":
            return .revelation
        default:
            return .history
        }
    }
}
