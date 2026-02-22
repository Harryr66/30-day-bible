import SwiftUI
import SwiftData

struct QuizView: View {
    let day: ReadingDay
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = QuizViewModel()
    @State private var selectedAnswer: String?
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var showCelebration = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                progressBar
                    .padding()

                if viewModel.isComplete {
                    completionView
                } else if let question = viewModel.currentQuestion {
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
                Text("Quiz - Day \(day.id)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
                    Text("❓")
                    Text("\(viewModel.currentIndex + 1)/\(viewModel.totalQuestions)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
        .onAppear {
            viewModel.loadQuestions(for: day)
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
                            colors: [.appBrown, .appBrownLight],
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

    private func questionView(_ question: QuizQuestion) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Question card
                VStack(spacing: 16) {
                    // Question number badge
                    Text("QUESTION \(viewModel.currentIndex + 1)")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(Color.appOrange)
                        )

                    Text(question.question)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appTextPrimary)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 4) {
                        Text("📖")
                        Text(question.verseReference)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.appBrown)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.appBrown.opacity(0.1)))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .playfulCard()

                // Answer options
                VStack(spacing: 12) {
                    ForEach(question.allAnswers, id: \.self) { answer in
                        AnswerButton(
                            text: answer,
                            isSelected: selectedAnswer == answer,
                            isCorrect: showResult && answer == question.correctAnswer,
                            isWrong: showResult && selectedAnswer == answer && answer != question.correctAnswer
                        ) {
                            if !showResult {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedAnswer = answer
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Submit/Next button
                if selectedAnswer != nil {
                    Button {
                        if showResult {
                            nextQuestion()
                        } else {
                            checkAnswer()
                        }
                    } label: {
                        HStack {
                            Text(showResult ? "Next Question" : "Check Answer")
                                .fontWeight(.bold)
                            Image(systemName: showResult ? "arrow.right" : "checkmark")
                        }
                    }
                    .buttonStyle(PlayfulButtonStyle(color: showResult ? .appBrown : .appGreen))
                    .padding(.horizontal)
                }

                // Result feedback
                if showResult {
                    resultFeedback(for: question)
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer(minLength: 100)
            }
            .padding()
        }
    }

    private func resultFeedback(for question: QuizQuestion) -> some View {
        HStack(spacing: 12) {
            Text(isCorrect ? "🎉" : "📚")
                .font(.title)

            VStack(alignment: .leading, spacing: 4) {
                Text(isCorrect ? "Correct!" : "Not quite...")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(isCorrect ? Color.appGreen : Color.appOrange)

                if !isCorrect {
                    Text("The answer was: \(question.correctAnswer)")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
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
            Text("Loading questions...")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var completionView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Trophy/mascot
                ZStack {
                    Circle()
                        .fill(Color.appYellow.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Text(viewModel.score >= viewModel.totalQuestions / 2 ? "🏆" : "⭐️")
                        .font(.system(size: 60))
                }
                .bounceIn(delay: 0)

                Text("Quiz Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
                    .bounceIn(delay: 0.1)

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

                // Performance message
                VStack(spacing: 8) {
                    Text(performanceEmoji)
                        .font(.title)
                    Text(performanceMessage)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding()
                .bounceIn(delay: 0.3)

                // XP earned
                HStack(spacing: 8) {
                    Text("⭐️")
                        .font(.title2)
                    Text("+\(viewModel.score * 10) XP earned!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appYellow)
                }
                .padding()
                .background(Capsule().fill(Color.appYellow.opacity(0.2)))
                .bounceIn(delay: 0.4)

                Button {
                    saveScore()
                    dismiss()
                } label: {
                    Text("Done")
                        .fontWeight(.bold)
                }
                .buttonStyle(PlayfulButtonStyle(color: .appBrown))
                .padding()
                .bounceIn(delay: 0.5)
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

    private var performanceEmoji: String {
        switch viewModel.percentage {
        case 90...100: return "🌟"
        case 70..<90: return "💪"
        case 50..<70: return "📖"
        default: return "🙏"
        }
    }

    private var performanceMessage: String {
        switch viewModel.percentage {
        case 90...100: return "Excellent! You really know this passage well!"
        case 70..<90: return "Great job! Keep studying to master these verses."
        case 50..<70: return "Good effort! Review the passage and try again."
        default: return "Keep practicing! Read through the passage again."
        }
    }

    private func checkAnswer() {
        guard let question = viewModel.currentQuestion, let answer = selectedAnswer else { return }
        isCorrect = answer == question.correctAnswer
        if isCorrect {
            viewModel.score += 1
            showCelebration = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showCelebration = false
            }
        }
        withAnimation(.spring(response: 0.4)) {
            showResult = true
        }
    }

    private func nextQuestion() {
        withAnimation {
            selectedAnswer = nil
            showResult = false
            isCorrect = false
            viewModel.nextQuestion()
        }
    }

    private func saveScore() {
        let score = GameScore(
            gameType: .quiz,
            score: viewModel.score,
            totalQuestions: viewModel.totalQuestions,
            dayNumber: day.id
        )
        modelContext.insert(score)
    }
}

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(foregroundColor)
                    .multilineTextAlignment(.leading)

                Spacer()

                ZStack {
                    Circle()
                        .stroke(borderColor, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isCorrect {
                        Circle()
                            .fill(Color.appGreen)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    } else if isWrong {
                        Circle()
                            .fill(Color.appRed)
                            .frame(width: 24, height: 24)
                        Image(systemName: "xmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    } else if isSelected {
                        Circle()
                            .fill(Color.appBrown)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding()
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected || isCorrect || isWrong ? 2 : 1)
            }
            .shadow(color: Color.appBrown.opacity(0.05), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.2)) {
                isPressed = pressing
            }
        }, perform: {})
    }

    private var backgroundColor: Color {
        if isCorrect { return Color.appGreen.opacity(0.1) }
        if isWrong { return Color.appRed.opacity(0.1) }
        if isSelected { return Color.appBrown.opacity(0.1) }
        return Color.appCardBackground
    }

    private var foregroundColor: Color {
        if isCorrect { return Color.appGreen }
        if isWrong { return Color.appRed }
        return Color.appTextPrimary
    }

    private var borderColor: Color {
        if isCorrect { return Color.appGreen }
        if isWrong { return Color.appRed }
        if isSelected { return Color.appBrown }
        return Color.appBrownLight.opacity(0.3)
    }
}

#Preview {
    NavigationStack {
        QuizView(day: ReadingPlan.days[0])
    }
}
