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

/// Book structure for parsing Bible JSON
struct BibleBook: Codable {
    let name: String
    let chapters: [[String]]
}
