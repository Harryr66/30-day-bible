import SwiftUI
import SwiftData

struct DailyReadingView: View {
    let day: ReadingDay
    var sessionManager: SessionManager?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var progress: [UserProgress]
    @StateObject private var viewModel = ReadingViewModel()
    @State private var currentStep = 0
    @State private var showCompletionCelebration = false
    @State private var animateContent = false
    @State private var showMiniTestPrompt = false
    @State private var navigateToMiniTest = false
    @State private var showSessionLimitPaywall = false
    @State private var sessionRecorded = false

    init(day: ReadingDay, sessionManager: SessionManager? = nil) {
        self.day = day
        self.sessionManager = sessionManager
    }

    private var userProgress: UserProgress {
        if let existing = progress.first {
            return existing
        }
        let newProgress = UserProgress()
        modelContext.insert(newProgress)
        return newProgress
    }

    // Total steps: intro + verses + memory verse + complete
    private var totalSteps: Int {
        let verseCount = viewModel.passage?.verses.count ?? 0
        return 1 + verseCount + 1 + 1 // intro + verses + memory + complete
    }

    private var progressPercentage: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(currentStep) / Double(totalSteps - 1)
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar at top
                progressBar
                    .padding(.horizontal)
                    .padding(.top, 8)

                // Main content area
                ZStack {
                    if viewModel.isLoading {
                        loadingView
                    } else {
                        stepContent
                            .id(currentStep) // Force refresh on step change
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom navigation
                bottomNavigation
                    .padding()
                    .padding(.bottom, 80)
                    .background(Color.appCardBackground)
            }

            // Celebration overlay
            if showCompletionCelebration {
                celebrationOverlay
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("Day \(day.id)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
            }
        }
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Record session start if we have a session manager
            if let manager = sessionManager, !sessionRecorded {
                if manager.tryStartSession() {
                    sessionRecorded = true
                } else {
                    // Paywall will be shown by the session manager
                    return
                }
            } else if !sessionRecorded {
                // Record session directly if no session manager provided
                userProgress.recordSessionStart()
                sessionRecorded = true
            }

            viewModel.loadPassage(for: day)
            withAnimation(.easeOut(duration: 0.3)) {
                animateContent = true
            }
        }
        .onChange(of: sessionManager?.showSessionLimitPaywall ?? false) { _, newValue in
            showSessionLimitPaywall = newValue
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appCardBackgroundLight)
                    .frame(height: 12)

