import Foundation

/// Organizes curated and dynamic lessons
struct LessonCatalog {
    /// Curated lessons from the 30-day reading plan
    static var curatedLessons: [Lesson] {
        ReadingPlan.days.map { Lesson.from(readingDay: $0) }
    }

    /// Featured "Today's Pick" lesson
    static func todaysPick() -> Lesson {
        let today = ReadingPlan.today()
        return Lesson.from(readingDay: today)
    }

    /// Get lessons by category
    static func lessons(for category: LessonCategory) -> [Lesson] {
        curatedLessons.filter { $0.category == category }
    }

    /// Search lessons by title, theme, or book
    static func search(query: String) -> [Lesson] {
        guard !query.isEmpty else { return curatedLessons }
        let lowercased = query.lowercased()
        return curatedLessons.filter { lesson in
            lesson.title.lowercased().contains(lowercased) ||
            lesson.theme.lowercased().contains(lowercased) ||
            lesson.book.lowercased().contains(lowercased) ||
            lesson.tags.contains { $0.lowercased().contains(lowercased) }
        }
    }

    /// Get random lesson from a category (for "discover" feature)
    static func randomLesson(from category: LessonCategory? = nil) -> Lesson? {
        let pool = category.map { lessons(for: $0) } ?? curatedLessons
        return pool.randomElement()
    }

