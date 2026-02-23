import SwiftUI
import SwiftData

struct MiniTestView: View {
    let day: ReadingDay
    let verses: [BibleVerse]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: MiniTestViewModel
    @State private var showCelebration = false
    @State private var showMascotFeedback = false
    @State private var mascotMessage = ""

    init(day: ReadingDay, verses: [BibleVerse]) {
        self.day = day
        self.verses = verses
        _viewModel = StateObject(wrappedValue: MiniTestViewModel(day: day, verses: verses))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                progressBar
                    .padding()

                if viewModel.isComplete {
                    completionView
                } else if let question = viewModel.currentQuestion {
                    questionContent(question)
                } else {
                    loadingView
                }
            }

            // Mascot feedback overlay
            if showMascotFeedback {
                mascotFeedbackOverlay
            }

            // Mini celebration on correct
            if showCelebration {
                CelebrationView()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Mini Test")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
                    Text("\(viewModel.currentIndex + 1)/\(viewModel.totalQuestions)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appCardBackgroundLight)
                    .frame(height: 12)

                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [.appPurple, .appPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * viewModel.progress, height: 12)
                    .animation(.spring(response: 0.4), value: viewModel.progress)
            }
        }
        .frame(height: 12)
    }

    // MARK: - Question Content

    @ViewBuilder
    private func questionContent(_ question: MiniTestQuestion) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Question type badge
                HStack(spacing: 8) {
                    Image(systemName: question.type.icon)
                    Text(question.type.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .foregroundStyle(Color.appPurple)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.appPurple.opacity(0.15)))

                // Question view based on type
                switch question.type {
                case .fillGap:
                    FillGapQuestionView(
                        question: question,
                        viewModel: viewModel,
                        onAnswer: handleAnswer
                    )
                case .nameVerse:
                    NameVerseQuestionView(
                        question: question,
                        viewModel: viewModel,
                        onAnswer: handleAnswer
                    )
                case .matchReference:
                    MatchReferenceQuestionView(
                        question: question,
                        viewModel: viewModel,
                        onAnswer: handleAnswer
                    )
                case .typeBack:
                    TypeBackQuestionView(
                        question: question,
                        viewModel: viewModel,
                        onAnswer: handleAnswer
                    )
                }

                Spacer(minLength: 100)
            }
            .padding()
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.appPurple)
                .scaleEffect(1.5)
            Text("Loading test...")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Completion View

    private var completionView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Trophy
                ZStack {
                    Circle()
                        .fill(Color.appYellow.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Text(viewModel.percentage >= 80 ? "🏆" : "⭐️")
                        .font(.system(size: 60))
                }
                .bounceIn(delay: 0)

                Text("Test Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
                    .bounceIn(delay: 0.1)

                // Mascot
                MascotView(mood: viewModel.percentage >= 80 ? .excited : .encouraging, size: 80)
                    .bounceIn(delay: 0.15)

                // Score card
                VStack(spacing: 16) {
                    HStack(spacing: 24) {
                        VStack(spacing: 4) {
                            Text("\(viewModel.score)")
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
                            Text("\(viewModel.totalQuestions)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(Color.appTextPrimary)
                            Text("Total")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }

                    // Percentage bar
                    VStack(spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.appBeige)
                                    .frame(height: 16)

                                RoundedRectangle(cornerRadius: 8)
                                    .fill(scoreColor)
                                    .frame(width: geo.size.width * (viewModel.percentage / 100), height: 16)
                            }
                        }
                        .frame(height: 16)

                        Text("\(Int(viewModel.percentage))% correct")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(scoreColor)
                    }
                }
                .padding()
                .playfulCard()
                .bounceIn(delay: 0.2)

                // XP earned
                HStack(spacing: 8) {
                    Text("⭐️")
                        .font(.title2)
                    Text("+\(viewModel.earnedXP) XP earned!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appYellow)
                }
                .padding()
                .background(Capsule().fill(Color.appYellow.opacity(0.2)))
                .bounceIn(delay: 0.3)

                // Bonus badge if applicable
                if viewModel.percentage >= 100 {
                    HStack(spacing: 8) {
                        Text("🌟")
                        Text("Perfect Score Bonus!")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appGreen)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.appGreen.opacity(0.15))
                    )
                    .bounceIn(delay: 0.35)
                } else if viewModel.percentage >= 80 {
                    HStack(spacing: 8) {
                        Text("💪")
                        Text("Great Score Bonus!")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appBlue)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.appBlue.opacity(0.15))
                    )
                    .bounceIn(delay: 0.35)
                }

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .fontWeight(.bold)
                }
                .buttonStyle(PlayfulButtonStyle(color: .appPurple))
                .padding()
                .bounceIn(delay: 0.4)
            }
            .padding()
        }
    }

    private var scoreColor: Color {
        switch viewModel.percentage {
        case 80...100: return .appGreen
        case 60..<80: return .appYellow
        default: return .appOrange
        }
    }

    // MARK: - Mascot Feedback Overlay

    private var mascotFeedbackOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                MascotView(
                    mood: viewModel.lastAnswerCorrect ? .excited : .sad,
                    size: 100
                )
                .scaleEffect(showMascotFeedback ? 1 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showMascotFeedback)

                Text(mascotMessage)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.appCardBackground)
            )
        }
        .transition(.opacity)
    }

    // MARK: - Answer Handler

    private func handleAnswer(correct: Bool) {
        mascotMessage = correct ? "Amazing!" : "Try again!"
        withAnimation(.spring(response: 0.4)) {
            showMascotFeedback = true
        }

        if correct {
            showCelebration = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showCelebration = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showMascotFeedback = false
            }
            viewModel.nextQuestion()
        }
    }
}

