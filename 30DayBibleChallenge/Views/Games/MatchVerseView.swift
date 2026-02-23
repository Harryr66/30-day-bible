import SwiftUI
import SwiftData

struct MatchVerseView: View {
    let day: ReadingDay
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ReadingViewModel()
    @State private var currentRound = 0
    @State private var score = 0
    @State private var isComplete = false
    @State private var showCelebration = false
    @State private var rounds: [MatchRound] = []

    private let totalRounds = 3

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                progressBar
                    .padding()

                if viewModel.isLoading {
                    loadingView
                } else if isComplete {
                    completionView
                } else if currentRound < rounds.count {
                    MatchRoundView(
                        round: rounds[currentRound],
                        onComplete: { correct in
                            handleRoundComplete(correct: correct)
                        }
                    )
                } else {
                    loadingView
                }
            }

            if showCelebration {
                CelebrationView()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Match Verse")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(currentRound + 1)/\(totalRounds)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .onAppear {
            viewModel.loadPassage(for: day)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                generateRounds()
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appBeige)
                    .frame(height: 12)

                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [.appTeal, .appBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * Double(currentRound) / Double(totalRounds), height: 12)
                    .animation(.spring(response: 0.4), value: currentRound)
            }
        }
        .frame(height: 12)
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Color.appTeal)
                .scaleEffect(1.5)
            Text("Loading verses...")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxHeight: .infinity)
    }

    private var completionView: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.appTeal.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Text(score >= 2 ? "🏆" : "⭐️")
                        .font(.system(size: 60))
                }
                .bounceIn(delay: 0)

                Text("Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
                    .bounceIn(delay: 0.1)

                VStack(spacing: 16) {
                    HStack(spacing: 24) {
                        VStack(spacing: 4) {
                            Text("\(score)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(Color.appGreen)
                            Text("Correct")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                        }

                        Rectangle()
                            .fill(Color.appBeige)
                            .frame(width: 1, height: 60)

                        VStack(spacing: 4) {
                            Text("\(totalRounds)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(Color.appTextPrimary)
                            Text("Rounds")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                }
                .padding()
                .playfulCard()
                .bounceIn(delay: 0.2)

                HStack(spacing: 8) {
                    Text("⭐️")
                        .font(.title2)
                    Text("+\(score * 10) XP earned!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appYellow)
                }
                .padding()
                .background(Capsule().fill(Color.appYellow.opacity(0.2)))
                .bounceIn(delay: 0.3)

                Button {
                    saveScore()
                    dismiss()
                } label: {
                    Text("Done")
                        .fontWeight(.bold)
                }
                .buttonStyle(PlayfulButtonStyle(color: .appTeal))
                .padding()
                .bounceIn(delay: 0.4)
            }
            .padding()
        }
    }

    private func generateRounds() {
        guard let passage = viewModel.passage, passage.verses.count >= 3 else { return }

        var generatedRounds: [MatchRound] = []

        for i in 0..<totalRounds {
            let startIndex = (i * 3) % max(1, passage.verses.count - 2)
            let versesToUse = Array(passage.verses.dropFirst(startIndex).prefix(3))

            if versesToUse.count >= 3 {
                let pairs = versesToUse.map { verse in
                    MatchPair(
                        verseSnippet: String(verse.text.prefix(60)) + (verse.text.count > 60 ? "..." : ""),
                        reference: verse.reference
                    )
                }
                generatedRounds.append(MatchRound(pairs: pairs))
            }
        }

        if generatedRounds.isEmpty {
            // Fallback: use all available verses
            let pairs = passage.verses.prefix(3).map { verse in
                MatchPair(
                    verseSnippet: String(verse.text.prefix(60)) + (verse.text.count > 60 ? "..." : ""),
                    reference: verse.reference
                )
            }
            for _ in 0..<totalRounds {
                generatedRounds.append(MatchRound(pairs: Array(pairs)))
            }
        }

        rounds = generatedRounds
    }

    private func handleRoundComplete(correct: Bool) {
        if correct {
            score += 1
            showCelebration = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showCelebration = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if currentRound < totalRounds - 1 {
                withAnimation {
                    currentRound += 1
                }
            } else {
                withAnimation {
                    isComplete = true
                }
            }
        }
    }

    private func saveScore() {
        let gameScore = GameScore(
            gameType: .matchVerse,
            score: score,
            totalQuestions: totalRounds,
            dayNumber: day.id
        )
        modelContext.insert(gameScore)
    }
}

struct MatchPair: Identifiable {
    let id = UUID()
    let verseSnippet: String
    let reference: String
}

struct MatchRound {
    let pairs: [MatchPair]
}

struct MatchRoundView: View {
    let round: MatchRound
    let onComplete: (Bool) -> Void

    @State private var selectedVerseIndex: Int?
    @State private var selectedRefIndex: Int?
    @State private var matches: [(verse: String, reference: String)] = []
    @State private var availableVerses: [MatchPair] = []
    @State private var availableRefs: [String] = []
    @State private var isSubmitted = false
    @State private var isCorrect = false
    @State private var showMascot = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Instructions
                Text("Match each verse to its reference")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.top)

                // Matched pairs
                if !matches.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(Array(matches.enumerated()), id: \.offset) { index, match in
                            HStack {
                                Text(String(match.verse.prefix(25)) + "...")
                                    .font(.caption)
                                    .foregroundStyle(Color.appGreen)
                                    .lineLimit(1)

                                Image(systemName: "arrow.right")
                                    .font(.caption)
                                    .foregroundStyle(Color.appGreen)

                                Text(match.reference)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.appGreen)

                                Spacer()

                                if !isSubmitted {
                                    Button {
                                        unmatch(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(Color.appRed.opacity(0.7))
                                    }
                                }
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.appGreen.opacity(0.1))
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                // Available verses
                if !availableVerses.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Verses")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appTextSecondary)
                            .padding(.horizontal)

                        ForEach(Array(availableVerses.enumerated()), id: \.element.id) { index, pair in
                            Button {
                                selectVerse(index)
                            } label: {
                                Text(pair.verseSnippet)
                                    .font(.subheadline)
                                    .foregroundStyle(selectedVerseIndex == index ? Color.appTeal : Color.appTextPrimary)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedVerseIndex == index ? Color.appTeal.opacity(0.15) : Color.appCardBackground)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedVerseIndex == index ? Color.appTeal : Color.appTextSecondary.opacity(0.2), lineWidth: selectedVerseIndex == index ? 2 : 1)
                                    )
                            }
                            .buttonStyle(.plain)
                            .disabled(isSubmitted)
                            .padding(.horizontal)
                        }
                    }
                }

                // Available references
                if !availableRefs.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("References")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appTextSecondary)
                            .padding(.horizontal)

                        FlowLayout(spacing: 8) {
                            ForEach(Array(availableRefs.enumerated()), id: \.offset) { index, ref in
                                Button {
                                    selectRef(index)
                                } label: {
                                    Text(ref)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(selectedRefIndex == index ? Color.appTeal : Color.appTextPrimary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(selectedRefIndex == index ? Color.appTeal.opacity(0.15) : Color.appCardBackground)
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(selectedRefIndex == index ? Color.appTeal : Color.appTextSecondary.opacity(0.3), lineWidth: selectedRefIndex == index ? 2 : 1)
                                        )
                                }
                                .buttonStyle(.plain)
                                .disabled(isSubmitted)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Submit button
                if availableVerses.isEmpty && availableRefs.isEmpty && !isSubmitted {
                    Button {
                        submitAnswer()
                    } label: {
                        HStack {
                            Text("Check Answer")
                                .fontWeight(.bold)
                            Image(systemName: "checkmark")
                        }
                    }
                    .buttonStyle(PlayfulButtonStyle(color: .appGreen))
                    .padding(.horizontal)
                }

                // Feedback
                if isSubmitted {
                    HStack(spacing: 12) {
                        MascotView(mood: isCorrect ? .excited : .sad, size: 60)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(isCorrect ? "Perfect!" : "Not quite...")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(isCorrect ? Color.appGreen : Color.appOrange)

                            Text(isCorrect ? "All matches correct!" : "Some matches were wrong")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                        }

                        Spacer()

                        if isCorrect {
                            Text("+10 XP")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.appYellow)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.appYellow.opacity(0.2)))
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isCorrect ? Color.appGreen.opacity(0.1) : Color.appOrange.opacity(0.1))
                    )
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer(minLength: 100)
            }
        }
        .onAppear {
            setupRound()
        }
    }

    private func setupRound() {
        availableVerses = round.pairs
        availableRefs = round.pairs.map { $0.reference }.shuffled()
        matches = []
        selectedVerseIndex = nil
        selectedRefIndex = nil
        isSubmitted = false
        isCorrect = false
    }

    private func selectVerse(_ index: Int) {
        if selectedVerseIndex == index {
            selectedVerseIndex = nil
        } else {
            selectedVerseIndex = index
            tryMatch()
        }
    }

    private func selectRef(_ index: Int) {
        if selectedRefIndex == index {
            selectedRefIndex = nil
        } else {
            selectedRefIndex = index
            tryMatch()
        }
    }

    private func tryMatch() {
        guard let verseIdx = selectedVerseIndex, let refIdx = selectedRefIndex else { return }

        let verse = availableVerses[verseIdx]
        let ref = availableRefs[refIdx]

        withAnimation(.spring(response: 0.3)) {
            matches.append((verse.verseSnippet, ref))
            availableVerses.remove(at: verseIdx)
            availableRefs.remove(at: refIdx)
            selectedVerseIndex = nil
            selectedRefIndex = nil
        }
    }

    private func unmatch(at index: Int) {
        let match = matches[index]
        let originalPair = round.pairs.first { $0.verseSnippet == match.verse }

        withAnimation(.spring(response: 0.3)) {
            matches.remove(at: index)
            if let pair = originalPair {
                availableVerses.append(pair)
            }
            availableRefs.append(match.reference)
        }
    }

    private func submitAnswer() {
        // Check if all matches are correct
        var allCorrect = true
        for match in matches {
            if let correctPair = round.pairs.first(where: { $0.verseSnippet == match.verse }) {
                if correctPair.reference != match.reference {
                    allCorrect = false
                    break
                }
            } else {
                allCorrect = false
                break
            }
        }

        isCorrect = allCorrect
        withAnimation(.spring(response: 0.4)) {
            isSubmitted = true
        }

        onComplete(isCorrect)
    }
}

#Preview {
    NavigationStack {
        MatchVerseView(day: ReadingPlan.days[0])
    }
}
