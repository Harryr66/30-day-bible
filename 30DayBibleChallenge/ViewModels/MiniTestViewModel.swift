import Foundation
import Combine

@MainActor
class MiniTestViewModel: ObservableObject {
    @Published var questions: [MiniTestQuestion] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var isComplete = false
    @Published var showingFeedback = false
    @Published var lastAnswerCorrect = false

    private var incorrectQueue: [MiniTestQuestion] = []
    private let verses: [BibleVerse]
    private let day: ReadingDay

    var currentQuestion: MiniTestQuestion? {
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

    var earnedXP: Int {
        var xp = score * 5
        if percentage >= 100 {
            xp += 25
        } else if percentage >= 80 {
            xp += 15
        }
        return xp
    }

    init(day: ReadingDay, verses: [BibleVerse]) {
        self.day = day
        self.verses = verses
        generateQuestions()
    }

    // MARK: - Question Generation

    private func generateQuestions() {
        guard !verses.isEmpty else { return }

        let questionTypes = MiniTestQuestionType.allCases
        var generatedQuestions: [MiniTestQuestion] = []

        // Distribute question types evenly across verses (max 5 questions)
        let versesToUse = Array(verses.prefix(5))

        for (index, verse) in versesToUse.enumerated() {
            let questionType = questionTypes[index % questionTypes.count]
            if let question = createQuestion(type: questionType, verse: verse) {
                generatedQuestions.append(question)
            }
        }

        questions = generatedQuestions.shuffled()
    }

    private func createQuestion(type: MiniTestQuestionType, verse: BibleVerse) -> MiniTestQuestion? {
        switch type {
        case .fillGap:
            return createFillGapQuestion(verse: verse)
        case .nameVerse:
            return createNameVerseQuestion(verse: verse)
        case .matchReference:
            return createMatchReferenceQuestion(verse: verse)
        case .typeBack:
            return createTypeBackQuestion(verse: verse)
        }
    }

    private func createFillGapQuestion(verse: BibleVerse) -> MiniTestQuestion {
        let words = verse.text.components(separatedBy: " ")
        var missingIndices: Set<Int> = []

        // Select 2-3 significant words (>3 chars) to blank out
        let significantIndices = words.enumerated()
            .filter { $0.element.filter { $0.isLetter }.count > 3 }
            .map { $0.offset }
            .shuffled()

        let numBlanks = min(3, max(2, significantIndices.count))
        for index in significantIndices.prefix(numBlanks) {
            missingIndices.insert(index)
        }

        let missingWords = missingIndices.sorted().compactMap { words[safe: $0]?.trimmingCharacters(in: .punctuationCharacters) }

        var textWithBlanks = ""
        for (index, word) in words.enumerated() {
            if missingIndices.contains(index) {
                textWithBlanks += "___ "
            } else {
                textWithBlanks += word + " "
            }
        }

        // Create word bank with correct words + distractors
        var wordBank = missingWords
        let distractors = ["faith", "love", "hope", "grace", "truth", "peace", "light", "word", "Lord", "life"]
            .filter { !missingWords.map { $0.lowercased() }.contains($0.lowercased()) }
            .shuffled()
            .prefix(2)
        wordBank.append(contentsOf: distractors)

        return MiniTestQuestion(
            type: .fillGap,
            verse: verse,
            textWithGaps: textWithBlanks.trimmingCharacters(in: .whitespaces),
            missingWords: missingWords,
            wordBank: wordBank.shuffled()
        )
    }

    private func createNameVerseQuestion(verse: BibleVerse) -> MiniTestQuestion {
        // Generate 3 wrong reference options
        let correctRef = verse.reference
        var options = [correctRef]

        // Generate plausible wrong references
        let wrongRefs = generateWrongReferences(for: verse, count: 3)
        options.append(contentsOf: wrongRefs)

        return MiniTestQuestion(
            type: .nameVerse,
            verse: verse,
            referenceOptions: options.shuffled()
        )
    }

    private func generateWrongReferences(for verse: BibleVerse, count: Int) -> [String] {
        var wrongRefs: [String] = []
        let books = ["Genesis", "Exodus", "Psalms", "Proverbs", "Isaiah", "Matthew", "Luke", "John", "Romans", "Galatians"]
            .filter { $0 != verse.book }

        for i in 0..<count {
            if i == 0 {
                // Same book, different verse
                let wrongVerse = verse.verse + Int.random(in: 1...5)
                wrongRefs.append("\(verse.book) \(verse.chapter):\(wrongVerse)")
            } else if i == 1 {
                // Same book, different chapter
                let wrongChapter = max(1, verse.chapter + Int.random(in: -2...2))
                let wrongVerse = Int.random(in: 1...20)
                if wrongChapter != verse.chapter || wrongVerse != verse.verse {
                    wrongRefs.append("\(verse.book) \(wrongChapter):\(wrongVerse)")
                } else {
                    wrongRefs.append("\(verse.book) \(wrongChapter + 1):\(wrongVerse)")
                }
            } else {
                // Different book
                let wrongBook = books.randomElement() ?? "Psalms"
                let wrongChapter = Int.random(in: 1...10)
                let wrongVerse = Int.random(in: 1...20)
                wrongRefs.append("\(wrongBook) \(wrongChapter):\(wrongVerse)")
            }
        }

        return wrongRefs
    }

    private func createMatchReferenceQuestion(verse: BibleVerse) -> MiniTestQuestion {
        // Create pairs of verse snippets with references
        var pairs: [(verse: String, reference: String)] = []

        // Main verse
        let snippet = String(verse.text.prefix(50)) + (verse.text.count > 50 ? "..." : "")
        pairs.append((snippet, verse.reference))

        // Add 2 more verses from the passage if available
        for otherVerse in verses.filter({ $0.id != verse.id }).prefix(2) {
            let otherSnippet = String(otherVerse.text.prefix(50)) + (otherVerse.text.count > 50 ? "..." : "")
            pairs.append((otherSnippet, otherVerse.reference))
        }

        // If we don't have enough verses, create dummy pairs
        while pairs.count < 3 {
            let dummyRef = "Psalms \(Int.random(in: 1...150)):\(Int.random(in: 1...20))"
            pairs.append(("Sample verse text...", dummyRef))
        }

        return MiniTestQuestion(
            type: .matchReference,
            verse: verse,
            matchPairs: pairs.shuffled()
        )
    }

    private func createTypeBackQuestion(verse: BibleVerse) -> MiniTestQuestion {
        // Show reference + hint (first few words)
        let words = verse.text.components(separatedBy: " ")
        let hintWordCount = min(4, words.count / 3)
        let hint = words.prefix(hintWordCount).joined(separator: " ") + "..."

        return MiniTestQuestion(
            type: .typeBack,
            verse: verse,
            hintText: hint
        )
    }

    // MARK: - Answer Validation

    func checkFillGapAnswer(selectedWords: [String]) -> Bool {
        guard let question = currentQuestion,
              let missingWords = question.missingWords else { return false }

        // Exact match of word array (case insensitive)
        let correct = selectedWords.map { $0.lowercased() } == missingWords.map { $0.lowercased() }
        handleAnswerResult(correct: correct)
        return correct
    }

    func checkNameVerseAnswer(selectedReference: String) -> Bool {
        guard let question = currentQuestion else { return false }

        let correct = selectedReference == question.verse.reference
        handleAnswerResult(correct: correct)
        return correct
    }

    func checkMatchReferenceAnswer(matches: [(verse: String, reference: String)]) -> Bool {
        guard let question = currentQuestion,
              let correctPairs = question.matchPairs else { return false }

        // Check if all pairs match correctly
        var correct = true
        for match in matches {
            if let correctPair = correctPairs.first(where: { $0.verse == match.verse }) {
                if correctPair.reference != match.reference {
                    correct = false
                    break
                }
            } else {
                correct = false
                break
            }
        }

        handleAnswerResult(correct: correct)
        return correct
    }

    func checkTypeBackAnswer(typedText: String) -> Bool {
        guard let question = currentQuestion else { return false }

        // Fuzzy match using Levenshtein distance (90% similarity)
        let correct = calculateSimilarity(typedText, question.verse.text) >= 0.9
        handleAnswerResult(correct: correct)
        return correct
    }

    private func calculateSimilarity(_ s1: String, _ s2: String) -> Double {
        let str1 = s1.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let str2 = s2.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if str1 == str2 { return 1.0 }
        if str1.isEmpty || str2.isEmpty { return 0.0 }

        let distance = levenshteinDistance(str1, str2)
        let maxLength = max(str1.count, str2.count)
        return 1.0 - (Double(distance) / Double(maxLength))
    }

    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let arr1 = Array(s1)
        let arr2 = Array(s2)
        let m = arr1.count
        let n = arr2.count

        if m == 0 { return n }
        if n == 0 { return m }

        var matrix = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)

        for i in 0...m { matrix[i][0] = i }
        for j in 0...n { matrix[0][j] = j }

        for i in 1...m {
            for j in 1...n {
                let cost = arr1[i - 1] == arr2[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j - 1] + cost
                )
            }
        }

        return matrix[m][n]
    }

    // MARK: - Answer Handling

    private func handleAnswerResult(correct: Bool) {
        lastAnswerCorrect = correct
        showingFeedback = true

        if correct {
            score += 1
            questions[currentIndex].isAnsweredCorrectly = true
        } else {
            questions[currentIndex].attempts += 1

            // Add to recycle queue if first incorrect attempt
            if questions[currentIndex].attempts == 1 {
                incorrectQueue.append(questions[currentIndex])
            }
        }
    }

    func nextQuestion() {
        showingFeedback = false

        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else if !incorrectQueue.isEmpty {
            // Add recycled questions to the end
            questions.append(contentsOf: incorrectQueue)
            incorrectQueue.removeAll()
            currentIndex += 1
        } else {
            isComplete = true
        }
    }
}
