import Foundation
import FirebaseFirestore

/// Firestore user document model
/// Stores user profile information in the cloud
struct CloudUser: Codable, Identifiable, Equatable {
    @DocumentID var documentId: String?
    let userId: String
    var email: String?
    var displayName: String?
    var createdAt: Date
    var isPremium: Bool
    var premiumExpiresAt: Date?

    // Reading progress synced to cloud
    var completedDays: [Int]
    var currentStreak: Int
    var longestStreak: Int
    var lastReadDate: Date?
    var completedLessonIds: [String]

    var id: String { userId }

    init(
        userId: String,
        email: String? = nil,
        displayName: String? = nil,
        createdAt: Date = Date(),
        isPremium: Bool = false,
        premiumExpiresAt: Date? = nil,
        completedDays: [Int] = [],
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastReadDate: Date? = nil,
        completedLessonIds: [String] = []
    ) {
        self.userId = userId
        self.email = email
        self.displayName = displayName
        self.createdAt = createdAt
        self.isPremium = isPremium
        self.premiumExpiresAt = premiumExpiresAt
        self.completedDays = completedDays
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastReadDate = lastReadDate
        self.completedLessonIds = completedLessonIds
    }

    /// Create CloudUser from UserProgress and auth info
    static func from(
        userProgress: UserProgress,
        userId: String,
        email: String?,
        displayName: String?
    ) -> CloudUser {
        CloudUser(
            userId: userId,
            email: email,
            displayName: displayName,
            createdAt: Date(),
            isPremium: userProgress.isPremium,
            premiumExpiresAt: nil,
            completedDays: userProgress.completedDays,
            currentStreak: userProgress.currentStreak,
            longestStreak: userProgress.longestStreak,
            lastReadDate: userProgress.lastReadDate,
            completedLessonIds: userProgress.completedLessonIds
        )
    }

    /// Apply cloud data to local UserProgress
    func applyTo(_ userProgress: UserProgress) {
        // Merge completed days (union of local and cloud)
        let mergedDays = Set(userProgress.completedDays).union(Set(completedDays))
        userProgress.completedDays = Array(mergedDays).sorted()

        // Take the higher streak values
        userProgress.currentStreak = max(userProgress.currentStreak, currentStreak)
        userProgress.longestStreak = max(userProgress.longestStreak, longestStreak)

        // Take the most recent read date
        if let cloudDate = lastReadDate {
            if let localDate = userProgress.lastReadDate {
                userProgress.lastReadDate = max(cloudDate, localDate)
            } else {
                userProgress.lastReadDate = cloudDate
            }
        }

        // Merge completed lessons
        let mergedLessons = Set(userProgress.completedLessonIds).union(Set(completedLessonIds))
        userProgress.completedLessonIds = Array(mergedLessons)

        // Premium status: cloud wins (server is source of truth for purchases)
        if isPremium {
            userProgress.isPremium = true
        }
    }
}
