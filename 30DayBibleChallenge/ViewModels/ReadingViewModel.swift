import Foundation
import Combine

@MainActor
class ReadingViewModel: ObservableObject {
    @Published var passage: BiblePassage?
    @Published var memoryVerse: BibleVerse?
    @Published var isLoading = false
    @Published var error: Error?

    private let dataService = BibleDataService()

    func loadPassage(for day: ReadingDay) {
        isLoading = true
        error = nil

        // Load passage from Bible data
        if let loadedPassage = dataService.loadPassage(for: day) {
            self.passage = loadedPassage
            loadMemoryVerse(for: day)
        } else {
            // Fallback: create a sample passage if data loading fails
            createSamplePassage(for: day)
        }

        isLoading = false
    }

    private func loadMemoryVerse(for day: ReadingDay) {
        // Find the memory verse from the passage
        memoryVerse = dataService.loadMemoryVerse(reference: day.memoryVerse)
    }

    private func createSamplePassage(for day: ReadingDay) {
        // Create sample data for development/testing
        let sampleVerses = (day.startVerse...day.endVerse).map { verseNum in
            BibleVerse(
                book: day.book,
                chapter: day.startChapter,
                verse: verseNum,
                text: sampleVerseText(for: day, verse: verseNum)
            )
        }

        passage = BiblePassage(
            book: day.book,
            startChapter: day.startChapter,
            startVerse: day.startVerse,
            endChapter: day.endChapter,
            endVerse: day.endVerse,
            verses: sampleVerses
        )

        // Set memory verse as first verse
        memoryVerse = sampleVerses.first
    }

    private func sampleVerseText(for day: ReadingDay, verse: Int) -> String {
        // Return sample text based on day theme
        switch day.id {
        case 1:
            return verse == 1 ? "In the beginning God created the heavens and the earth." : "And God saw that it was good."
        case 8:
            return verse == 1 ? "The LORD is my shepherd; I shall not want." : "He makes me lie down in green pastures."
        case 22:
            return verse == 16 ? "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life." : "For God did not send his Son into the world to condemn the world."
        default:
            return "Sample verse text for \(day.book) \(day.startChapter):\(verse)"
        }
    }
}
