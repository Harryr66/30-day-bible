import Foundation
import SwiftData

/// Represents a single Bible verse
struct BibleVerse: Codable, Identifiable, Hashable {
    var id: String { "\(book)_\(chapter)_\(verse)" }
    let book: String
    let chapter: Int
    let verse: Int
    let text: String

    var reference: String {
        "\(book) \(chapter):\(verse)"
    }
}

/// Represents a passage (multiple verses)
struct BiblePassage: Codable, Identifiable, Hashable {
    let id: UUID
    let book: String
    let startChapter: Int
    let startVerse: Int
    let endChapter: Int
    let endVerse: Int
    let verses: [BibleVerse]

    var reference: String {
        if startChapter == endChapter {
            if startVerse == endVerse {
                return "\(book) \(startChapter):\(startVerse)"
            }
            return "\(book) \(startChapter):\(startVerse)-\(endVerse)"
        }
        return "\(book) \(startChapter):\(startVerse)-\(endChapter):\(endVerse)"
    }

    var fullText: String {
        verses.map { $0.text }.joined(separator: " ")
    }

    var keyVerse: BibleVerse? {
        verses.first
    }

    init(id: UUID = UUID(), book: String, startChapter: Int, startVerse: Int, endChapter: Int, endVerse: Int, verses: [BibleVerse]) {
        self.id = id
        self.book = book
        self.startChapter = startChapter
        self.startVerse = startVerse
        self.endChapter = endChapter
        self.endVerse = endVerse
        self.verses = verses
    }
}

/// Verse structure for KJV Bible JSON
struct KJVVerse: Codable {
    let verse: String
    let text: String
}

/// Chapter structure for KJV Bible JSON
struct KJVChapter: Codable {
    let chapter: String
    let verses: [KJVVerse]
}

/// Book structure for parsing Bible JSON (KJV format)
struct BibleBook: Codable {
    let book: String
    let chapters: [KJVChapter]

    /// Get verse text by chapter and verse number
    func getVerse(chapter: Int, verse: Int) -> String? {
        guard chapter > 0 && chapter <= chapters.count else { return nil }
        let chapterData = chapters[chapter - 1]
        guard verse > 0 && verse <= chapterData.verses.count else { return nil }
        return chapterData.verses[verse - 1].text
    }

    /// Get all verses for a chapter
    func getChapterVerses(chapter: Int) -> [KJVVerse]? {
        guard chapter > 0 && chapter <= chapters.count else { return nil }
        return chapters[chapter - 1].verses
    }
}