                // Progress fill
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [.appGreen, .appTeal],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progressPercentage, height: 12)
                    .animation(.spring(response: 0.4), value: progressPercentage)
            }
        }
        .frame(height: 12)
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                if currentStep == 0 {
                    // Step 0: Introduction
                    introductionStep
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else if let passage = viewModel.passage, currentStep <= passage.verses.count {
                    // Verse steps
                    let verseIndex = currentStep - 1
                    if verseIndex < passage.verses.count {
                        verseStep(passage.verses[verseIndex], index: verseIndex + 1, total: passage.verses.count)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                } else if currentStep == (viewModel.passage?.verses.count ?? 0) + 1 {
                    // Memory verse step
                    if let memoryVerse = viewModel.memoryVerse {
                        memoryVerseStep(memoryVerse)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                } else {
                    // Final completion step
                    completionStep
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .padding()
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
        }
    }

    // MARK: - Introduction Step

    private var introductionStep: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)

            // Day badge
            Text("DAY \(day.id)")
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
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

            // Title
            Text(day.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)

            // Reference
            Text(day.reference)
                .font(.title3)
                .foregroundStyle(Color.appYellow)

            // Theme badge
            Text(day.theme.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(Color.appPurple)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.appPurple.opacity(0.2)))

            Spacer().frame(height: 20)

            // Dove mascot
            MascotView(mood: .encouraging, size: 120)

            // Instructions
            Text("Let's read through today's passage together!")
                .font(.body)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // XP preview
            HStack(spacing: 8) {
                Text("⭐️")
                    .font(.title2)
                Text("+50 XP")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appYellow)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color.appYellow.opacity(0.15)))

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Verse Step

    private func verseStep(_ verse: BibleVerse, index: Int, total: Int) -> some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 40)

            // Verse counter
            Text("Verse \(index) of \(total)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appTextSecondary)

            // Book icon
            Text("📖")
                .font(.system(size: 50))

            // Verse text in card
            VStack(spacing: 16) {
                Text(verse.text)
                    .font(.title3)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineSpacing(8)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                // Reference
                Text("— \(verse.reference)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appYellow)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.appCardBackground)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
            )

            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: - Memory Verse Step

    private func memoryVerseStep(_ verse: BibleVerse) -> some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 40)

            // Header
            Text("Memory Verse")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appTextSecondary)

            // Brain icon
            Text("🧠")
                .font(.system(size: 50))

            // Memory verse card
            VStack(spacing: 16) {
                Text("Try to memorize this verse!")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)

                Text("\"\(verse.text)\"")
                    .font(.title3)
                    .fontWeight(.medium)
                    .italic()
                    .foregroundStyle(Color.appTextPrimary)
                    .lineSpacing(8)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("— \(verse.reference)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appPurple)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.appPurple.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.appPurple.opacity(0.3), lineWidth: 2)
                    )
            )

            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: - Completion Step

    private var completionStep: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 40)

            // Celebration
            Text("🎉")
                .font(.system(size: 60))

            Text("Great Job!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.appTextPrimary)

            Text("You've read through all of today's passage.")
                .font(.body)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

            // Mascot
            MascotView(mood: .excited, size: 100)

            // Summary card
            VStack(spacing: 12) {
                HStack {
                    Text("📖")
                    Text("\(viewModel.passage?.verses.count ?? 0) verses read")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.appGreen)
                }

                Divider()

                HStack {
                    Text("🧠")
                    Text("Memory verse learned")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.appGreen)
                }

                Divider()

                HStack {
                    Text("⭐️")
                    Text("+50 XP earned")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appYellow)
                    Spacer()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appCardBackground)
            )

            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: - Bottom Navigation

    private var bottomNavigation: some View {
        HStack(spacing: 16) {
            // Back button (hidden on first step)
            if currentStep > 0 {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        currentStep -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(Color.appCardBackgroundLight)
                        )
                }
            } else {
                Spacer().frame(width: 50)
            }

            Spacer()

            // Continue / Complete button
            Button {
                if isLastStep {
                    markComplete()
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        currentStep += 1
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(buttonTitle)
                        .font(.headline)
                        .fontWeight(.black)

                    if !isLastStep {
                        Image(systemName: "chevron.right")
                            .font(.headline)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isLastStep ? Color.appGreenDark : Color.appBlueDark)
                            .offset(y: 4)
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isLastStep ? Color.appGreen : Color.appBlue)
                    }
                )
            }
        }
    }

    private var isLastStep: Bool {
        currentStep >= totalSteps - 1
    }

    private var buttonTitle: String {
        if currentStep == 0 {
            return "START READING"
        } else if isLastStep {
            return "COMPLETE LESSON"
        } else {
            return "CONTINUE"
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.appGreen)
                .scaleEffect(1.5)

            Text("Loading lesson...")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Celebration Overlay

    private var celebrationOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

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

                // Mini Test Prompt
                if showMiniTestPrompt {
                    VStack(spacing: 16) {
                        Text("Ready to test your knowledge?")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)

                        HStack(spacing: 16) {
                            Button {
                                dismiss()
                            } label: {
                                Text("Skip")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            .frame(width: 100)

                            NavigationLink {
                                MiniTestView(day: day, verses: viewModel.passage?.verses ?? [])
                            } label: {
                                Text("Take Mini Test")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .background(
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.appPurpleDark)
                                                .offset(y: 3)
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.appPurple)
                                        }
                                    )
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.appCardBackground.opacity(0.95))
                    )
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Button {
                        dismiss()
                    } label: {
                        Text("CONTINUE")
                            .font(.headline)
                            .fontWeight(.black)
                    }
                    .buttonStyle(PlayfulButtonStyle(color: .appGreen))
                    .padding(.horizontal, 40)
                    .padding(.top, 16)
                }
            }
            .padding()

            // Confetti particles
            CelebrationView()
        }
        .onAppear {
            // Show mini test prompt after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showMiniTestPrompt = true
                }
            }
        }
    }

    // MARK: - Actions

    private func markComplete() {
        userProgress.markDayComplete(day.id)

        // Save to SwiftData
        try? modelContext.save()

        // Save to shared container for widget
        let shared = SharedProgress.fromUserProgress(userProgress)
        shared.save()

        withAnimation(.spring(response: 0.5)) {
            showCompletionCelebration = true
        }
    }
}

#Preview {
    NavigationStack {
        DailyReadingView(day: ReadingPlan.days[0])
    }
    .environmentObject(StoreViewModel())
}
