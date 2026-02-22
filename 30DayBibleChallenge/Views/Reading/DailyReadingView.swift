import SwiftUI
import SwiftData

struct DailyReadingView: View {
    let day: ReadingDay
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var progress: [UserProgress]
    @StateObject private var viewModel = ReadingViewModel()
    @State private var showCompletionCelebration = false
    @State private var currentVerseIndex = 0
    @State private var showAllVerses = false

    private var userProgress: UserProgress {
        if let existing = progress.first {
            return existing
        }
        let newProgress = UserProgress()
        modelContext.insert(newProgress)
        return newProgress
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header card
                    headerCard
                        .bounceIn(delay: 0)

                    // Verse content
                    if let passage = viewModel.passage {
                        verseContent(passage)
                            .bounceIn(delay: 0.1)
                    } else if viewModel.isLoading {
                        loadingView
                    }

                    // Memory verse card
                    if let memoryVerse = viewModel.memoryVerse {
                        memoryVerseCard(memoryVerse)
                            .bounceIn(delay: 0.2)
                    }

                    // Complete button
                    if !userProgress.isDayComplete(day.id) {
                        completeButton
                            .bounceIn(delay: 0.3)
                    }

                    Spacer(minLength: 100)
                }
                .padding()
            }

            // Celebration overlay
            if showCompletionCelebration {
                celebrationOverlay
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Day \(day.id)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
            }

            ToolbarItem(placement: .topBarTrailing) {
                if userProgress.isDayComplete(day.id) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.appGreen)
                }
            }
        }
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            viewModel.loadPassage(for: day)
        }
    }

    private var headerCard: some View {
        VStack(spacing: 16) {
            // Day badge
            HStack {
                Text("DAY \(day.id)")
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

                // XP reward
                HStack(spacing: 4) {
                    Text("⭐️")
                    Text("+50 XP")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appYellow)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(day.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)

                Text(day.reference)
                    .font(.headline)
                    .foregroundStyle(Color.appYellow)

                HStack(spacing: 8) {
                    Text(day.theme.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appPurple)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.appPurple.opacity(0.2)))

                    Text("~5 min read")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .playfulCard()
    }

    private func verseContent(_ passage: BiblePassage) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📖")
                    .font(.title2)
                Text("Scripture")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        showAllVerses.toggle()
                    }
                } label: {
                    Text(showAllVerses ? "Show Less" : "Show All")
                        .font(.caption)
                        .foregroundStyle(Color.appBlue)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                let versesToShow = showAllVerses ? passage.verses : Array(passage.verses.prefix(5))

                ForEach(Array(versesToShow.enumerated()), id: \.element.id) { index, verse in
                    VerseRow(verse: verse, isHighlighted: index == 0)
                }

                if !showAllVerses && passage.verses.count > 5 {
                    Text("+ \(passage.verses.count - 5) more verses")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                }
            }
        }
        .padding()
        .playfulCard()
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.appGreen)
                .scaleEffect(1.5)

            Text("Loading scripture...")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .playfulCard()
    }

    private func memoryVerseCard(_ verse: BibleVerse) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🧠")
                    .font(.title2)
                Text("Memory Verse")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("\"\(verse.text)\"")
                    .font(.body)
                    .italic()
                    .foregroundStyle(Color.appTextPrimary)
                    .lineSpacing(6)

                Text("— \(verse.reference)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appYellow)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appPurple.opacity(0.1))
            )
        }
        .padding()
        .playfulCard()
    }

    private var completeButton: some View {
        Button {
            markComplete()
        } label: {
            HStack(spacing: 12) {
                Text("🎉")
                    .font(.title2)
                Text("COMPLETE LESSON")
                    .font(.headline)
                    .fontWeight(.black)
            }
        }
        .buttonStyle(PlayfulButtonStyle(color: .appBrown))
        .padding(.horizontal)
    }

    private var celebrationOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            VStack(spacing: 24) {
                // Mascot
                MascotView(mood: .excited, size: 100)
                    .scaleEffect(showCompletionCelebration ? 1 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showCompletionCelebration)

                Text("Amazing! 🎉")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("You completed Day \(day.id)!")
                    .font(.title3)
                    .foregroundStyle(Color.appTextSecondary)

                // XP earned
                HStack(spacing: 8) {
                    Text("⭐️")
                        .font(.title)
                    Text("+50 XP")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appYellow)
                }
                .padding()
                .background(Capsule().fill(Color.appYellow.opacity(0.2)))

                // Streak info
                if userProgress.currentStreak > 0 {
                    HStack(spacing: 8) {
                        Text("🔥")
                            .font(.title)
                        Text("\(userProgress.currentStreak) day streak!")
                            .font(.headline)
                            .foregroundStyle(Color.appOrange)
                    }
                }

                Button {
                    dismiss()
                } label: {
                    Text("CONTINUE")
                        .font(.headline)
                        .fontWeight(.black)
                }
                .buttonStyle(PlayfulButtonStyle(color: .appBrown))
                .padding(.horizontal, 40)
                .padding(.top, 16)
            }
            .padding()

            // Confetti particles
            CelebrationView()
        }
    }

    private func markComplete() {
        userProgress.markDayComplete(day.id)

        // Save to shared container for widget
        let shared = SharedProgress.fromUserProgress(userProgress)
        shared.save()

        withAnimation(.spring(response: 0.5)) {
            showCompletionCelebration = true
        }
    }
}

struct VerseRow: View {
    let verse: BibleVerse
    let isHighlighted: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(verse.verse)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(isHighlighted ? Color.appYellow : Color.appTextSecondary)
                .frame(width: 24, alignment: .trailing)

            Text(verse.text)
                .font(.body)
                .foregroundStyle(Color.appTextPrimary)
                .lineSpacing(4)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, isHighlighted ? 12 : 0)
        .background(
            isHighlighted ?
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appYellow.opacity(0.1)) : nil
        )
    }
}

#Preview {
    NavigationStack {
        DailyReadingView(day: ReadingPlan.days[0])
    }
    .environmentObject(StoreViewModel())
}
