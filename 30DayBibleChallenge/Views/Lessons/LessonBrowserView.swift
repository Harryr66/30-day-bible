import SwiftUI
import SwiftData

/// Browse all available lessons with category filtering and search
struct LessonBrowserView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var progress: [UserProgress]
    @EnvironmentObject var storeViewModel: StoreViewModel
    @StateObject private var sessionManager = SessionManager()

    @State private var searchText = ""
    @State private var selectedCategory: LessonCategory?
    @State private var selectedLesson: Lesson?
    @State private var showPaywall = false
    @State private var showSessionLimitPaywall = false

    private var userProgress: UserProgress {
        if let existing = progress.first {
            return existing
        }
        let newProgress = UserProgress()
        modelContext.insert(newProgress)
        return newProgress
    }

    private var filteredLessons: [Lesson] {
        var lessons = selectedCategory.map { LessonCatalog.lessons(for: $0) } ?? LessonCatalog.allLessons

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            lessons = lessons.filter { lesson in
                lesson.title.lowercased().contains(query) ||
                lesson.theme.lowercased().contains(query) ||
                lesson.book.lowercased().contains(query)
            }
        }

        return lessons
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Session status card
                    sessionStatusCard
                        .bounceIn(delay: 0)

                    // Today's Pick
                    todaysPickCard
                        .bounceIn(delay: 0.1)

                    // Category filter
                    categoryFilter
                        .bounceIn(delay: 0.2)

                    // Lesson grid
                    lessonGrid
                        .bounceIn(delay: 0.3)
                }
                .padding()
                .padding(.bottom, 80)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .searchable(text: $searchText, prompt: "Search lessons...")
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Explore")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appTextPrimary)
                }
            }
            .navigationDestination(item: $selectedLesson) { lesson in
                LessonDetailView(lesson: lesson, sessionManager: sessionManager)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .fullScreenCover(isPresented: $showSessionLimitPaywall) {
                SessionLimitPaywallView(sessionManager: sessionManager)
            }
            .onAppear {
                sessionManager.update(with: userProgress)
            }
            .onChange(of: sessionManager.showSessionLimitPaywall) { _, newValue in
                showSessionLimitPaywall = newValue
            }
        }
    }

    // MARK: - Session Status Card

    private var sessionStatusCard: some View {
        HStack(spacing: 16) {
            // Sessions remaining
            VStack(alignment: .leading, spacing: 4) {
                Text("Sessions Today")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)

                HStack(spacing: 8) {
                    if userProgress.isPremium {
                        Text("∞")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appYellow)
                        Text("UNLIMITED")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appYellow)
                    } else {
                        Text("\(sessionManager.remainingSessions)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(sessionManager.remainingSessions > 0 ? Color.appGreen : Color.appRed)
                        Text("of \(UserProgress.freeSessionLimit)")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }

            Spacer()

            // Time until next session or upgrade button
            if !userProgress.isPremium {
                if sessionManager.remainingSessions == 0 {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Next in")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                        Text(sessionManager.formattedTimeRemaining)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appOrange)
                    }
                } else {
                    Button {
                        showPaywall = true
                    } label: {
                        Text("GO PRO")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.appYellow, Color.appOrange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                }
            }
        }
        .padding()
        .playfulCard()
    }

    // MARK: - Today's Pick Card

    private var todaysPickCard: some View {
        let todaysPick = LessonCatalog.todaysPick()

        return Button {
            if sessionManager.canStartSession() {
                selectedLesson = todaysPick
            } else {
                sessionManager.showSessionLimitPaywall = true
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("TODAY'S PICK")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(Color.appOrange)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text("~\(todaysPick.estimatedMinutes) min")
                    }
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                }

                Text(todaysPick.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.leading)

                Text(todaysPick.reference)
                    .font(.subheadline)
                    .foregroundStyle(Color.appYellow)

                HStack {
                    // Category badge
                    Text(todaysPick.category.rawValue.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appPurple)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.appPurple.opacity(0.2)))

                    // Theme badge
                    Text(todaysPick.theme.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appBrown)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.appBrown.opacity(0.2)))

                    Spacer()

                    // Start button
                    HStack(spacing: 4) {
                        Text("START")
                            .font(.caption)
                            .fontWeight(.black)
                        Image(systemName: "arrow.right")
                            .font(.caption)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.appBlue)
                    )
                }
            }
            .padding()
            .playfulCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color.appTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // All categories button
                    CategoryChip(
                        title: "All",
                        icon: "square.grid.2x2.fill",
                        isSelected: selectedCategory == nil
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = nil
                        }
                    }

                    ForEach(LessonCategory.allCases) { category in
                        CategoryChip(
                            title: category.rawValue,
                            icon: category.icon,
                            isSelected: selectedCategory == category
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCategory = category
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Lesson Grid

    private var lessonGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedCategory?.rawValue ?? "All Lessons")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color.appTextPrimary)

            LazyVStack(spacing: 12) {
                ForEach(filteredLessons) { lesson in
                    LessonCard(
                        lesson: lesson,
                        isCompleted: userProgress.isLessonComplete(lesson.id)
                    ) {
                        if sessionManager.canStartSession() {
                            selectedLesson = lesson
                        } else {
                            sessionManager.showSessionLimitPaywall = true
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(isSelected ? .white : Color.appTextPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color.appBlue : Color.appCardBackground)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.appBrownLight.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Lesson Card

struct LessonCard: View {
    let lesson: Lesson
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Category icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(categoryColor.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: lesson.category.icon)
                        .font(.title3)
                        .foregroundStyle(categoryColor)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(lesson.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(1)

                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(Color.appGreen)
                        }
                    }

                    Text(lesson.reference)
                        .font(.caption)
                        .foregroundStyle(Color.appYellow)

                    HStack(spacing: 8) {
                        Text(lesson.theme)
                            .font(.caption2)
                            .foregroundStyle(Color.appTextSecondary)

                        Text("•")
                            .font(.caption2)
                            .foregroundStyle(Color.appTextSecondary)

                        Text("~\(lesson.estimatedMinutes) min")
                            .font(.caption2)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }

                Spacer()

                // Play button
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.appBlue)
            }
            .padding()
            .playfulCard()
        }
        .buttonStyle(.plain)
    }

    private var categoryColor: Color {
        switch lesson.category {
        case .foundation: return .appBrown
        case .gospels: return .appBlue
        case .epistles: return .appPurple
        case .prophets: return .appOrange
        case .wisdom: return .appYellow
        case .history: return .appGreen
        case .psalms: return .appTeal
        case .revelation: return .appRed
        }
    }
}

