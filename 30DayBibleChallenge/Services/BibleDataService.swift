import Foundation

class BibleDataService {
    private var bibleData: [BibleBook]?

    init() {
        loadBibleData()
    }

    private func loadBibleData() {
        // Try to load from bundled JSON file
        guard let url = Bundle.main.url(forResource: "web_bible", withExtension: "json") else {
            print("Bible data file not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            bibleData = try JSONDecoder().decode([BibleBook].self, from: data)
        } catch {
            print("Failed to load Bible data: \(error)")
        }
    }

    func loadPassage(for day: ReadingDay) -> BiblePassage? {
        guard let books = bibleData else {
            // Return sample passage if no data
            return createSamplePassage(for: day)
        }

        guard let book = books.first(where: { normalizeBookName($0.name) == normalizeBookName(day.book) }) else {
            return createSamplePassage(for: day)
        }

        var verses: [BibleVerse] = []

        // Handle single chapter or multi-chapter passages
        if day.startChapter == day.endChapter {
            // Single chapter
            let chapterIndex = day.startChapter - 1
            guard chapterIndex < book.chapters.count else {
                return createSamplePassage(for: day)
            }

            let chapter = book.chapters[chapterIndex]
            for verseNum in day.startVerse...min(day.endVerse, chapter.count) {
                let verseIndex = verseNum - 1
                if verseIndex < chapter.count {
                    verses.append(BibleVerse(
                        book: day.book,
                        chapter: day.startChapter,
                        verse: verseNum,
                        text: chapter[verseIndex]
                    ))
                }
            }
        } else {
            // Multi-chapter passage
            for chapterNum in day.startChapter...day.endChapter {
                let chapterIndex = chapterNum - 1
                guard chapterIndex < book.chapters.count else { continue }

                let chapter = book.chapters[chapterIndex]
                let startVerse = chapterNum == day.startChapter ? day.startVerse : 1
                let endVerse = chapterNum == day.endChapter ? day.endVerse : chapter.count

                for verseNum in startVerse...min(endVerse, chapter.count) {
                    let verseIndex = verseNum - 1
                    if verseIndex < chapter.count {
                        verses.append(BibleVerse(
                            book: day.book,
                            chapter: chapterNum,
                            verse: verseNum,
                            text: chapter[verseIndex]
                        ))
                    }
                }
            }
        }

        guard !verses.isEmpty else {
            return createSamplePassage(for: day)
        }

        return BiblePassage(
            book: day.book,
            startChapter: day.startChapter,
            startVerse: day.startVerse,
            endChapter: day.endChapter,
            endVerse: day.endVerse,
            verses: verses
        )
    }

    func loadMemoryVerse(reference: String) -> BibleVerse? {
        // Parse reference like "Genesis 1:1" or "John 3:16"
        let parts = reference.components(separatedBy: " ")
        guard parts.count >= 2 else { return nil }

        let book = parts.dropLast().joined(separator: " ")
        let location = parts.last!

        let locationParts = location.components(separatedBy: ":")
        guard locationParts.count == 2,
              let chapter = Int(locationParts[0]),
              let verse = Int(locationParts[1].components(separatedBy: "-").first ?? "") else {
            return nil
        }

        guard let books = bibleData,
              let bookData = books.first(where: { normalizeBookName($0.name) == normalizeBookName(book) }),
              chapter - 1 < bookData.chapters.count,
              verse - 1 < bookData.chapters[chapter - 1].count else {
            return createSampleMemoryVerse(reference: reference)
        }

        return BibleVerse(
            book: book,
            chapter: chapter,
            verse: verse,
            text: bookData.chapters[chapter - 1][verse - 1]
        )
    }

    private func normalizeBookName(_ name: String) -> String {
        // Normalize book names for matching
        name.lowercased()
            .replacingOccurrences(of: "1 ", with: "1")
            .replacingOccurrences(of: "2 ", with: "2")
            .replacingOccurrences(of: "3 ", with: "3")
            .replacingOccurrences(of: "first ", with: "1")
            .replacingOccurrences(of: "second ", with: "2")
            .replacingOccurrences(of: "third ", with: "3")
    }

    private func createSamplePassage(for day: ReadingDay) -> BiblePassage {
        // Create sample content for development
        let sampleVerses = getSampleVerses(for: day)

        return BiblePassage(
            book: day.book,
            startChapter: day.startChapter,
            startVerse: day.startVerse,
            endChapter: day.endChapter,
            endVerse: day.endVerse,
            verses: sampleVerses
        )
    }

    private func getSampleVerses(for day: ReadingDay) -> [BibleVerse] {
        // Return well-known verses for popular passages
        switch day.id {
        case 1: // Genesis 1
            return [
                BibleVerse(book: "Genesis", chapter: 1, verse: 1, text: "In the beginning God created the heavens and the earth."),
                BibleVerse(book: "Genesis", chapter: 1, verse: 2, text: "The earth was formless and empty, and darkness was over the surface of the deep. And the Spirit of God was hovering over the surface of the waters."),
                BibleVerse(book: "Genesis", chapter: 1, verse: 3, text: "God said, \"Let there be light,\" and there was light."),
                BibleVerse(book: "Genesis", chapter: 1, verse: 4, text: "God saw that the light was good, and God separated the light from the darkness."),
                BibleVerse(book: "Genesis", chapter: 1, verse: 5, text: "God called the light \"day,\" and the darkness he called \"night.\" There was evening, and there was morning—the first day.")
            ]

        case 8: // Psalm 23
            return [
                BibleVerse(book: "Psalms", chapter: 23, verse: 1, text: "The LORD is my shepherd; I shall not want."),
                BibleVerse(book: "Psalms", chapter: 23, verse: 2, text: "He makes me lie down in green pastures; he leads me beside still waters."),
                BibleVerse(book: "Psalms", chapter: 23, verse: 3, text: "He restores my soul. He leads me in paths of righteousness for his name's sake."),
                BibleVerse(book: "Psalms", chapter: 23, verse: 4, text: "Even though I walk through the valley of the shadow of death, I will fear no evil, for you are with me; your rod and your staff, they comfort me."),
                BibleVerse(book: "Psalms", chapter: 23, verse: 5, text: "You prepare a table before me in the presence of my enemies; you anoint my head with oil; my cup overflows."),
                BibleVerse(book: "Psalms", chapter: 23, verse: 6, text: "Surely goodness and mercy shall follow me all the days of my life, and I shall dwell in the house of the LORD forever.")
            ]

        case 22: // John 3
            return [
                BibleVerse(book: "John", chapter: 3, verse: 1, text: "Now there was a man of the Pharisees named Nicodemus, a ruler of the Jews."),
                BibleVerse(book: "John", chapter: 3, verse: 2, text: "This man came to Jesus by night and said to him, \"Rabbi, we know that you are a teacher come from God, for no one can do these signs that you do unless God is with him.\""),
                BibleVerse(book: "John", chapter: 3, verse: 3, text: "Jesus answered him, \"Truly, truly, I say to you, unless one is born again he cannot see the kingdom of God.\""),
                BibleVerse(book: "John", chapter: 3, verse: 16, text: "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life."),
                BibleVerse(book: "John", chapter: 3, verse: 17, text: "For God did not send his Son into the world to condemn the world, but in order that the world might be saved through him.")
            ]

        default:
            // Generic sample verses
            return (day.startVerse...min(day.endVerse, day.startVerse + 4)).map { verse in
                BibleVerse(
                    book: day.book,
                    chapter: day.startChapter,
                    verse: verse,
                    text: "[\(day.book) \(day.startChapter):\(verse)] - Sample verse text for the \(day.theme) theme."
                )
            }
        }
    }

    private func createSampleMemoryVerse(reference: String) -> BibleVerse {
        // Well-known memory verses
        switch reference {
        case "Genesis 1:1":
            return BibleVerse(book: "Genesis", chapter: 1, verse: 1, text: "In the beginning God created the heavens and the earth.")
        case "John 3:16":
            return BibleVerse(book: "John", chapter: 3, verse: 16, text: "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.")
        case "Psalms 23:1", "Psalm 23:1":
            return BibleVerse(book: "Psalms", chapter: 23, verse: 1, text: "The LORD is my shepherd; I shall not want.")
        case "Proverbs 3:5-6":
            return BibleVerse(book: "Proverbs", chapter: 3, verse: 5, text: "Trust in the LORD with all your heart, and do not lean on your own understanding. In all your ways acknowledge him, and he will make straight your paths.")
        default:
            let parts = reference.components(separatedBy: " ")
            let book = parts.dropLast().joined(separator: " ")
            return BibleVerse(book: book, chapter: 1, verse: 1, text: "Memory verse: \(reference)")
        }
    }
}

// Extension for widget data access
extension BibleDataService {
    static let shared = BibleDataService()

    func getTodayVerse() -> BibleVerse? {
        let today = ReadingPlan.today()
        return loadMemoryVerse(reference: today.memoryVerse)
    }

    func getTodayReading() -> ReadingDay {
        ReadingPlan.today()
    }
}
