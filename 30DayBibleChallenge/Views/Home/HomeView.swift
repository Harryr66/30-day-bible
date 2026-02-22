import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var selectedDay: Int?
    @Environment(\.modelContext) private var modelContext
    @Query private var progress: [UserProgress]
    @StateObject private var viewModel = ReadingViewModel()
    @State private var showDailyReading = false
    @State private var animateStats = false
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

    private var todayReading: ReadingDay {
        ReadingPlan.today()
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Top stats bar
                    statsBar
                        .bounceIn(delay: 0)

                    // Mascot greeting
                    mascotSection
                        .bounceIn(delay: 0.1)

                    // Daily goal progress
                    dailyGoalCard
                        .bounceIn(delay: 0.2)

                    // Today's lesson card
                    todayLessonCard
                        .bounceIn(delay: 0.3)

                    // Quick practice buttons
                    practiceSection
                        .bounceIn(delay: 0.4)
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("30 Day Bible")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appTextPrimary)
                }
            }
            .navigationDestination(isPresented: $showDailyReading) {
                DailyReadingView(day: todayReading)
            }
            .navigationDestination(item: $selectedGame) { gameType in
                switch gameType {
                case .quiz:
                    QuizView(day: todayReading)
                case .memoryVerse:
                    MemoryVerseView(day: todayReading)
                case .fillBlank:
                    FillBlankView(day: todayReading)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .onChange(of: selectedDay) { _, newValue in
                if newValue != nil {
                    showDailyReading = true
                }
            }
            .onAppear {
                viewModel.loadPassage(for: todayReading)
                withAnimation(.spring(response: 0.6).delay(0.5)) {
                    animateStats = true
                }
            }
        }
    }

    private var statsBar: some View {
        HStack(spacing: 16) {
            StreakBadge(days: userProgress.currentStreak)

            Spacer()

            XPBadge(amount: userProgress.completedDays.count * 50)

            HeartsView(hearts: 5)
        }
        .padding(.horizontal, 4)
    }

    private var mascotSection: some View {
        HStack(spacing: 20) {
            MascotView(mood: greetingMood, size: 80)

            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)

                Text(motivationalMessage)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: greetingMood == .sad ? [Color.appBlue.opacity(0.1), Color.appBlue.opacity(0.05)] : [Color.appGreen.opacity(0.1), Color.appGreen.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(greetingMood == .sad ? Color.appBlue.opacity(0.2) : Color.appGreen.opacity(0.2), lineWidth: 2)
        )
    }

    private var greetingMood: MascotView.MascotMood {
        if userProgress.currentStreak == 0 { return .sad }
        if userProgress.currentStreak >= 7 { return .excited }
        if userProgress.currentStreak >= 1 { return .happy }
        return .encouraging
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning! ☀️"
        case 12..<17: return "Good afternoon! 🌤"
        default: return "Good evening! 🌙"
        }
    }

    private var motivationalMessage: String {
        if userProgress.currentStreak == 0 {
            return "I miss you! Let's read together today!"
        } else if userProgress.currentStreak >= 7 {
            return "WOW! \(userProgress.currentStreak) day streak! You're amazing!"
        } else if userProgress.currentStreak >= 3 {
            return "\(userProgress.currentStreak) day streak! Keep going!"
        } else {
            return "Great start! \(userProgress.currentStreak) day streak!"
        }
    }

    private var dailyGoalCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Goal")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appTextPrimary)

                    Text("Complete today's reading")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer()

                ZStack {
                    ProgressRing(
                        progress: userProgress.isDayComplete(todayReading.id) ? 1.0 : 0.0,
                        size: 50,
                        lineWidth: 6,
                        color: .appGreen
                    )

                    if userProgress.isDayComplete(todayReading.id) {
                        Image(systemName: "checkmark")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appGreen)
                    } else {
                        Text("0/1")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.appCardBackgroundLight)
                        .frame(height: 16)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.appGreen, .appTeal],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: animateStats && userProgress.isDayComplete(todayReading.id) ? geo.size.width : 0, height: 16)
                }
            }
            .frame(height: 16)
        }
        .padding()
        .playfulCard()
    }

    private var todayLessonCard: some View {
        Button {
            showDailyReading = true
        } label: {
            VStack(spacing: 16) {
                HStack {
                    // Day badge
                    Text("DAY \(todayReading.id)")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.appBrown, .appBrownDark],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )

                    Spacer()

                    if userProgress.isDayComplete(todayReading.id) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("COMPLETE")
                        }
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appGreen)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text("~5 MIN")
                        }
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                    }
                }

                // Title and theme
                VStack(alignment: .leading, spacing: 8) {
                    Text(todayReading.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appTextPrimary)
                        .multilineTextAlignment(.leading)

                    Text(todayReading.reference)
                        .font(.subheadline)
                        .foregroundStyle(Color.appYellow)

                    // Theme tag
                    Text(todayReading.theme.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appPurple)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.appPurple.opacity(0.2)))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Start button
                HStack {
                    Text(userProgress.isDayComplete(todayReading.id) ? "REVIEW" : "START")
                        .font(.headline)
                        .fontWeight(.black)

                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [.appBrown, .appBrownDark],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
            }
            .padding()
            .playfulCard()
        }
        .buttonStyle(.plain)
    }

    private var practiceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Practice")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color.appTextPrimary)

            HStack(spacing: 12) {
                PracticeButton(
                    title: "Quiz",
                    icon: "questionmark.circle.fill",
                    color: .appOrange,
                    locked: !userProgress.isPremium
                ) {
                    if userProgress.isPremium {
                        selectedGame = .quiz
                    } else {
                        showPaywall = true
                    }
                }

                PracticeButton(
                    title: "Memory",
                    icon: "brain.head.profile",
                    color: .appPurple,
                    locked: !userProgress.isPremium
                ) {
                    if userProgress.isPremium {
                        selectedGame = .memoryVerse
                    } else {
                        showPaywall = true
                    }
                }

                PracticeButton(
                    title: "Fill",
                    icon: "text.badge.checkmark",
                    color: .appBlue,
                    locked: !userProgress.isPremium
                ) {
                    if userProgress.isPremium {
                        selectedGame = .fillBlank
                    } else {
                        showPaywall = true
                    }
                }
            }
        }
    }
}

struct PracticeButton: View {
    let title: String
    let icon: String
    let color: Color
    let locked: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)

                    if locked {
                        Circle()
                            .fill(.black.opacity(0.5))
                            .frame(width: 50, height: 50)

                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                }

                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .playfulCard()
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

#Preview {
    HomeView(selectedDay: .constant(nil))
        .environmentObject(StoreViewModel())
}
