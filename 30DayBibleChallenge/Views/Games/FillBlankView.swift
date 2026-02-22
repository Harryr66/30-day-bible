import SwiftUI
import SwiftData

struct FillBlankView: View {
    let day: ReadingDay
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var questions: [FillBlankQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedWords: [String] = []
    @State private var remainingWords: [String] = []
    @State private var isChecking = false
    @State private var isCorrect = false
    @State private var score = 0
    @State private var isComplete = false
    @State private var showCelebration = false

    private var currentQuestion: FillBlankQuestion? {
        questions[safe: currentIndex]
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                progressBar
                    .padding()

                if isComplete {
                    completionView
                } else if let question = currentQuestion {
                    questionView(question)
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
                Text("Fill in the Blank")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
                    Text("✍️")
                    Text("\(currentIndex + 1)/\(questions.count)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
        .onAppear {
            loadQuestions()
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
                            colors: [.appBlue, .appTeal],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * Double(currentIndex) / Double(max(questions.count, 1)), height: 12)
                    .animation(.spring(response: 0.4), value: currentIndex)
            }
        }
        .frame(height: 12)
    }

    private func questionView(_ question: FillBlankQuestion) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Reference badge
                HStack(spacing: 8) {
                    Text("📖")
                    Text(question.verseReference)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appBrown)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(Color.appBrown.opacity(0.1))
                )

                // Passage with blanks
                passageView(question)

                RusticDivider()

                // Word bank
                wordBankView

                // Check/Next button
                if selectedWords.count == question.missingWords.count {
                    Button {
                        if isChecking {
                            nextQuestion()
                        } else {
                            checkAnswer()
                        }
                    } label: {
                        HStack {
                            Text(isChecking ? "Next Verse" : "Check Answer")
                                .fontWeight(.bold)
                            Image(systemName: isChecking ? "arrow.right" : "checkmark")
                        }
                    }
                    .buttonStyle(PlayfulButtonStyle(color: isChecking ? .appBrown : .appBlue))
                    .padding(.horizontal)
                }

