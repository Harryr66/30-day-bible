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

    init() {
        self.id = UUID()
        self.completedDays = []
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastReadDate = nil
        self.totalReadingTime = 0
        self.isPremium = false
        self.premiumPurchaseDate = nil
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

    static let appGroupIdentifier = "group.com.biblechallenge.shared"

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
            isPremium: progress.isPremium
        )
    }
}
