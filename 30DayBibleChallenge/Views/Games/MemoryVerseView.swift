import SwiftUI
import SwiftData

struct MemoryVerseView: View {
    let day: ReadingDay
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = MemoryViewModel()
    @State private var currentCardIndex = 0
    @State private var isFlipped = false
    @State private var dragOffset: CGSize = .zero
    @State private var cardRotation: Double = 0
    @State private var showCompletion = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                // Progress header
                progressHeader
                    .padding(.horizontal)

                if !viewModel.cards.isEmpty {
                    // Flashcard
                    flashcard
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation
                                    cardRotation = Double(value.translation.width / 20)
                                }
                                .onEnded { value in
                                    handleSwipe(translation: value.translation.width)
                                }
                        )

                    // Instructions
                    HStack(spacing: 8) {
                        Image(systemName: isFlipped ? "hand.draw" : "hand.tap")
                            .font(.caption)
                        Text(isFlipped ? "Swipe to continue" : "Tap to reveal verse")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.appBeige))

                    // Navigation buttons
                    navigationButtons

                    // Mastery buttons
                    if isFlipped {
                        masteryButtons
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                } else {
                    loadingView
                }

                Spacer()
            }
            .padding()

            // Completion overlay
            if showCompletion {
                completionOverlay
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Memory Verse")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    saveProgress()
                    dismiss()
                }
                .fontWeight(.medium)
                .foregroundStyle(Color.appBrown)
            }
        }
        .onAppear {
            viewModel.loadCards(for: day)
        }
    }

    private var progressHeader: some View {
        HStack {
            // Card counter
            HStack(spacing: 4) {
                Text("🧠")
                Text("Card \(currentCardIndex + 1) of \(viewModel.cards.count)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer()

            // Progress dots
            HStack(spacing: 6) {
                ForEach(0..<viewModel.cards.count, id: \.self) { index in
                    Circle()
                        .fill(dotColor(for: index))
                        .frame(width: 10, height: 10)
                        .overlay {
                            if index < viewModel.cards.count && viewModel.cards[index].masteryLevel >= 3 {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 6, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .scaleEffect(index == currentCardIndex ? 1.2 : 1)
                        .animation(.spring(response: 0.3), value: currentCardIndex)
                }
            }
        }
    }

    private func dotColor(for index: Int) -> Color {
        if index == currentCardIndex {
            return .appBrown
        } else if index < viewModel.cards.count && viewModel.cards[index].masteryLevel >= 3 {
            return .appGreen
        }
        return Color.appBeige
    }

    private var flashcard: some View {
        ZStack {
            // Back of card (verse text)
            cardFace(
                content: viewModel.cards[safe: currentCardIndex]?.text ?? "",
                isBack: true
            )
            .opacity(isFlipped ? 1 : 0)
            .rotation3DEffect(
                .degrees(isFlipped ? 0 : 180),
                axis: (x: 0, y: 1, z: 0)
            )

            // Front of card (reference)
            cardFace(
                content: viewModel.cards[safe: currentCardIndex]?.reference ?? "",
                isBack: false
            )
            .opacity(isFlipped ? 0 : 1)
            .rotation3DEffect(
                .degrees(isFlipped ? -180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .frame(height: 320)
        .offset(dragOffset)
        .rotationEffect(.degrees(cardRotation))
        .animation(.spring(response: 0.3), value: dragOffset)
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
        }
    }

    private func cardFace(content: String, isBack: Bool) -> some View {
        VStack(spacing: 20) {
            if !isBack {
                // Front: Reference with book icon
                ZStack {
                    Circle()
                        .fill(Color.appBrown.opacity(0.1))
                        .frame(width: 80, height: 80)

                    Text("📖")
                        .font(.system(size: 40))
                }

                Text(content)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)

                Text("Tap to reveal")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.top, 8)
            } else {
                // Back: Verse text
                ScrollView(showsIndicators: false) {
                    Text("\"\(content)\"")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appTextPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .background(
            ZStack {
                // Card shadow
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.appBrownDark.opacity(0.1))
                    .offset(y: 6)

                // Card background
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.appCardBackground)

                // Decorative border
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color.appBrown.opacity(0.3), Color.appBrownLight.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )

                // Corner decoration
                VStack {
                    HStack {
                        Text("✦")
                            .font(.caption)
                            .foregroundStyle(Color.appYellow.opacity(0.5))
                            .padding(12)
                        Spacer()
                        Text("✦")
                            .font(.caption)
                            .foregroundStyle(Color.appYellow.opacity(0.5))
                            .padding(12)
                    }
                    Spacer()
                    HStack {
                        Text("✦")
                            .font(.caption)
                            .foregroundStyle(Color.appYellow.opacity(0.5))
                            .padding(12)
                        Spacer()
                        Text("✦")
                            .font(.caption)
                            .foregroundStyle(Color.appYellow.opacity(0.5))
                            .padding(12)
                    }
                }
            }
        )
        .shadow(color: Color.appBrown.opacity(0.1), radius: 15, y: 8)
    }

    private var navigationButtons: some View {
        HStack(spacing: 32) {
            // Previous
            Button {
                previousCard()
            } label: {
                ZStack {
                    Circle()
                        .fill(currentCardIndex > 0 ? Color.appBrown.opacity(0.1) : Color.appBeige)
                        .frame(width: 56, height: 56)

                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(currentCardIndex > 0 ? Color.appBrown : Color.appTextSecondary)
                }
            }
            .disabled(currentCardIndex == 0)

            // Flip
            Button {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isFlipped.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.appBrown)
                        .frame(width: 64, height: 64)
                        .shadow(color: Color.appBrown.opacity(0.3), radius: 8, y: 4)

                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            }

            // Next
            Button {
                nextCard()
            } label: {
                ZStack {
                    Circle()
                        .fill(currentCardIndex < viewModel.cards.count - 1 ? Color.appBrown.opacity(0.1) : Color.appBeige)
                        .frame(width: 56, height: 56)

                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(currentCardIndex < viewModel.cards.count - 1 ? Color.appBrown : Color.appTextSecondary)
                }
            }
            .disabled(currentCardIndex >= viewModel.cards.count - 1)
        }
        .padding()
    }

    private var masteryButtons: some View {
        HStack(spacing: 16) {
            // Still learning
            Button {
                nextCard()
            } label: {
                HStack {
                    Text("📚")
                    Text("Still Learning")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.appOrange.opacity(0.1))
                .foregroundStyle(Color.appOrange)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appOrange.opacity(0.3), lineWidth: 1)
                )
            }

            // Got it
            Button {
                if currentCardIndex < viewModel.cards.count {
                    viewModel.cards[currentCardIndex].masteryLevel = min(5, viewModel.cards[currentCardIndex].masteryLevel + 1)
                }
                if currentCardIndex == viewModel.cards.count - 1 {
                    withAnimation {
                        showCompletion = true
                    }
                } else {
                    nextCard()
                }
            } label: {
                HStack {
                    Text("✅")
                    Text("Got It!")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.appGreen.opacity(0.1))
                .foregroundStyle(Color.appGreen)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appGreen.opacity(0.3), lineWidth: 1)
                )
            }
        }
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

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                MascotView(mood: .excited, size: 100)
                    .bounceIn(delay: 0)

                Text("Well Done! 🎉")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .bounceIn(delay: 0.1)

                let masteredCount = viewModel.cards.filter { $0.masteryLevel >= 3 }.count
                VStack(spacing: 8) {
                    Text("\(masteredCount) / \(viewModel.cards.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appGreen)

                    Text("verses mastered")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .bounceIn(delay: 0.2)

                HStack(spacing: 8) {
                    Text("⭐️")
                        .font(.title2)
                    Text("+\(masteredCount * 15) XP")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appYellow)
                }
                .padding()
                .background(Capsule().fill(Color.appYellow.opacity(0.2)))
                .bounceIn(delay: 0.3)

                Button {
                    saveProgress()
                    dismiss()
                } label: {
                    Text("Continue")
                        .fontWeight(.bold)
                }
                .buttonStyle(PlayfulButtonStyle(color: .appBrown))
                .padding(.horizontal, 40)
                .bounceIn(delay: 0.4)
            }
            .padding()

            CelebrationView()
        }
    }

    private func handleSwipe(translation: CGFloat) {
        withAnimation(.spring(response: 0.3)) {
            if translation > 100 && currentCardIndex > 0 {
                previousCard()
            } else if translation < -100 && currentCardIndex < viewModel.cards.count - 1 {
                nextCard()
            }
            dragOffset = .zero
            cardRotation = 0
        }
    }

    private func nextCard() {
        withAnimation(.spring(response: 0.4)) {
            isFlipped = false
            if currentCardIndex < viewModel.cards.count - 1 {
                currentCardIndex += 1
            }
        }
    }

    private func previousCard() {
        withAnimation(.spring(response: 0.4)) {
            isFlipped = false
            if currentCardIndex > 0 {
                currentCardIndex -= 1
            }
        }
    }

    private func saveProgress() {
        let masteredCount = viewModel.cards.filter { $0.masteryLevel >= 3 }.count
        let score = GameScore(
            gameType: .memoryVerse,
            score: masteredCount,
            totalQuestions: viewModel.cards.count,
            dayNumber: day.id
        )
        modelContext.insert(score)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    NavigationStack {
        MemoryVerseView(day: ReadingPlan.days[0])
    }
}
