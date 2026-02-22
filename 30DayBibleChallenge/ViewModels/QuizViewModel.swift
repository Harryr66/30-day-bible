import Foundation

@MainActor
class QuizViewModel: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var isComplete = false

    private let dataService = BibleDataService()

    var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var totalQuestions: Int {
        questions.count
    }

    var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentIndex) / Double(totalQuestions)
    }

    var percentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(score) / Double(totalQuestions) * 100
    }

    func loadQuestions(for day: ReadingDay) {
        // Generate quiz questions based on the day's content
        questions = generateQuestions(for: day)
    }

    func nextQuestion() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            isComplete = true
        }
    }

    private func generateQuestions(for day: ReadingDay) -> [QuizQuestion] {
        // Generate questions based on the day's theme and content
        var generatedQuestions: [QuizQuestion] = []

        switch day.id {
        case 1: // Creation
            generatedQuestions = [
                QuizQuestion(
                    question: "What did God create in the beginning?",
                    correctAnswer: "The heavens and the earth",
                    wrongAnswers: ["The sun and moon", "Animals and plants", "Light and darkness"],
                    verseReference: "Genesis 1:1"
                ),
                QuizQuestion(
                    question: "How many days did God take to create the world?",
                    correctAnswer: "Six days",
                    wrongAnswers: ["Seven days", "Five days", "One day"],
                    verseReference: "Genesis 1"
                ),
                QuizQuestion(
                    question: "What did God do on the seventh day?",
                    correctAnswer: "He rested",
                    wrongAnswers: ["Created humans", "Created animals", "Created light"],
                    verseReference: "Genesis 2:2"
                ),
                QuizQuestion(
                    question: "In whose image was man created?",
                    correctAnswer: "God's image",
                    wrongAnswers: ["Angel's image", "Animal's image", "Nature's image"],
                    verseReference: "Genesis 1:27"
                ),
                QuizQuestion(
                    question: "What did God say about His creation?",
                    correctAnswer: "It was very good",
                    wrongAnswers: ["It was okay", "It needed work", "It was complete"],
                    verseReference: "Genesis 1:31"
                )
            ]

        case 8: // Psalm 23
            generatedQuestions = [
                QuizQuestion(
                    question: "Who is described as 'my shepherd' in Psalm 23?",
                    correctAnswer: "The LORD",
                    wrongAnswers: ["David", "Moses", "Abraham"],
                    verseReference: "Psalm 23:1"
                ),
                QuizQuestion(
                    question: "Where does the shepherd make the psalmist lie down?",
                    correctAnswer: "Green pastures",
                    wrongAnswers: ["Rocky mountains", "Sandy deserts", "Dark forests"],
                    verseReference: "Psalm 23:2"
                ),
                QuizQuestion(
                    question: "Even though I walk through the valley of the shadow of ___?",
                    correctAnswer: "Death",
                    wrongAnswers: ["Fear", "Darkness", "Doubt"],
                    verseReference: "Psalm 23:4"
                ),
                QuizQuestion(
                    question: "What does the psalmist say will follow them all the days of their life?",
                    correctAnswer: "Goodness and mercy",
                    wrongAnswers: ["Wealth and fame", "Power and strength", "Wisdom and knowledge"],
                    verseReference: "Psalm 23:6"
                ),
                QuizQuestion(
                    question: "Where will the psalmist dwell forever?",
                    correctAnswer: "The house of the LORD",
                    wrongAnswers: ["A palace", "The wilderness", "The city"],
                    verseReference: "Psalm 23:6"
                )
            ]

        case 22: // John 3 - Born Again
            generatedQuestions = [
                QuizQuestion(
                    question: "Who came to Jesus by night?",
                    correctAnswer: "Nicodemus",
                    wrongAnswers: ["Peter", "John", "Judas"],
                    verseReference: "John 3:1-2"
                ),
                QuizQuestion(
                    question: "What did Jesus say a person must be to see the kingdom of God?",
                    correctAnswer: "Born again",
                    wrongAnswers: ["Very wealthy", "Very wise", "Very strong"],
                    verseReference: "John 3:3"
                ),
                QuizQuestion(
                    question: "For God so loved the world that he gave his only ___?",
                    correctAnswer: "Son",
                    wrongAnswers: ["Prophet", "Angel", "Kingdom"],
                    verseReference: "John 3:16"
                ),
                QuizQuestion(
                    question: "What shall those who believe in Him have?",
                    correctAnswer: "Eternal life",
                    wrongAnswers: ["Great wealth", "Perfect health", "Much wisdom"],
                    verseReference: "John 3:16"
                ),
                QuizQuestion(
                    question: "God did not send His Son to condemn the world, but to ___?",
                    correctAnswer: "Save it",
                    wrongAnswers: ["Judge it", "Rule it", "Destroy it"],
                    verseReference: "John 3:17"
                )
            ]

        default:
            // Generate generic questions for other days
            generatedQuestions = [
                QuizQuestion(
                    question: "What is the main theme of \(day.title)?",
                    correctAnswer: day.theme,
                    wrongAnswers: ["Creation", "Love", "Faith"].filter { $0 != day.theme },
                    verseReference: day.reference
                ),
                QuizQuestion(
                    question: "Which book of the Bible is today's reading from?",
                    correctAnswer: day.book,
                    wrongAnswers: ["Genesis", "Psalms", "John"].filter { $0 != day.book },
                    verseReference: day.reference
                ),
                QuizQuestion(
                    question: "What chapter does today's reading start in?",
                    correctAnswer: "\(day.startChapter)",
                    wrongAnswers: ["1", "5", "10"].filter { $0 != "\(day.startChapter)" },
                    verseReference: day.reference
                ),
                QuizQuestion(
                    question: "Today's reading is Day ___ of the 30 Day Challenge",
                    correctAnswer: "\(day.id)",
                    wrongAnswers: ["\((day.id % 30) + 1)", "\((day.id + 5) % 30 + 1)", "\((day.id + 10) % 30 + 1)"],
                    verseReference: "30 Day Challenge"
                ),
                QuizQuestion(
                    question: "What is the title of Day \(day.id)?",
                    correctAnswer: day.title,
                    wrongAnswers: ["The Beginning", "God's Love", "New Life"],
                    verseReference: day.reference
                )
            ]
        }

        return generatedQuestions.shuffled()
    }
}
