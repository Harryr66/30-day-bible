import Foundation
import SwiftUI
import Combine

/// Observable object to track and manage session limits for free users
@MainActor
class SessionManager: ObservableObject {
    /// Whether the session limit paywall should be shown
    @Published var showSessionLimitPaywall = false

    /// Remaining sessions for display
    @Published var remainingSessions: Int = UserProgress.freeSessionLimit

    /// Time until next session becomes available (for display)
    @Published var timeUntilNextSession: TimeInterval?

    /// Formatted time string for display
    @Published var formattedTimeRemaining: String = ""

    /// Reference to user progress for checking session state
    private var userProgress: UserProgress?

    /// Timer for refreshing session state
    private var refreshTimer: Timer?

    init() {
        startRefreshTimer()
    }

    deinit {
        refreshTimer?.invalidate()
    }

    /// Update the session manager with current user progress
    func update(with progress: UserProgress) {
        self.userProgress = progress
        refreshState()
    }

    /// Attempt to start a session. Returns true if allowed, false if limit reached.
    /// If limit reached, triggers the paywall.
    @discardableResult
    func tryStartSession() -> Bool {
        guard let progress = userProgress else { return true }

        if progress.canStartSession {
            progress.recordSessionStart()
            refreshState()
            return true
        } else {
            showSessionLimitPaywall = true
            return false
        }
    }

    /// Check if a session can be started without actually starting one
    func canStartSession() -> Bool {
        userProgress?.canStartSession ?? true
    }

    /// Dismiss the session limit paywall
    func dismissPaywall() {
        showSessionLimitPaywall = false
    }

    /// Refresh the session state (called periodically and on demand)
    func refreshState() {
        guard let progress = userProgress else {
            remainingSessions = UserProgress.freeSessionLimit
            timeUntilNextSession = nil
            formattedTimeRemaining = ""
            return
        }

        remainingSessions = progress.remainingSessions
        timeUntilNextSession = progress.timeUntilNextSession
        formattedTimeRemaining = formatTimeRemaining(progress.timeUntilNextSession)
    }

    /// Start a timer to refresh state every minute
    private func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshState()
            }
        }
    }

    /// Format time interval as "Xh Ym" or "Xm"
    private func formatTimeRemaining(_ interval: TimeInterval?) -> String {
        guard let interval = interval, interval > 0 else { return "" }

        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "< 1m"
        }
    }

    /// Display string for remaining sessions
    var sessionsDisplayText: String {
        guard let progress = userProgress else {
            return "\(UserProgress.freeSessionLimit)"
        }

        if progress.isPremium {
            return "∞"
        }

        return "\(remainingSessions)"
    }

    /// Whether to show the upgrade prompt
    var shouldShowUpgradePrompt: Bool {
        guard let progress = userProgress else { return false }
        return !progress.isPremium && remainingSessions <= 2
    }

    /// Progress percentage for visual indicator (0.0 to 1.0)
    var sessionProgressPercentage: Double {
        guard let progress = userProgress, !progress.isPremium else { return 1.0 }
        return Double(remainingSessions) / Double(UserProgress.freeSessionLimit)
    }
}
