import Foundation

/// Service for fetching Bible content from the Free Use Bible API (bible.helloao.org)
/// Supports public domain translations: BSB (Berean Standard Bible) and WEB (World English Bible)
actor BibleAPIService {
    static let shared = BibleAPIService()

    private let baseURL = "https://bible.helloao.org/api"
    private let defaultTranslation = "BSB" // Berean Standard Bible

    // Cache for fetched chapters
    private var chapterCache: [String: [String: Any]] = [:]

    // Book name to API code mapping
    private let bookCodes: [String: String] = [
        "Genesis": "GEN",
        "Exodus": "EXO",
        "Leviticus": "LEV",
        "Numbers": "NUM",
        "Deuteronomy": "DEU",
        "Joshua": "JOS",
        "Judges": "JDG",
        "Ruth": "RUT",
        "1 Samuel": "1SA",
        "2 Samuel": "2SA",
        "1 Kings": "1KI",
        "2 Kings": "2KI",
        "1 Chronicles": "1CH",
        "2 Chronicles": "2CH",
        "Ezra": "EZR",
        "Nehemiah": "NEH",
        "Esther": "EST",
        "Job": "JOB",
        "Psalms": "PSA",
        "Proverbs": "PRO",
        "Ecclesiastes": "ECC",
        "Song of Solomon": "SNG",
        "Isaiah": "ISA",
        "Jeremiah": "JER",
        "Lamentations": "LAM",
        "Ezekiel": "EZK",
        "Daniel": "DAN",
        "Hosea": "HOS",
        "Joel": "JOL",
        "Amos": "AMO",
        "Obadiah": "OBA",
        "Jonah": "JON",
        "Micah": "MIC",
        "Nahum": "NAM",
        "Habakkuk": "HAB",
        "Zephaniah": "ZEP",
        "Haggai": "HAG",
        "Zechariah": "ZEC",
        "Malachi": "MAL",
        "Matthew": "MAT",
        "Mark": "MRK",
        "Luke": "LUK",
        "John": "JHN",
        "Acts": "ACT",
        "Romans": "ROM",
        "1 Corinthians": "1CO",
        "2 Corinthians": "2CO",
        "Galatians": "GAL",
        "Ephesians": "EPH",
        "Philippians": "PHP",
        "Colossians": "COL",
        "1 Thessalonians": "1TH",
        "2 Thessalonians": "2TH",
        "1 Timothy": "1TI",
        "2 Timothy": "2TI",
        "Titus": "TIT",
        "Philemon": "PHM",
        "Hebrews": "HEB",
        "James": "JAS",
        "1 Peter": "1PE",
        "2 Peter": "2PE",
        "1 John": "1JN",
        "2 John": "2JN",
        "3 John": "3JN",
        "Jude": "JUD",
        "Revelation": "REV"
    ]

    enum BibleAPIError: Error, LocalizedError {
        case invalidBookName(String)
        case networkError(Error)
        case invalidResponse
        case noData

        var errorDescription: String? {
            switch self {
            case .invalidBookName(let name):
                return "Unknown book name: \(name)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .invalidResponse:
                return "Invalid response from API"
            case .noData:
                return "No data returned from API"
            }
        }
    }

    /// Fetch a specific chapter from the Bible API
    func fetchChapter(book: String, chapter: Int, translation: String? = nil) async throws -> [BibleVerse] {
        let trans = translation ?? defaultTranslation
        guard let bookCode = bookCodes[book] else {
            throw BibleAPIError.invalidBookName(book)
        }

        let cacheKey = "\(trans)_\(bookCode)_\(chapter)"

        // Check cache first
        if let cached = chapterCache[cacheKey],
           let verses = parseVerses(from: cached, book: book, chapter: chapter) {
            return verses
        }

        // Build URL: https://bible.helloao.org/api/{translation}/{book}/{chapter}.json
        let urlString = "\(baseURL)/\(trans)/\(bookCode)/\(chapter).json"
        guard let url = URL(string: urlString) else {
            throw BibleAPIError.invalidResponse
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BibleAPIError.invalidResponse
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw BibleAPIError.invalidResponse
        }

        // Cache the response
        chapterCache[cacheKey] = json

        guard let verses = parseVerses(from: json, book: book, chapter: chapter) else {
            throw BibleAPIError.noData
        }

        return verses
    }

    /// Fetch a passage spanning potentially multiple chapters
    func fetchPassage(
        book: String,
        startChapter: Int,
        startVerse: Int,
        endChapter: Int,
        endVerse: Int,
        translation: String? = nil
    ) async throws -> BiblePassage {
        var allVerses: [BibleVerse] = []

        for chapterNum in startChapter...endChapter {
            let chapterVerses = try await fetchChapter(book: book, chapter: chapterNum, translation: translation)

            let filteredVerses = chapterVerses.filter { verse in
                if chapterNum == startChapter && chapterNum == endChapter {
                    return verse.verse >= startVerse && verse.verse <= endVerse
                } else if chapterNum == startChapter {
                    return verse.verse >= startVerse
                } else if chapterNum == endChapter {
                    return verse.verse <= endVerse
                }
                return true
            }

            allVerses.append(contentsOf: filteredVerses)
        }

        return BiblePassage(
            book: book,
            startChapter: startChapter,
            startVerse: startVerse,
            endChapter: endChapter,
            endVerse: endVerse,
            verses: allVerses
        )
    }

    /// Fetch passage for a ReadingDay
    func fetchPassage(for readingDay: ReadingDay, translation: String? = nil) async throws -> BiblePassage {
        try await fetchPassage(
            book: readingDay.book,
            startChapter: readingDay.startChapter,
            startVerse: readingDay.startVerse,
            endChapter: readingDay.endChapter,
            endVerse: readingDay.endVerse,
            translation: translation
        )
    }

    /// Fetch passage for a Lesson
    func fetchPassage(for lesson: Lesson, translation: String? = nil) async throws -> BiblePassage {
        try await fetchPassage(
            book: lesson.book,
            startChapter: lesson.startChapter,
            startVerse: lesson.startVerse,
            endChapter: lesson.endChapter,
            endVerse: lesson.endVerse,
            translation: translation
        )
    }

    // MARK: - Private Helpers

    private func parseVerses(from json: [String: Any], book: String, chapter: Int) -> [BibleVerse]? {
        // The API returns verses in a "verses" array or keyed by verse number
        // Structure varies, so we handle both cases

        var verses: [BibleVerse] = []

        if let versesArray = json["verses"] as? [[String: Any]] {
            for verseData in versesArray {
                if let verseNum = verseData["verse"] as? Int,
                   let text = verseData["text"] as? String {
                    let cleanText = cleanHTMLTags(from: text)
                    verses.append(BibleVerse(
                        book: book,
                        chapter: chapter,
                        verse: verseNum,
                        text: cleanText
                    ))
                }
            }
        } else if let chapterData = json["chapter"] as? [String: Any],
                  let content = chapterData["content"] as? [[String: Any]] {
            // Alternative format
            for item in content {
                if let verseNum = item["verseNumber"] as? Int,
                   let text = item["text"] as? String {
                    let cleanText = cleanHTMLTags(from: text)
                    verses.append(BibleVerse(
                        book: book,
                        chapter: chapter,
                        verse: verseNum,
                        text: cleanText
                    ))
                }
            }
        }

        return verses.isEmpty ? nil : verses.sorted { $0.verse < $1.verse }
    }

    /// Remove HTML tags and clean up text
    private func cleanHTMLTags(from text: String) -> String {
        var cleaned = text

        // Remove HTML tags
        cleaned = cleaned.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)

        // Decode HTML entities
        cleaned = cleaned.replacingOccurrences(of: "&nbsp;", with: " ")
        cleaned = cleaned.replacingOccurrences(of: "&amp;", with: "&")
        cleaned = cleaned.replacingOccurrences(of: "&lt;", with: "<")
        cleaned = cleaned.replacingOccurrences(of: "&gt;", with: ">")
        cleaned = cleaned.replacingOccurrences(of: "&quot;", with: "\"")
        cleaned = cleaned.replacingOccurrences(of: "&#39;", with: "'")
        cleaned = cleaned.replacingOccurrences(of: "&apos;", with: "'")

        // Normalize whitespace
        cleaned = cleaned.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        return cleaned
    }

    /// Clear the chapter cache
    func clearCache() {
        chapterCache.removeAll()
    }

    /// Get available translations
    func availableTranslations() -> [(code: String, name: String)] {
        [
            ("BSB", "Berean Standard Bible"),
            ("WEB", "World English Bible"),
            ("KJV", "King James Version")
        ]
    }
}
