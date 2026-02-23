import Foundation
import SwiftData

enum GameType: String, Codable, CaseIterable {
    case quiz = "Quiz"
    case memoryVerse = "Memory Verse"
    case fillBlank = "Fill in the Blank"
    case matchVerse = "Match Verse"

    var icon: String {
        switch self {
        case .quiz: return "questionmark.circle.fill"
        case .memoryVerse: return "brain.head.profile"
        case .fillBlank: return "text.badge.checkmark"
        case .matchVerse: return "link"
        }
    }

    var description: String {
        switch self {
        case .quiz: return "Test your knowledge with multiple choice questions"
        case .memoryVerse: return "Memorize key verses with flashcards"
        case .fillBlank: return "Complete passages with missing words"
        case .matchVerse: return "Match verses to their references"
        }
    }
}

@Model
final class GameScore {
    var id: UUID
    var gameType: String
    var score: Int
    var totalQuestions: Int
    var dayNumber: Int
    var dateCompleted: Date
    var timeSpent: TimeInterval

    init(gameType: GameType, score: Int, totalQuestions: Int, dayNumber: Int, timeSpent: TimeInterval = 0) {
        self.id = UUID()
        self.gameType = gameType.rawValue
        self.score = score
        self.totalQuestions = totalQuestions
        self.dayNumber = dayNumber
        self.dateCompleted = Date()
        self.timeSpent = timeSpent
    }

    var percentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(score) / Double(totalQuestions) * 100
    }

    var type: GameType {
        GameType(rawValue: gameType) ?? .quiz
    }
}

/// Quiz question model
struct QuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let correctAnswer: String
    let wrongAnswers: [String]
    let verseReference: String

    var allAnswers: [String] {
        ([correctAnswer] + wrongAnswers).shuffled()
    }
}

/// Memory verse card model
struct MemoryCard: Identifiable {
    let id = UUID()
    let reference: String
    let text: String
    var isFlipped: Bool = false
    var masteryLevel: Int = 0 // 0-5, for spaced repetition

    var nextReviewDate: Date {
        let intervals = [0, 1, 3, 7, 14, 30] // Days until next review
        let interval = intervals[min(masteryLevel, intervals.count - 1)]
        return Calendar.current.date(byAdding: .day, value: interval, to: Date()) ?? Date()
    }
}

/// Fill in the blank question
struct FillBlankQuestion: Identifiable {
    let id = UUID()
    let fullText: String
    let textWithBlanks: String
    let missingWords: [String]
    let wordBank: [String]
    let verseReference: String
}

// MARK: - Mini Test Models

enum MiniTestQuestionType: String, CaseIterable, Codable {
    case fillGap = "Fill in the Gap"
    case nameVerse = "Name the Verse"
    case matchReference = "Match Reference"
    case typeBack = "Type Back"

    var icon: String {
        switch self {
        case .fillGap: return "text.badge.plus"
        case .nameVerse: return "doc.text.magnifyingglass"
        case .matchReference: return "link"
        case .typeBack: return "keyboard"
        }
    }
}

struct MiniTestQuestion: Identifiable {
    let id = UUID()
    let type: MiniTestQuestionType
    let verse: BibleVerse
    var textWithGaps: String?
    var missingWords: [String]?
    var wordBank: [String]?
    var referenceOptions: [String]?
    var matchPairs: [(verse: String, reference: String)]?
    var hintText: String?
    var attempts: Int = 0
    var isAnsweredCorrectly: Bool = false
}

/// Persisted mastery level for a specific verse
@Model
final class VerseMastery {
    var id: UUID
    var verseReference: String
    var masteryLevel: Int
    var lastReviewedDate: Date
    var nextReviewDate: Date

    init(verseReference: String, masteryLevel: Int = 0) {
        self.id = UUID()
        self.verseReference = verseReference
        self.masteryLevel = masteryLevel
        self.lastReviewedDate = Date()
        self.nextReviewDate = VerseMastery.calculateNextReview(masteryLevel: masteryLevel)
    }

    func incrementMastery() {
        masteryLevel = min(5, masteryLevel + 1)
        lastReviewedDate = Date()
        nextReviewDate = VerseMastery.calculateNextReview(masteryLevel: masteryLevel)
    }

    func decrementMastery() {
        masteryLevel = max(0, masteryLevel - 1)
        lastReviewedDate = Date()
        nextReviewDate = VerseMastery.calculateNextReview(masteryLevel: masteryLevel)
    }

    static func calculateNextReview(masteryLevel: Int) -> Date {
        // Spaced repetition intervals in days
        let intervals = [0, 1, 3, 7, 14, 30]
        let interval = intervals[min(masteryLevel, intervals.count - 1)]
        return Calendar.current.date(byAdding: .day, value: interval, to: Date()) ?? Date()
    }
}
