import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Service for syncing user progress to Firestore
actor CloudSyncService {
    static let shared = CloudSyncService()

    private let db = Firestore.firestore()
    private let usersCollection = "users"

    enum SyncError: Error, LocalizedError {
        case notAuthenticated
        case networkError(Error)
        case encodingError
        case decodingError

        var errorDescription: String? {
            switch self {
            case .notAuthenticated:
                return "You must be signed in to sync."
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .encodingError:
                return "Failed to encode data."
            case .decodingError:
                return "Failed to decode data."
            }
        }
    }

    // MARK: - User Document Operations

    /// Get the current user's cloud data
    func fetchUserData() async throws -> CloudUser? {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw SyncError.notAuthenticated
        }

        do {
            let document = try await db.collection(usersCollection).document(userId).getDocument()

            guard document.exists else {
                return nil
            }

            return try document.data(as: CloudUser.self)
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            throw SyncError.decodingError
        } catch {
            throw SyncError.networkError(error)
        }
    }

    /// Create or update user document in Firestore
    func saveUserData(_ cloudUser: CloudUser) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw SyncError.notAuthenticated
        }

        do {
            try db.collection(usersCollection).document(userId).setData(from: cloudUser, merge: true)
        } catch let error as EncodingError {
            print("Encoding error: \(error)")
            throw SyncError.encodingError
        } catch {
            throw SyncError.networkError(error)
        }
    }

    /// Delete user document from Firestore
    func deleteUserData() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw SyncError.notAuthenticated
        }

        do {
            try await db.collection(usersCollection).document(userId).delete()
        } catch {
            throw SyncError.networkError(error)
        }
    }

    // MARK: - Progress Sync

    /// Sync local progress to cloud
    /// Merges local and cloud data, preferring the most complete data
    func syncProgress(localProgress: UserProgress) async throws -> CloudUser? {
        guard let user = Auth.auth().currentUser else {
            throw SyncError.notAuthenticated
        }

        // Fetch existing cloud data
        let existingCloudUser = try await fetchUserData()

        // Create cloud user from local progress
        var cloudUser = CloudUser.from(
            userProgress: localProgress,
            userId: user.uid,
            email: user.email,
            displayName: user.displayName
        )

        // If cloud data exists, merge it
        if let existing = existingCloudUser {
            cloudUser = mergeCloudUsers(local: cloudUser, cloud: existing)
        }

        // Save merged data to cloud
        try await saveUserData(cloudUser)

        return cloudUser
    }

    /// Pull cloud data and update local progress
    func pullProgress() async throws -> CloudUser? {
        return try await fetchUserData()
    }

    /// Push local progress to cloud (overwrite)
    func pushProgress(localProgress: UserProgress) async throws {
        guard let user = Auth.auth().currentUser else {
            throw SyncError.notAuthenticated
        }

        let cloudUser = CloudUser.from(
            userProgress: localProgress,
            userId: user.uid,
            email: user.email,
            displayName: user.displayName
        )

        try await saveUserData(cloudUser)
    }

    // MARK: - Conflict Resolution

    /// Merge two CloudUser objects with smart conflict resolution
    private func mergeCloudUsers(local: CloudUser, cloud: CloudUser) -> CloudUser {
        var merged = local

        // Merge completed days (union)
        let mergedDays = Set(local.completedDays).union(Set(cloud.completedDays))
        merged.completedDays = Array(mergedDays).sorted()

        // Take the higher streak values
        merged.currentStreak = max(local.currentStreak, cloud.currentStreak)
        merged.longestStreak = max(local.longestStreak, cloud.longestStreak)

        // Take the most recent read date
        if let cloudDate = cloud.lastReadDate, let localDate = local.lastReadDate {
            merged.lastReadDate = max(cloudDate, localDate)
        } else {
            merged.lastReadDate = cloud.lastReadDate ?? local.lastReadDate
        }

        // Merge completed lessons (union)
        let mergedLessons = Set(local.completedLessonIds).union(Set(cloud.completedLessonIds))
        merged.completedLessonIds = Array(mergedLessons)

        // Premium status: cloud wins (server is source of truth for purchases)
        if cloud.isPremium {
            merged.isPremium = true
            merged.premiumExpiresAt = cloud.premiumExpiresAt
        }

        // Keep the earlier creation date
        merged.createdAt = min(local.createdAt, cloud.createdAt)

        return merged
    }

    // MARK: - Real-time Listener

    /// Listen for real-time updates to user data
    nonisolated func addUserDataListener(
        userId: String,
        onChange: @escaping (CloudUser?) -> Void
    ) -> ListenerRegistration {
        return Firestore.firestore()
            .collection(usersCollection)
            .document(userId)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    onChange(nil)
                    return
                }

                let cloudUser = try? snapshot.data(as: CloudUser.self)
                onChange(cloudUser)
            }
    }

    // MARK: - Premium Status

    /// Update premium status in cloud
    func updatePremiumStatus(isPremium: Bool, expiresAt: Date? = nil) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw SyncError.notAuthenticated
        }

        var data: [String: Any] = ["isPremium": isPremium]
        if let expiresAt = expiresAt {
            data["premiumExpiresAt"] = Timestamp(date: expiresAt)
        }

        do {
            try await db.collection(usersCollection).document(userId).updateData(data)
        } catch {
            throw SyncError.networkError(error)
        }
    }
}