// MARK: - Fill Gap Question View

struct FillGapQuestionView: View {
    let question: MiniTestQuestion
    @ObservedObject var viewModel: MiniTestViewModel
    let onAnswer: (Bool) -> Void

    @State private var selectedWords: [String] = []
    @State private var remainingWords: [String] = []
    @State private var isSubmitted = false

    var body: some View {
        VStack(spacing: 20) {
            // Instructions
            Text("Fill in the missing words")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            // Passage with blanks
            passageView
                .padding()
                .playfulCard()

            // Word bank
            wordBankView
                .padding()
                .playfulCard()

            // Submit button
            if selectedWords.count == (question.missingWords?.count ?? 0) && !isSubmitted {
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
            }
        }
        .onAppear {
            remainingWords = question.wordBank ?? []
        }
    }

    private var passageView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📖")
                Text(question.verse.reference)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appBrown)
            }

            if let textWithGaps = question.textWithGaps {
                let parts = textWithGaps.components(separatedBy: "___")

                FlowLayout(spacing: 4) {
                    ForEach(Array(parts.enumerated()), id: \.offset) { index, part in
                        Text(part)
                            .font(.body)
                            .foregroundStyle(Color.appTextPrimary)

                        if index < parts.count - 1 {
                            blankSlot(at: index)
                        }
                    }
                }
            }
        }
    }

    private func blankSlot(at index: Int) -> some View {
        Group {
            if index < selectedWords.count {
                Text(selectedWords[index])
                    .font(.body)
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.appPurple.opacity(0.15))
                    .foregroundStyle(Color.appPurple)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture {
                        if !isSubmitted {
                            withAnimation(.spring(response: 0.3)) {
                                removeWord(at: index)
                            }
                        }
                    }
            } else {
                Text("______")
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.appBeige)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.appPurple.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                    )
            }
        }
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
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.appPurple.opacity(0.1))
                            .foregroundStyle(Color.appPurple)
                            .clipShape(Capsule())
                    }
                    .disabled(isSubmitted)
                }
            }
        }
    }

    private func selectWord(_ word: String) {
        guard selectedWords.count < (question.missingWords?.count ?? 0) else { return }
        selectedWords.append(word)
        remainingWords.removeAll { $0 == word }
    }

    private func removeWord(at index: Int) {
        guard index < selectedWords.count else { return }
        let word = selectedWords.remove(at: index)
        remainingWords.append(word)
    }

    private func submitAnswer() {
        isSubmitted = true
        let correct = viewModel.checkFillGapAnswer(selectedWords: selectedWords)
        onAnswer(correct)
    }
}

// MARK: - Name Verse Question View

struct NameVerseQuestionView: View {
    let question: MiniTestQuestion
    @ObservedObject var viewModel: MiniTestViewModel
    let onAnswer: (Bool) -> Void

    @State private var selectedReference: String?
    @State private var isSubmitted = false

