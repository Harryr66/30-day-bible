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
            // ═══════════════════════════════════════════
            // FOUNDATION - Old Testament Stories
            // ═══════════════════════════════════════════

            Lesson(
                title: "Noah and the Flood",
                theme: "Obedience",
                book: "Genesis",
                startChapter: 6,
                startVerse: 9,
                endChapter: 7,
                endVerse: 24,
                memoryVerseReference: "Genesis 6:22",
                category: .foundation,
                difficulty: .beginner,
                description: "Noah's faithful obedience to God",
                tags: ["obedience", "faith", "judgment", "salvation"]
            ),
            Lesson(
                title: "The Rainbow Promise",
                theme: "Covenant",
                book: "Genesis",
                startChapter: 9,
                startVerse: 8,
                endChapter: 9,
                endVerse: 17,
                memoryVerseReference: "Genesis 9:13",
                category: .foundation,
                difficulty: .beginner,
                description: "God's covenant with Noah",
                tags: ["covenant", "promise", "rainbow"]
            ),
            Lesson(
                title: "Jacob's Ladder",
                theme: "God's Presence",
                book: "Genesis",
                startChapter: 28,
                startVerse: 10,
                endChapter: 28,
                endVerse: 22,
                memoryVerseReference: "Genesis 28:15",
                category: .foundation,
                difficulty: .beginner,
                description: "God's promise to be with us",
                tags: ["dreams", "presence", "promise"]
            ),
            Lesson(
                title: "Wrestling with God",
                theme: "Persistence",
                book: "Genesis",
                startChapter: 32,
                startVerse: 22,
                endChapter: 32,
                endVerse: 32,
                memoryVerseReference: "Genesis 32:28",
                category: .foundation,
                difficulty: .intermediate,
                description: "Jacob's transforming encounter",
                tags: ["persistence", "transformation", "blessing"]
            ),
            Lesson(
                title: "Joseph's Dreams",
                theme: "Purpose",
                book: "Genesis",
                startChapter: 37,
                startVerse: 1,
                endChapter: 37,
                endVerse: 28,
                memoryVerseReference: "Genesis 50:20",
                category: .foundation,
                difficulty: .beginner,
                description: "God's plan through adversity",
                tags: ["dreams", "purpose", "brothers"]
            ),
            Lesson(
                title: "Joseph Forgives",
                theme: "Forgiveness",
                book: "Genesis",
                startChapter: 45,
                startVerse: 1,
                endChapter: 45,
                endVerse: 15,
                memoryVerseReference: "Genesis 45:5",
                category: .foundation,
                difficulty: .beginner,
                description: "The power of forgiveness",
                tags: ["forgiveness", "reconciliation", "family"]
            ),
            Lesson(
                title: "The Burning Bush",
                theme: "Calling",
                book: "Exodus",
                startChapter: 3,
                startVerse: 1,
                endChapter: 3,
                endVerse: 15,
                memoryVerseReference: "Exodus 3:14",
                category: .foundation,
                difficulty: .beginner,
                description: "God calls Moses",
                tags: ["calling", "identity", "mission"]
            ),

            // ═══════════════════════════════════════════
            // HISTORY - Biblical Heroes
            // ═══════════════════════════════════════════

            Lesson(
                title: "Walls of Jericho",
                theme: "Faith in Action",
                book: "Joshua",
                startChapter: 6,
                startVerse: 1,
                endChapter: 6,
                endVerse: 20,
                memoryVerseReference: "Joshua 6:20",
                category: .history,
                difficulty: .beginner,
                description: "Victory through obedience",
                tags: ["faith", "victory", "obedience"]
            ),
            Lesson(
                title: "Gideon's 300",
                theme: "God's Power",
                book: "Judges",
                startChapter: 7,
                startVerse: 1,
                endChapter: 7,
                endVerse: 22,
                memoryVerseReference: "Judges 7:7",
                category: .history,
                difficulty: .intermediate,
                description: "Victory with few",
                tags: ["power", "weakness", "victory"]
            ),
            Lesson(
                title: "Ruth's Loyalty",
                theme: "Faithfulness",
                book: "Ruth",
                startChapter: 1,
                startVerse: 1,
                endChapter: 1,
                endVerse: 22,
                memoryVerseReference: "Ruth 1:16",
                category: .history,
                difficulty: .beginner,
                description: "Unwavering devotion",
                tags: ["loyalty", "love", "commitment"]
            ),
            Lesson(
                title: "Samuel's Call",
                theme: "Listening",
                book: "1 Samuel",
                startChapter: 3,
                startVerse: 1,
                endChapter: 3,
                endVerse: 21,
                memoryVerseReference: "1 Samuel 3:10",
                category: .history,
                difficulty: .beginner,
                description: "Hearing God's voice",
                tags: ["calling", "listening", "obedience"]
            ),
            Lesson(
                title: "David Anointed",
                theme: "God's Choice",
                book: "1 Samuel",
                startChapter: 16,
                startVerse: 1,
                endChapter: 16,
                endVerse: 13,
                memoryVerseReference: "1 Samuel 16:7",
                category: .history,
                difficulty: .beginner,
                description: "God looks at the heart",
                tags: ["heart", "anointing", "character"]
            ),
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
                title: "Solomon's Wisdom",
                theme: "Wisdom",
                book: "1 Kings",
                startChapter: 3,
                startVerse: 5,
                endChapter: 3,
                endVerse: 14,
                memoryVerseReference: "1 Kings 3:9",
                category: .history,
                difficulty: .beginner,
                description: "Asking for wisdom",
                tags: ["wisdom", "prayer", "discernment"]
            ),
            Lesson(
                title: "Elijah Fed by Ravens",
                theme: "God's Provision",
                book: "1 Kings",
                startChapter: 17,
                startVerse: 1,
                endChapter: 17,
                endVerse: 16,
                memoryVerseReference: "1 Kings 17:6",
                category: .history,
                difficulty: .beginner,
                description: "Miraculous provision",
                tags: ["provision", "faith", "miracles"]
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
                title: "Job's Faith",
                theme: "Suffering",
                book: "Job",
                startChapter: 1,
                startVerse: 13,
                endChapter: 1,
                endVerse: 22,
                memoryVerseReference: "Job 1:21",
                category: .wisdom,
                difficulty: .intermediate,
                description: "Faith through trials",
                tags: ["suffering", "faith", "perseverance"]
            ),
            Lesson(
                title: "Job's Restoration",
                theme: "Redemption",
                book: "Job",
                startChapter: 42,
                startVerse: 1,
                endChapter: 42,
                endVerse: 17,
                memoryVerseReference: "Job 42:5",
                category: .wisdom,
                difficulty: .intermediate,
                description: "God restores everything",
                tags: ["restoration", "blessing", "humility"]
            ),
            Lesson(
                title: "For Such a Time",
                theme: "Courage",
                book: "Esther",
                startChapter: 4,
                startVerse: 1,
                endChapter: 4,
                endVerse: 17,
                memoryVerseReference: "Esther 4:14",
                category: .history,
                difficulty: .intermediate,
                description: "Esther's brave stand",
                tags: ["courage", "purpose", "faith"]
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
            ),
            Lesson(
                title: "Jonah and the Fish",
                theme: "Obedience",
                book: "Jonah",
                startChapter: 1,
                startVerse: 1,
                endChapter: 2,
                endVerse: 10,
                memoryVerseReference: "Jonah 2:9",
                category: .prophets,
                difficulty: .beginner,
                description: "Running from God",
                tags: ["obedience", "mercy", "second chances"]
            ),
            Lesson(
                title: "Nineveh Repents",
                theme: "Repentance",
                book: "Jonah",
                startChapter: 3,
                startVerse: 1,
                endChapter: 3,
                endVerse: 10,
                memoryVerseReference: "Jonah 3:10",
                category: .prophets,
                difficulty: .beginner,
                description: "A city turns to God",
                tags: ["repentance", "mercy", "revival"]
            ),

            // ═══════════════════════════════════════════
            // PSALMS - Songs of Faith
            // ═══════════════════════════════════════════

            Lesson(
                title: "The Blessed Life",
                theme: "Righteousness",
                book: "Psalms",
                startChapter: 1,
                startVerse: 1,
                endChapter: 1,
                endVerse: 6,
                memoryVerseReference: "Psalms 1:1-2",
                category: .psalms,
                difficulty: .beginner,
                description: "The path of the righteous",
                tags: ["blessing", "wisdom", "choices"]
            ),
            Lesson(
                title: "What is Man?",
                theme: "Human Worth",
                book: "Psalms",
                startChapter: 8,
                startVerse: 1,
                endChapter: 8,
                endVerse: 9,
                memoryVerseReference: "Psalms 8:4-5",
                category: .psalms,
                difficulty: .beginner,
                description: "Our place in creation",
                tags: ["creation", "worth", "glory"]
            ),
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
                title: "Light and Salvation",
                theme: "Confidence",
                book: "Psalms",
                startChapter: 27,
                startVerse: 1,
                endChapter: 27,
                endVerse: 14,
                memoryVerseReference: "Psalms 27:1",
                category: .psalms,
                difficulty: .beginner,
                description: "Trusting without fear",
                tags: ["confidence", "trust", "seeking"]
            ),
            Lesson(
                title: "God Our Refuge",
                theme: "Security",
                book: "Psalms",
                startChapter: 46,
                startVerse: 1,
                endChapter: 46,
                endVerse: 11,
                memoryVerseReference: "Psalms 46:10",
                category: .psalms,
                difficulty: .beginner,
                description: "Be still and know",
                tags: ["refuge", "peace", "strength"]
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
            Lesson(
                title: "Bless the Lord",
                theme: "Praise",
                book: "Psalms",
                startChapter: 103,
                startVerse: 1,
                endChapter: 103,
                endVerse: 22,
                memoryVerseReference: "Psalms 103:1-2",
                category: .psalms,
                difficulty: .beginner,
                description: "Remembering God's benefits",
                tags: ["praise", "forgiveness", "love"]
            ),
            Lesson(
                title: "My Help Comes",
                theme: "Help",
                book: "Psalms",
                startChapter: 121,
                startVerse: 1,
                endChapter: 121,
                endVerse: 8,
                memoryVerseReference: "Psalms 121:1-2",
                category: .psalms,
                difficulty: .beginner,
                description: "The Lord watches over you",
                tags: ["help", "protection", "journey"]
            ),
            Lesson(
                title: "Wonderfully Made",
                theme: "Identity",
                book: "Psalms",
                startChapter: 139,
                startVerse: 1,
                endChapter: 139,
                endVerse: 18,
                memoryVerseReference: "Psalms 139:14",
                category: .psalms,
                difficulty: .beginner,
                description: "God knows you completely",
                tags: ["identity", "worth", "creation"]
            ),

            // ═══════════════════════════════════════════
            // WISDOM - Proverbs & Ecclesiastes
            // ═══════════════════════════════════════════

            Lesson(
                title: "Guard Your Heart",
                theme: "Protection",
                book: "Proverbs",
                startChapter: 4,
                startVerse: 20,
                endChapter: 4,
                endVerse: 27,
                memoryVerseReference: "Proverbs 4:23",
                category: .wisdom,
                difficulty: .beginner,
                description: "Protecting your inner life",
                tags: ["heart", "wisdom", "choices"]
            ),
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

            // ═══════════════════════════════════════════
            // PROPHETS - God's Messengers
            // ═══════════════════════════════════════════

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
            Lesson(
                title: "Plans for Hope",
                theme: "Future",
                book: "Jeremiah",
                startChapter: 29,
                startVerse: 10,
                endChapter: 29,
                endVerse: 14,
                memoryVerseReference: "Jeremiah 29:11",
                category: .prophets,
                difficulty: .beginner,
                description: "God's plans to prosper you",
                tags: ["hope", "future", "plans"]
            ),
            Lesson(
                title: "Valley of Dry Bones",
                theme: "Revival",
                book: "Ezekiel",
                startChapter: 37,
                startVerse: 1,
                endChapter: 37,
                endVerse: 14,
                memoryVerseReference: "Ezekiel 37:5",
                category: .prophets,
                difficulty: .intermediate,
                description: "God brings life from death",
                tags: ["revival", "restoration", "hope"]
            ),
            Lesson(
                title: "Do Justice, Love Mercy",
                theme: "Righteousness",
                book: "Micah",
                startChapter: 6,
                startVerse: 6,
                endChapter: 6,
                endVerse: 8,
                memoryVerseReference: "Micah 6:8",
                category: .prophets,
                difficulty: .beginner,
                description: "What the Lord requires",
                tags: ["justice", "mercy", "humility"]
            ),

            // ═══════════════════════════════════════════
            // GOSPELS - Life of Jesus
            // ═══════════════════════════════════════════

            Lesson(
                title: "Jesus' Baptism",
                theme: "Identity",
                book: "Matthew",
                startChapter: 3,
                startVerse: 13,
                endChapter: 3,
                endVerse: 17,
                memoryVerseReference: "Matthew 3:17",
                category: .gospels,
                difficulty: .beginner,
                description: "The Father's affirmation",
                tags: ["baptism", "identity", "Spirit"]
            ),
            Lesson(
                title: "Temptation in the Desert",
                theme: "Victory",
                book: "Matthew",
                startChapter: 4,
                startVerse: 1,
                endChapter: 4,
                endVerse: 11,
                memoryVerseReference: "Matthew 4:4",
                category: .gospels,
                difficulty: .beginner,
                description: "Overcoming temptation",
                tags: ["temptation", "victory", "Scripture"]
            ),
            Lesson(
                title: "Walking on Water",
                theme: "Faith",
                book: "Matthew",
                startChapter: 14,
                startVerse: 22,
                endChapter: 14,
                endVerse: 33,
                memoryVerseReference: "Matthew 14:31",
                category: .gospels,
                difficulty: .beginner,
                description: "Keeping eyes on Jesus",
                tags: ["faith", "fear", "miracles"]
            ),
            Lesson(
                title: "The Transfiguration",
                theme: "Glory",
                book: "Matthew",
                startChapter: 17,
                startVerse: 1,
                endChapter: 17,
                endVerse: 13,
                memoryVerseReference: "Matthew 17:5",
                category: .gospels,
                difficulty: .intermediate,
                description: "Jesus revealed in glory",
                tags: ["glory", "revelation", "listen"]
            ),
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
                title: "Feeding the 5000",
                theme: "Provision",
                book: "John",
                startChapter: 6,
                startVerse: 1,
                endChapter: 6,
                endVerse: 14,
                memoryVerseReference: "John 6:35",
                category: .gospels,
                difficulty: .beginner,
                description: "Jesus provides abundantly",
                tags: ["provision", "miracles", "faith"]
            ),
            Lesson(
                title: "Lazarus Raised",
                theme: "Resurrection",
                book: "John",
                startChapter: 11,
                startVerse: 32,
                endChapter: 11,
                endVerse: 44,
                memoryVerseReference: "John 11:25-26",
                category: .gospels,
                difficulty: .beginner,
                description: "Jesus conquers death",
                tags: ["resurrection", "faith", "hope"]
            ),
            Lesson(
                title: "Washing Feet",
                theme: "Service",
                book: "John",
                startChapter: 13,
                startVerse: 1,
                endChapter: 13,
                endVerse: 17,
                memoryVerseReference: "John 13:14-15",
                category: .gospels,
                difficulty: .beginner,
                description: "Servant leadership",
                tags: ["service", "humility", "love"]
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
            Lesson(
                title: "The Crucifixion",
                theme: "Sacrifice",
                book: "John",
                startChapter: 19,
                startVerse: 16,
                endChapter: 19,
                endVerse: 30,
                memoryVerseReference: "John 19:30",
                category: .gospels,
                difficulty: .intermediate,
                description: "It is finished",
                tags: ["cross", "sacrifice", "love"]
            ),

            // ═══════════════════════════════════════════
            // ACTS - Early Church
            // ═══════════════════════════════════════════

            Lesson(
                title: "Pentecost",
                theme: "Holy Spirit",
                book: "Acts",
                startChapter: 2,
                startVerse: 1,
                endChapter: 2,
                endVerse: 21,
                memoryVerseReference: "Acts 2:4",
                category: .epistles,
                difficulty: .beginner,
                description: "The Spirit comes",
                tags: ["Spirit", "power", "church"]
            ),
            Lesson(
                title: "Paul's Conversion",
                theme: "Transformation",
                book: "Acts",
                startChapter: 9,
                startVerse: 1,
                endChapter: 9,
                endVerse: 19,
                memoryVerseReference: "Acts 9:15",
                category: .epistles,
                difficulty: .beginner,
                description: "Encounter on Damascus road",
                tags: ["conversion", "calling", "grace"]
            ),

            // ═══════════════════════════════════════════
            // EPISTLES - Letters to the Church
            // ═══════════════════════════════════════════

            Lesson(
                title: "Living Sacrifice",
                theme: "Dedication",
                book: "Romans",
                startChapter: 12,
                startVerse: 1,
                endChapter: 12,
                endVerse: 8,
                memoryVerseReference: "Romans 12:1-2",
                category: .epistles,
                difficulty: .beginner,
                description: "Transformed by renewal",
                tags: ["sacrifice", "transformation", "worship"]
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
                title: "Rejoice Always",
                theme: "Joy",
                book: "Philippians",
                startChapter: 4,
                startVerse: 4,
                endChapter: 4,
                endVerse: 9,
                memoryVerseReference: "Philippians 4:6-7",
                category: .epistles,
                difficulty: .beginner,
                description: "Peace that guards hearts",
                tags: ["joy", "peace", "prayer"]
            ),
            Lesson(
                title: "Put On the New Self",
                theme: "Transformation",
                book: "Colossians",
                startChapter: 3,
                startVerse: 1,
                endChapter: 3,
                endVerse: 17,
                memoryVerseReference: "Colossians 3:12",
                category: .epistles,
                difficulty: .intermediate,
                description: "Living the new life",
                tags: ["transformation", "character", "newness"]
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
            Lesson(
                title: "Trials and Joy",
                theme: "Perseverance",
                book: "James",
                startChapter: 1,
                startVerse: 2,
                endChapter: 1,
                endVerse: 18,
                memoryVerseReference: "James 1:2-3",
                category: .epistles,
                difficulty: .beginner,
                description: "Joy in trials",
                tags: ["trials", "perseverance", "wisdom"]
            ),
            Lesson(
                title: "Living Stones",
                theme: "Identity",
                book: "1 Peter",
                startChapter: 2,
                startVerse: 4,
                endChapter: 2,
                endVerse: 12,
                memoryVerseReference: "1 Peter 2:9",
                category: .epistles,
                difficulty: .intermediate,
                description: "A chosen people",
                tags: ["identity", "priesthood", "holy"]
            ),
            Lesson(
                title: "God is Love",
                theme: "Love",
                book: "1 John",
                startChapter: 4,
                startVerse: 7,
                endChapter: 4,
                endVerse: 21,
                memoryVerseReference: "1 John 4:19",
                category: .epistles,
                difficulty: .beginner,
                description: "Perfect love casts out fear",
                tags: ["love", "fear", "relationship"]
            ),

            // ═══════════════════════════════════════════
            // REVELATION - Future Hope
            // ═══════════════════════════════════════════

            Lesson(
                title: "Throne of Heaven",
                theme: "Worship",
                book: "Revelation",
                startChapter: 4,
                startVerse: 1,
                endChapter: 4,
                endVerse: 11,
                memoryVerseReference: "Revelation 4:11",
                category: .revelation,
                difficulty: .intermediate,
                description: "Worship around the throne",
                tags: ["worship", "heaven", "glory"]
            ),
            Lesson(
                title: "New Heaven and Earth",
                theme: "Eternity",
                book: "Revelation",
                startChapter: 21,
                startVerse: 1,
                endChapter: 21,
                endVerse: 8,
                memoryVerseReference: "Revelation 21:4",
                category: .revelation,
                difficulty: .beginner,
                description: "God makes all things new",
                tags: ["heaven", "hope", "eternity"]
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