    /// Additional curated lessons for the Explore feature
    /// These extend beyond the 30-day plan with popular passages
    static var extendedLessons: [Lesson] {
        [
            // Psalms
            Lesson(
                title: "The Creator's Majesty",
                theme: "God's Glory",
                book: "Psalms",
                startChapter: 19,
                startVerse: 1,
                endChapter: 19,
                endVerse: 14,
                memoryVerseReference: "Psalms 19:1",
                category: .psalms,
                difficulty: .beginner,
                description: "The heavens declare God's glory",
                tags: ["creation", "nature", "praise"]
            ),
            Lesson(
                title: "A Song of Deliverance",
                theme: "Protection",
                book: "Psalms",
                startChapter: 91,
                startVerse: 1,
                endChapter: 91,
                endVerse: 16,
                memoryVerseReference: "Psalms 91:1-2",
                category: .psalms,
                difficulty: .beginner,
                description: "Finding refuge in God",
                tags: ["protection", "trust", "safety"]
            ),
            Lesson(
                title: "Give Thanks",
                theme: "Gratitude",
                book: "Psalms",
                startChapter: 100,
                startVerse: 1,
                endChapter: 100,
                endVerse: 5,
                memoryVerseReference: "Psalms 100:4",
                category: .psalms,
                difficulty: .beginner,
                description: "A psalm of thanksgiving",
                tags: ["thanksgiving", "praise", "joy"]
            ),

            // Wisdom
            Lesson(
                title: "The Virtuous Woman",
                theme: "Character",
                book: "Proverbs",
                startChapter: 31,
                startVerse: 10,
                endChapter: 31,
                endVerse: 31,
                memoryVerseReference: "Proverbs 31:30",
                category: .wisdom,
                difficulty: .intermediate,
                description: "Portrait of noble character",
                tags: ["character", "virtue", "women"]
            ),
            Lesson(
                title: "A Time for Everything",
                theme: "Seasons",
                book: "Ecclesiastes",
                startChapter: 3,
                startVerse: 1,
                endChapter: 3,
                endVerse: 15,
                memoryVerseReference: "Ecclesiastes 3:1",
                category: .wisdom,
                difficulty: .beginner,
                description: "Understanding life's seasons",
                tags: ["time", "seasons", "purpose"]
            ),

            // Prophets
            Lesson(
                title: "Here Am I, Send Me",
                theme: "Calling",
                book: "Isaiah",
                startChapter: 6,
                startVerse: 1,
                endChapter: 6,
                endVerse: 13,
                memoryVerseReference: "Isaiah 6:8",
                category: .prophets,
                difficulty: .intermediate,
                description: "Isaiah's vision and commission",
                tags: ["calling", "vision", "service"]
            ),
            Lesson(
                title: "Comfort My People",
                theme: "Hope",
                book: "Isaiah",
                startChapter: 40,
                startVerse: 1,
                endChapter: 40,
                endVerse: 31,
                memoryVerseReference: "Isaiah 40:31",
                category: .prophets,
                difficulty: .intermediate,
                description: "Renewed strength in waiting",
                tags: ["hope", "strength", "waiting"]
            ),

            // Gospels
            Lesson(
                title: "The Great Commission",
                theme: "Mission",
                book: "Matthew",
                startChapter: 28,
                startVerse: 16,
                endChapter: 28,
                endVerse: 20,
                memoryVerseReference: "Matthew 28:19-20",
                category: .gospels,
                difficulty: .beginner,
                description: "Jesus' final command",
                tags: ["mission", "disciples", "evangelism"]
            ),
            Lesson(
                title: "The Vine and Branches",
                theme: "Abiding",
                book: "John",
                startChapter: 15,
                startVerse: 1,
                endChapter: 15,
                endVerse: 17,
                memoryVerseReference: "John 15:5",
                category: .gospels,
                difficulty: .beginner,
                description: "Staying connected to Christ",
                tags: ["abiding", "fruit", "love"]
            ),

            // Epistles
            Lesson(
                title: "The Full Armor",
                theme: "Spiritual Warfare",
                book: "Ephesians",
                startChapter: 6,
                startVerse: 10,
                endChapter: 6,
                endVerse: 20,
                memoryVerseReference: "Ephesians 6:11",
                category: .epistles,
                difficulty: .intermediate,
                description: "Standing firm in faith",
                tags: ["armor", "warfare", "faith"]
            ),
            Lesson(
                title: "Christ's Humility",
                theme: "Humility",
                book: "Philippians",
                startChapter: 2,
                startVerse: 1,
                endChapter: 2,
                endVerse: 11,
                memoryVerseReference: "Philippians 2:5",
                category: .epistles,
                difficulty: .beginner,
                description: "The mind of Christ",
                tags: ["humility", "servant", "attitude"]
            ),
            Lesson(
                title: "Faith Heroes",
                theme: "Faith",
                book: "Hebrews",
                startChapter: 11,
                startVerse: 1,
                endChapter: 11,
                endVerse: 40,
                memoryVerseReference: "Hebrews 11:1",
                category: .epistles,
                difficulty: .advanced,
                description: "The hall of faith",
                tags: ["faith", "heroes", "perseverance"]
            ),

            // Foundation / History
            Lesson(
                title: "David and Goliath",
                theme: "Courage",
                book: "1 Samuel",
                startChapter: 17,
                startVerse: 32,
                endChapter: 17,
                endVerse: 50,
                memoryVerseReference: "1 Samuel 17:47",
                category: .history,
                difficulty: .beginner,
                description: "Victory through faith",
                tags: ["courage", "faith", "victory"]
            ),
            Lesson(
                title: "Elijah on Mount Carmel",
                theme: "Power of God",
                book: "1 Kings",
                startChapter: 18,
                startVerse: 20,
                endChapter: 18,
                endVerse: 39,
                memoryVerseReference: "1 Kings 18:39",
                category: .history,
                difficulty: .intermediate,
                description: "God answers by fire",
                tags: ["power", "prophet", "confrontation"]
            ),
            Lesson(
                title: "Daniel in the Lions' Den",
                theme: "Faithfulness",
                book: "Daniel",
                startChapter: 6,
                startVerse: 10,
                endChapter: 6,
                endVerse: 23,
                memoryVerseReference: "Daniel 6:23",
                category: .history,
                difficulty: .beginner,
                description: "Standing firm in faith",
                tags: ["faithfulness", "protection", "courage"]
            )
        ]
    }

    /// All available lessons (curated + extended)
    static var allLessons: [Lesson] {
        curatedLessons + extendedLessons
    }

    /// Get lessons grouped by category
    static func groupedByCategory() -> [LessonCategory: [Lesson]] {
        Dictionary(grouping: allLessons, by: { $0.category })
    }

    /// Get lesson by ID
    static func lesson(withId id: String) -> Lesson? {
        allLessons.first { $0.id == id }
    }

    /// Get next uncompleted lesson
    static func nextUncompletedLesson(completedIds: [String]) -> Lesson? {
        curatedLessons.first { !completedIds.contains($0.id) }
    }
}