    var body: some View {
        VStack(spacing: 20) {
            // Instructions
            Text("Which verse is this?")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            // Verse text
            VStack(spacing: 12) {
                Text("\"\(question.verse.text)\"")
                    .font(.body)
                    .italic()
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
            .padding(20)
            .playfulCard()

            // Reference options
            VStack(spacing: 12) {
                ForEach(question.referenceOptions ?? [], id: \.self) { reference in
                    Button {
                        if !isSubmitted {
                            withAnimation(.spring(response: 0.3)) {
                                selectedReference = reference
                            }
                        }
                    } label: {
                        HStack {
                            Text(reference)
                                .font(.body)
                                .fontWeight(selectedReference == reference ? .semibold : .regular)
                                .foregroundStyle(selectedReference == reference ? Color.appPurple : Color.appTextPrimary)

                            Spacer()

                            ZStack {
                                Circle()
                                    .stroke(selectedReference == reference ? Color.appPurple : Color.appTextSecondary.opacity(0.3), lineWidth: 2)
                                    .frame(width: 24, height: 24)

                                if selectedReference == reference {
                                    Circle()
                                        .fill(Color.appPurple)
                                        .frame(width: 14, height: 14)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedReference == reference ? Color.appPurple.opacity(0.1) : Color.appCardBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedReference == reference ? Color.appPurple : Color.appTextSecondary.opacity(0.2), lineWidth: selectedReference == reference ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Submit button
            if selectedReference != nil && !isSubmitted {
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
            }
        }
    }

    private func submitAnswer() {
        guard let selected = selectedReference else { return }
        isSubmitted = true
        let correct = viewModel.checkNameVerseAnswer(selectedReference: selected)
        onAnswer(correct)
    }
}

// MARK: - Match Reference Question View

struct MatchReferenceQuestionView: View {
    let question: MiniTestQuestion
    @ObservedObject var viewModel: MiniTestViewModel
    let onAnswer: (Bool) -> Void

    @State private var selectedVerseIndex: Int?
    @State private var selectedRefIndex: Int?
    @State private var matches: [(verse: String, reference: String)] = []
    @State private var availableVerses: [String] = []
    @State private var availableRefs: [String] = []
    @State private var isSubmitted = false

    var body: some View {
        VStack(spacing: 20) {
            // Instructions
            Text("Match each verse to its reference")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            // Matched pairs
            if !matches.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(matches.enumerated()), id: \.offset) { index, match in
                        HStack {
                            Text(String(match.verse.prefix(30)) + "...")
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

                            Button {
                                unmatch(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.appRed.opacity(0.7))
                            }
                            .disabled(isSubmitted)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.appGreen.opacity(0.1))
                        )
                    }
                }
            }

            // Available verses
            if !availableVerses.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Verses")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appTextSecondary)

                    ForEach(Array(availableVerses.enumerated()), id: \.offset) { index, verse in
                        Button {
                            selectVerse(index)
                        } label: {
                            Text(verse)
                                .font(.caption)
                                .foregroundStyle(selectedVerseIndex == index ? Color.appPurple : Color.appTextPrimary)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedVerseIndex == index ? Color.appPurple.opacity(0.15) : Color.appCardBackground)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedVerseIndex == index ? Color.appPurple : Color.appTextSecondary.opacity(0.2), lineWidth: selectedVerseIndex == index ? 2 : 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(isSubmitted)
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

                    FlowLayout(spacing: 8) {
                        ForEach(Array(availableRefs.enumerated()), id: \.offset) { index, ref in
                            Button {
                                selectRef(index)
                            } label: {
                                Text(ref)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(selectedRefIndex == index ? Color.appPurple : Color.appTextPrimary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(selectedRefIndex == index ? Color.appPurple.opacity(0.15) : Color.appCardBackground)
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(selectedRefIndex == index ? Color.appPurple : Color.appTextSecondary.opacity(0.3), lineWidth: selectedRefIndex == index ? 2 : 1)
                                    )
                            }
                            .buttonStyle(.plain)
                            .disabled(isSubmitted)
                        }
                    }
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
            }
        }
        .onAppear {
            setupPairs()
        }
    }

    private func setupPairs() {
        guard let pairs = question.matchPairs else { return }
        availableVerses = pairs.map { $0.verse }
        availableRefs = pairs.map { $0.reference }.shuffled()
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
            matches.append((verse, ref))
            availableVerses.remove(at: verseIdx)
            availableRefs.remove(at: refIdx)
            selectedVerseIndex = nil
            selectedRefIndex = nil
        }
    }

    private func unmatch(at index: Int) {
        let match = matches[index]
        withAnimation(.spring(response: 0.3)) {
            matches.remove(at: index)
            availableVerses.append(match.verse)
            availableRefs.append(match.reference)
        }
    }

    private func submitAnswer() {
        isSubmitted = true
        let correct = viewModel.checkMatchReferenceAnswer(matches: matches)
        onAnswer(correct)
    }
}

// MARK: - Type Back Question View

struct TypeBackQuestionView: View {
    let question: MiniTestQuestion
    @ObservedObject var viewModel: MiniTestViewModel
    let onAnswer: (Bool) -> Void

    @State private var typedText = ""
    @State private var isSubmitted = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            // Instructions
            Text("Type the verse from memory")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            // Reference and hint
            VStack(spacing: 12) {
                HStack {
                    Text("📖")
                    Text(question.verse.reference)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appBrown)
                }

                if let hint = question.hintText {
                    HStack {
                        Text("Hint:")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                        Text(hint)
                            .font(.caption)
                            .italic()
                            .foregroundStyle(Color.appPurple)
                    }
                }
            }
            .padding()
            .playfulCard()

            // Text input
            VStack(alignment: .leading, spacing: 8) {
                Text("Your answer:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appTextSecondary)

                TextEditor(text: $typedText)
                    .focused($isFocused)
                    .frame(minHeight: 120)
                    .padding(12)
                    .background(Color.appCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isFocused ? Color.appPurple : Color.appTextSecondary.opacity(0.3), lineWidth: isFocused ? 2 : 1)
                    )
                    .disabled(isSubmitted)
            }

            // Submit button
            if !typedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitted {
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
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }

    private func submitAnswer() {
        isFocused = false
        isSubmitted = true
        let correct = viewModel.checkTypeBackAnswer(typedText: typedText)
        onAnswer(correct)
    }
}

#Preview {
    NavigationStack {
        MiniTestView(
            day: ReadingPlan.days[0],
            verses: [
                BibleVerse(book: "Genesis", chapter: 1, verse: 1, text: "In the beginning God created the heavens and the earth."),
                BibleVerse(book: "Genesis", chapter: 1, verse: 2, text: "And the earth was without form, and void; and darkness was upon the face of the deep.")
            ]
        )
    }
}