// MARK: - Lesson Detail View

struct LessonDetailView: View {
    let lesson: Lesson
    @ObservedObject var sessionManager: SessionManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var progress: [UserProgress]
    @StateObject private var viewModel = ReadingViewModel()
    @State private var currentStep = 0
    @State private var showCompletionCelebration = false
    @State private var animateContent = false

    private var userProgress: UserProgress {
        if let existing = progress.first {
            return existing
        }
        let newProgress = UserProgress()
        modelContext.insert(newProgress)
        return newProgress
    }

    // Create a ReadingDay from the lesson for compatibility
    private var readingDay: ReadingDay {
        ReadingDay(
            id: Int(lesson.id.hashValue % 1000),
            title: lesson.title,
            theme: lesson.theme,
            book: lesson.book,
            startChapter: lesson.startChapter,
            startVerse: lesson.startVerse,
            endChapter: lesson.endChapter,
            endVerse: lesson.endVerse,
            memoryVerse: lesson.memoryVerseReference
        )
    }

    var body: some View {
        DailyReadingView(day: readingDay)
            .onAppear {
                // Record the session start
                if sessionManager.tryStartSession() {
                    // Session started successfully
                }
            }
    }
}

#Preview {
    LessonBrowserView()
        .environmentObject(StoreViewModel())
}
