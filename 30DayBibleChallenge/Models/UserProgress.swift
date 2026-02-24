import Foundation
import SwiftData

@Model
final class UserProgress {
    var id: UUID
    var completedDays: [Int]
    var currentStreak: Int
    var longestStreak: Int
    var lastReadDate: Date?
    var totalReadingTime: TimeInterval
    var isPremium: Bool
    var premiumPurchaseDate: Date?

    // Session tracking
    var sessionTimestamps: [Date] = []
    var completedLessonIds: [String] = []

    // Session constants
    static let freeSessionLimit = 5
    static let sessionWindowHours: TimeInterval = 24 * 60 * 60

    init() {
        self.id = UUID()
        self.completedDays = []
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastReadDate = nil
        self.totalReadingTime = 0
        self.isPremium = true // TODO: Set back to false before release
        self.premiumPurchaseDate = nil
        self.sessionTimestamps = []
        self.completedLessonIds = []
    }

    // MARK: - Session Management

    var activeSessions: [Date] {
        let cutoff = Date().addingTimeInterval(-Self.sessionWindowHours)
        return sessionTimestamps.filter { $0 > cutoff }
    }

    var remainingSessions: Int {
        if isPremium { return Int.max }
        return max(0, Self.freeSessionLimit - activeSessions.count)
    }

    var canStartSession: Bool {
        isPremium || remainingSessions > 0
    }

    var timeUntilNextSession: TimeInterval? {
        guard !isPremium && remainingSessions == 0,
              let oldest = activeSessions.sorted().first else { return nil }
        return oldest.addingTimeInterval(Self.sessionWindowHours).timeIntervalSince(Date())
    }

    func recordSessionStart() {
        sessionTimestamps.append(Date())
        // Prune old sessions (older than 48 hours)
        let threshold = Date().addingTimeInterval(-48 * 60 * 60)
        sessionTimestamps = sessionTimestamps.filter { $0 > threshold }
    }

    func markLessonComplete(_ lessonId: String) {
        if !completedLessonIds.contains(lessonId) {
            completedLessonIds.append(lessonId)
        }
    }

    func isLessonComplete(_ lessonId: String) -> Bool {
        completedLessonIds.contains(lessonId)
    }

    func markDayComplete(_ day: Int) {
        if !completedDays.contains(day) {
            completedDays.append(day)
        }
        updateStreak()
    }

    func isDayComplete(_ day: Int) -> Bool {
        completedDays.contains(day)
    }

    var completionPercentage: Double {
        Double(completedDays.count) / 30.0 * 100.0
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastRead = lastReadDate {
            let lastReadDay = calendar.startOfDay(for: lastRead)
            let daysDifference = calendar.dateComponents([.day], from: lastReadDay, to: today).day ?? 0

            if daysDifference == 0 {
                // Same day, streak stays the same
            } else if daysDifference == 1 {
                // Consecutive day, increment streak
                currentStreak += 1
            } else {
                // Missed days, reset streak
                currentStreak = 1
            }
        } else {
            // First reading ever
            currentStreak = 1
        }

        lastReadDate = today
        longestStreak = max(longestStreak, currentStreak)
    }
}

/// Shared progress accessible via App Groups for widget
struct SharedProgress: Codable {
    var completedDays: [Int]
    var currentStreak: Int
    var lastReadDate: Date?
    var isPremium: Bool
    var sessionTimestamps: [Date]
    var completedLessonIds: [String]

    static let appGroupIdentifier = "group.com.biblechallenge.shared"

    // Session computed properties for widget
    var activeSessions: [Date] {
        let cutoff = Date().addingTimeInterval(-UserProgress.sessionWindowHours)
        return sessionTimestamps.filter { $0 > cutoff }
    }

    var remainingSessions: Int {
        if isPremium { return Int.max }
        return max(0, UserProgress.freeSessionLimit - activeSessions.count)
    }

    var timeUntilNextSession: TimeInterval? {
        guard !isPremium && remainingSessions == 0,
              let oldest = activeSessions.sorted().first else { return nil }
        return oldest.addingTimeInterval(UserProgress.sessionWindowHours).timeIntervalSince(Date())
    }

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

    func save() {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedProgress.appGroupIdentifier) else {
            return
        }
        let fileURL = containerURL.appendingPathComponent("progress.json")
        if let data = try? JSONEncoder().encode(self) {
            try? data.write(to: fileURL)
        }
    }

    static func fromUserProgress(_ progress: UserProgress) -> SharedProgress {
        SharedProgress(
            completedDays: progress.completedDays,
            currentStreak: progress.currentStreak,
            lastReadDate: progress.lastReadDate,
            isPremium: progress.isPremium,
            sessionTimestamps: progress.sessionTimestamps,
            completedLessonIds: progress.completedLessonIds
        )
    }
}
