import SwiftUI
import SwiftData

struct GamesMenuView: View {
    @EnvironmentObject var storeViewModel: StoreViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var progress: [UserProgress]
    @Query(sort: \GameScore.dateCompleted, order: .reverse) private var scores: [GameScore]
    @State private var showPaywall = false
    @State private var selectedGame: GameType?

    private var userProgress: UserProgress {
        if let existing = progress.first {
            return existing
        }
        let newProgress = UserProgress()
        modelContext.insert(newProgress)
        return newProgress
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header with mascot
                    headerSection
                        .bounceIn(delay: 0)

                    // Game cards
                    gameCards
                        .bounceIn(delay: 0.1)

                    // Recent activity
                    if !scores.isEmpty {
                        recentActivity
                            .bounceIn(delay: 0.2)
                    }
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Practice")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appTextPrimary)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .navigationDestination(item: $selectedGame) { gameType in
                gameDestination(for: gameType)
            }
        }
    }

    private var headerSection: some View {
        HStack(spacing: 16) {
            MascotView(mood: .encouraging, size: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text("Time to practice! 💪")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)

                Text("Strengthen your Bible knowledge")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer()
        }
        .padding()
        .playfulCard()
    }

    private var gameCards: some View {
        VStack(spacing: 16) {
            GameCard(
                title: "Quiz Challenge",
                description: "Test your knowledge with fun questions",
                icon: "❓",
                color: .appOrange,
                xpReward: 30,
                isLocked: !userProgress.isPremium,
                bestScore: bestScore(for: .quiz)
            ) {
                if userProgress.isPremium {
                    selectedGame = .quiz
                } else {
                    showPaywall = true
                }
            }

            GameCard(
                title: "Memory Verses",
                description: "Master key scriptures with flashcards",
                icon: "🧠",
                color: .appPurple,
                xpReward: 25,
                isLocked: !userProgress.isPremium,
                bestScore: bestScore(for: .memoryVerse)
            ) {
                if userProgress.isPremium {
                    selectedGame = .memoryVerse
                } else {
                    showPaywall = true
                }
            }

            GameCard(
                title: "Fill the Blank",
                description: "Complete passages from memory",
                icon: "✍️",
                color: .appBlue,
                xpReward: 35,
                isLocked: !userProgress.isPremium,
                bestScore: bestScore(for: .fillBlank)
            ) {
                if userProgress.isPremium {
                    selectedGame = .fillBlank
                } else {
                    showPaywall = true
                }
            }
        }
    }

    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color.appTextPrimary)

            VStack(spacing: 8) {
                ForEach(scores.prefix(3)) { score in
                    ActivityRow(score: score)
                }
            }
            .padding()
            .playfulCard()
        }
    }

    private func bestScore(for gameType: GameType) -> Int? {
        scores
            .filter { $0.type == gameType }
            .map { Int($0.percentage) }
            .max()
    }

    @ViewBuilder
    private func gameDestination(for gameType: GameType) -> some View {
        switch gameType {
        case .quiz:
            QuizView(day: ReadingPlan.today())
        case .memoryVerse:
            MemoryVerseView(day: ReadingPlan.today())
        case .fillBlank:
            FillBlankView(day: ReadingPlan.today())
        }
    }
}

struct GameCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let xpReward: Int
    let isLocked: Bool
    let bestScore: Int?
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.opacity(0.2))
                        .frame(width: 60, height: 60)

                    Text(icon)
                        .font(.title)

                    if isLocked {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.black.opacity(0.5))
                            .frame(width: 60, height: 60)

                        Image(systemName: "lock.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appTextPrimary)

                    Text(description)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)

                    HStack(spacing: 12) {
                        // XP reward
                        HStack(spacing: 4) {
                            Text("⭐️")
                                .font(.caption2)
                            Text("+\(xpReward) XP")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.appYellow)
                        }

                        // Best score
                        if let best = bestScore {
                            HStack(spacing: 4) {
                                Text("🏆")
                                    .font(.caption2)
                                Text("\(best)%")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.appGreen)
                            }
                        }
                    }
                }

                Spacer()

                // Play button
                ZStack {
                    Circle()
                        .fill(isLocked ? Color.appCardBackgroundLight : color)
                        .frame(width: 44, height: 44)

                    Image(systemName: isLocked ? "lock.fill" : "play.fill")
                        .font(.body)
                        .foregroundStyle(isLocked ? Color.appTextSecondary : .white)
                }
            }
            .padding()
            .playfulCard()
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct ActivityRow: View {
    let score: GameScore

    var scoreColor: Color {
        switch score.percentage {
        case 80...100: return .appGreen
        case 60..<80: return .appYellow
        default: return .appOrange
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Game icon
            Text(gameIcon)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(score.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.appTextPrimary)

                Text("Day \(score.dayNumber) • \(timeAgo)")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer()

            // Score
            Text("\(Int(score.percentage))%")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(scoreColor)
        }
    }

    private var gameIcon: String {
        switch score.type {
        case .quiz: return "❓"
        case .memoryVerse: return "🧠"
        case .fillBlank: return "✍️"
        }
    }

    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: score.dateCompleted, relativeTo: Date())
    }
}

#Preview {
    GamesMenuView()
        .environmentObject(StoreViewModel())
}