                // Feedback
                if isChecking {
                    feedbackView
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer(minLength: 100)
            }
            .padding()
        }
    }

    private func passageView(_ question: FillBlankQuestion) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Complete the verse")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
            }

            let parts = question.textWithBlanks.components(separatedBy: "___")

            FlowLayout(spacing: 4) {
                ForEach(Array(parts.enumerated()), id: \.offset) { index, part in
                    // Text part
                    Text(part)
                        .font(.body)
                        .foregroundStyle(Color.appTextPrimary)

                    // Blank (if not last part)
                    if index < parts.count - 1 {
                        blankSlot(at: index)
                    }
                }
            }
            .lineSpacing(8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appCream)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appBrownLight.opacity(0.3), lineWidth: 1)
        )
    }

    private func blankSlot(at index: Int) -> some View {
        Group {
            if index < selectedWords.count {
                // Filled blank
                Text(selectedWords[index])
                    .font(.body)
                    .fontWeight(.bold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(blankBackgroundColor(at: index))
                    .foregroundStyle(blankTextColor(at: index))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(blankBorderColor(at: index), lineWidth: 2)
                    )
                    .onTapGesture {
                        if !isChecking {
                            withAnimation(.spring(response: 0.3)) {
                                removeWord(at: index)
                            }
                        }
                    }
            } else {
                // Empty blank
                Text("________")
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.appBeige)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.appBrownLight.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [5]))
                    )
            }
        }
    }

    private func blankBackgroundColor(at index: Int) -> Color {
        guard isChecking, let question = currentQuestion else {
            return Color.appBrown.opacity(0.1)
        }
        let correct = index < question.missingWords.count && selectedWords[index] == question.missingWords[index]
        return correct ? Color.appGreen.opacity(0.15) : Color.appRed.opacity(0.15)
    }

    private func blankTextColor(at index: Int) -> Color {
        guard isChecking, let question = currentQuestion else {
            return Color.appBrown
        }
        let correct = index < question.missingWords.count && selectedWords[index] == question.missingWords[index]
        return correct ? Color.appGreen : Color.appRed
    }

    private func blankBorderColor(at index: Int) -> Color {
        guard isChecking, let question = currentQuestion else {
            return Color.appBrown.opacity(0.3)
        }
        let correct = index < question.missingWords.count && selectedWords[index] == question.missingWords[index]
        return correct ? Color.appGreen : Color.appRed
    }

    private var wordBankView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📝")
                Text("Word Bank")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
            }

            if remainingWords.isEmpty && !isChecking {
                Text("All words placed!")
                    .font(.subheadline)
                    .foregroundStyle(Color.appGreen)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.appGreen.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                FlowLayout(spacing: 10) {
                    ForEach(remainingWords, id: \.self) { word in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectWord(word)
                            }
                        } label: {
                            Text(word)
                                .font(.body)
                                .fontWeight(.medium)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(Color.appBrown.opacity(0.1))
                                .foregroundStyle(Color.appBrown)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.appBrown.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .disabled(isChecking)
                    }
                }
            }
        }
        .padding()
        .playfulCard()
    }

    private var feedbackView: some View {
        HStack(spacing: 12) {
            Text(isCorrect ? "🎉" : "📚")
                .font(.title)

            VStack(alignment: .leading, spacing: 4) {
                Text(isCorrect ? "Perfect!" : "Not quite right")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(isCorrect ? Color.appGreen : Color.appOrange)

                if !isCorrect {
                    Text("The correct words are shown above")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            Spacer()

            if isCorrect {
                Text("+15 XP")
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
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCorrect ? Color.appGreen.opacity(0.3) : Color.appOrange.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Color.appBrown)
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
                // Success icon
                ZStack {
                    Circle()
                        .fill(Color.appGreen.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Text("✅")
                        .font(.system(size: 60))
                }
                .bounceIn(delay: 0)

                Text("Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
                    .bounceIn(delay: 0.1)

                // Score card
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
                            Text("\(questions.count)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(Color.appTextPrimary)
                            Text("Verses")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }

                    Text("verses completed correctly")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding()
                .playfulCard()
                .bounceIn(delay: 0.2)

                // XP earned
                HStack(spacing: 8) {
                    Text("⭐️")
                        .font(.title2)
                    Text("+\(score * 15) XP earned!")
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
                .buttonStyle(PlayfulButtonStyle(color: .appBrown))
                .padding()
                .bounceIn(delay: 0.4)
            }
            .padding()
        }
    }

    private func loadQuestions() {
        let service = BibleDataService()
        guard let passage = service.loadPassage(for: day) else { return }

        questions = passage.verses.prefix(5).map { verse in
            generateQuestion(from: verse)
        }

        if let first = questions.first {
            setupQuestion(first)
        }
    }

    private func generateQuestion(from verse: BibleVerse) -> FillBlankQuestion {
        let words = verse.text.components(separatedBy: " ")
        var missingIndices: Set<Int> = []

        let significantIndices = words.enumerated()
            .filter { $0.element.count > 3 }
            .map { $0.offset }
            .shuffled()

        for index in significantIndices.prefix(min(3, significantIndices.count)) {
            missingIndices.insert(index)
        }

        let missingWords = missingIndices.sorted().compactMap { words[safe: $0] }

        var textWithBlanks = ""
        for (index, word) in words.enumerated() {
            if missingIndices.contains(index) {
                textWithBlanks += "___ "
            } else {
                textWithBlanks += word + " "
            }
        }

        var wordBank = missingWords
        let distractors = ["faith", "love", "hope", "grace", "truth", "peace", "light", "word"]
            .filter { !missingWords.contains($0) }
            .prefix(2)
        wordBank.append(contentsOf: distractors)

        return FillBlankQuestion(
            fullText: verse.text,
            textWithBlanks: textWithBlanks.trimmingCharacters(in: .whitespaces),
            missingWords: missingWords,
            wordBank: wordBank.shuffled(),
            verseReference: verse.reference
        )
    }

    private func setupQuestion(_ question: FillBlankQuestion) {
        selectedWords = []
        remainingWords = question.wordBank
        isChecking = false
        isCorrect = false
    }

    private func selectWord(_ word: String) {
        guard let question = currentQuestion, selectedWords.count < question.missingWords.count else { return }
        selectedWords.append(word)
        remainingWords.removeAll { $0 == word }
    }

    private func removeWord(at index: Int) {
        guard index < selectedWords.count else { return }
        let word = selectedWords.remove(at: index)
        remainingWords.append(word)
    }

    private func checkAnswer() {
        guard let question = currentQuestion else { return }
        isCorrect = selectedWords == question.missingWords
        if isCorrect {
            score += 1
            showCelebration = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showCelebration = false
            }
        }
        withAnimation(.spring(response: 0.4)) {
            isChecking = true
        }
    }

    private func nextQuestion() {
        if currentIndex < questions.count - 1 {
            withAnimation {
                currentIndex += 1
                if let next = currentQuestion {
                    setupQuestion(next)
                }
            }
        } else {
            withAnimation {
                isComplete = true
            }
        }
    }

    private func saveScore() {
        let gameScore = GameScore(
            gameType: .fillBlank,
            score: score,
            totalQuestions: questions.count,
            dayNumber: day.id
        )
        modelContext.insert(gameScore)
    }
}

// Simple flow layout for wrapping content
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

#Preview {
    NavigationStack {
        FillBlankView(day: ReadingPlan.days[0])
    }
}
