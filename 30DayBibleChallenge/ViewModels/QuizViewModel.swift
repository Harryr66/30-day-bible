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
        questions = generateQuestions(
            book: day.book,
            chapter: day.startChapter,
            theme: day.theme,
            title: day.title,
            reference: day.reference
        )
    }

    func loadQuestions(for lesson: Lesson) {
        questions = generateQuestions(
            book: lesson.book,
            chapter: lesson.startChapter,
            theme: lesson.theme,
            title: lesson.title,
            reference: "\(lesson.book) \(lesson.startChapter):\(lesson.startVerse)-\(lesson.endVerse)"
        )
    }

    func nextQuestion() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            isComplete = true
        }
    }

    private func generateQuestions(book: String, chapter: Int, theme: String, title: String, reference: String) -> [QuizQuestion] {
        var allQuestions: [QuizQuestion] = []

        // 1. Get book-specific questions
        if let bookQuestions = questionsByBook[book] {
            allQuestions.append(contentsOf: bookQuestions)
        }

        // 2. Get chapter-specific questions if available
        let bookChapterKey = "\(book)_\(chapter)"
        if let chapterQuestions = questionsByChapter[bookChapterKey] {
            allQuestions.append(contentsOf: chapterQuestions)
        }

        // 3. Get theme-based questions
        if let themeQuestions = questionsByTheme[theme] {
            allQuestions.append(contentsOf: themeQuestions)
        }

        // 4. If we don't have enough, add general questions for this book/theme
        if allQuestions.count < 5 {
            allQuestions.append(contentsOf: generateDynamicQuestions(book: book, theme: theme, reference: reference))
        }

        // Return 5 random questions
        return Array(allQuestions.shuffled().prefix(5))
    }

    private func generateDynamicQuestions(book: String, theme: String, reference: String) -> [QuizQuestion] {
        // Generate contextual questions based on book and theme
        var questions: [QuizQuestion] = []

        // Book-type based questions
        if isOldTestamentHistory(book) {
            questions.append(contentsOf: oldTestamentHistoryQuestions(book: book, reference: reference))
        } else if isPsalm(book) {
            questions.append(contentsOf: psalmQuestions(reference: reference))
        } else if isWisdom(book) {
            questions.append(contentsOf: wisdomQuestions(book: book, reference: reference))
        } else if isProphet(book) {
            questions.append(contentsOf: prophetQuestions(book: book, reference: reference))
        } else if isGospel(book) {
            questions.append(contentsOf: gospelQuestions(book: book, reference: reference))
        } else if isEpistle(book) {
            questions.append(contentsOf: epistleQuestions(book: book, reference: reference))
        }

        // Theme-based questions
        questions.append(QuizQuestion(
            question: "What does this passage teach about \(theme.lowercased())?",
            correctAnswer: getThemeTeaching(theme),
            wrongAnswers: getWrongThemeTeachings(theme),
            verseReference: reference
        ))

        return questions
    }

    // MARK: - Book Type Helpers

    private func isOldTestamentHistory(_ book: String) -> Bool {
        ["Genesis", "Exodus", "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel", "1 Kings", "2 Kings", "Esther", "Daniel"].contains(book)
    }

    private func isPsalm(_ book: String) -> Bool {
        book == "Psalms" || book == "Psalm"
    }

    private func isWisdom(_ book: String) -> Bool {
        ["Proverbs", "Ecclesiastes", "Job", "Song of Solomon"].contains(book)
    }

    private func isProphet(_ book: String) -> Bool {
        ["Isaiah", "Jeremiah", "Ezekiel", "Daniel", "Hosea", "Joel", "Amos", "Jonah", "Micah", "Nahum", "Habakkuk", "Zephaniah", "Haggai", "Zechariah", "Malachi"].contains(book)
    }

    private func isGospel(_ book: String) -> Bool {
        ["Matthew", "Mark", "Luke", "John"].contains(book)
    }

    private func isEpistle(_ book: String) -> Bool {
        ["Romans", "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians", "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians", "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews", "James", "1 Peter", "2 Peter", "1 John", "2 John", "3 John", "Jude", "Revelation", "Acts"].contains(book)
    }

    // MARK: - Dynamic Question Generators

    private func oldTestamentHistoryQuestions(book: String, reference: String) -> [QuizQuestion] {
        [
            QuizQuestion(
                question: "What does God reveal about His character in this passage from \(book)?",
                correctAnswer: "His faithfulness and power to save",
                wrongAnswers: ["His indifference to people", "His anger only", "Nothing about His character"],
                verseReference: reference
            ),
            QuizQuestion(
                question: "How does this Old Testament story point to God's redemption plan?",
                correctAnswer: "It shows God working through history to save His people",
                wrongAnswers: ["It doesn't relate to redemption", "It shows God abandoning His people", "It's just an ancient tale"],
                verseReference: reference
            )
        ]
    }

    private func psalmQuestions(reference: String) -> [QuizQuestion] {
        [
            QuizQuestion(
                question: "What response does this Psalm call for from the reader?",
                correctAnswer: "Trust, praise, and worship of God",
                wrongAnswers: ["Fear and hiding", "Self-reliance", "Indifference"],
                verseReference: reference
            ),
            QuizQuestion(
                question: "How does the Psalmist describe God?",
                correctAnswer: "As a refuge, shepherd, and source of help",
                wrongAnswers: ["As distant and uncaring", "As angry and vengeful only", "As weak and limited"],
                verseReference: reference
            )
        ]
    }

    private func wisdomQuestions(book: String, reference: String) -> [QuizQuestion] {
        [
            QuizQuestion(
                question: "According to \(book), where does true wisdom come from?",
                correctAnswer: "The fear of the LORD",
                wrongAnswers: ["Education alone", "Life experience only", "Human reasoning"],
                verseReference: reference
            ),
            QuizQuestion(
                question: "What practical guidance does this wisdom passage offer?",
                correctAnswer: "Trust God and live righteously",
                wrongAnswers: ["Pursue wealth above all", "Follow your heart always", "Ignore consequences"],
                verseReference: reference
            )
        ]
    }

    private func prophetQuestions(book: String, reference: String) -> [QuizQuestion] {
        [
            QuizQuestion(
                question: "What is the prophet's message in this passage?",
                correctAnswer: "Call to repentance and promise of restoration",
                wrongAnswers: ["Permanent rejection", "Indifference to sin", "Human solutions only"],
                verseReference: reference
            ),
            QuizQuestion(
                question: "How does this prophecy point to the Messiah?",
                correctAnswer: "It foreshadows God's ultimate plan of salvation",
                wrongAnswers: ["It doesn't relate to the Messiah", "It describes a political king only", "It predicts failure"],
                verseReference: reference
            )
        ]
    }

    private func gospelQuestions(book: String, reference: String) -> [QuizQuestion] {
        [
            QuizQuestion(
                question: "What does this passage reveal about Jesus?",
                correctAnswer: "His divine nature and compassion for people",
                wrongAnswers: ["He was just a teacher", "He was uncertain of His mission", "He sought political power"],
                verseReference: reference
            ),
            QuizQuestion(
                question: "What response does Jesus call for in this teaching?",
                correctAnswer: "Faith and following Him",
                wrongAnswers: ["Religious rituals only", "Self-improvement", "Passive observation"],
                verseReference: reference
            )
        ]
    }

    private func epistleQuestions(book: String, reference: String) -> [QuizQuestion] {
        [
            QuizQuestion(
                question: "What instruction does this epistle give for Christian living?",
                correctAnswer: "Live by faith, love others, and follow Christ",
                wrongAnswers: ["Follow strict rules for salvation", "Live however you want", "Isolate from the world"],
                verseReference: reference
            ),
            QuizQuestion(
                question: "How does this passage describe our identity in Christ?",
                correctAnswer: "We are new creations, forgiven and loved",
                wrongAnswers: ["We must earn God's favor", "We are still condemned", "We are on our own"],
                verseReference: reference
            )
        ]
    }

    private func getThemeTeaching(_ theme: String) -> String {
        let teachings: [String: String] = [
            "Creation": "God created everything good and with purpose",
            "Humanity": "Humans are made in God's image with inherent dignity",
            "Sin": "Sin separates us from God but He provides a way back",
            "Covenant": "God makes and keeps His promises faithfully",
            "Faith": "Trusting God even when circumstances are difficult",
            "Salvation": "God alone saves through His grace and power",
            "Law": "God's commands reveal His character and guide our lives",
            "Guidance": "God leads those who trust in Him",
            "Repentance": "Turning from sin to God brings forgiveness",
            "Scripture": "God's Word is truth and transforms us",
            "Trust": "We should rely on God completely",
            "Wisdom": "True wisdom begins with fearing the Lord",
            "Prophecy": "God reveals His plans and keeps His promises",
            "Transformation": "God changes hearts and makes us new",
            "Incarnation": "God became human to save us",
            "Kingdom Living": "Living according to God's values and ways",
            "Prayer": "Communion with God who hears and answers",
            "Peace": "God provides peace that transcends circumstances",
            "Love": "God's love is sacrificial and unconditional",
            "Grace": "Unmerited favor from God to undeserving sinners",
            "Divinity": "Jesus is fully God",
            "New Life": "Spiritual rebirth through faith in Christ",
            "Protection": "God guards and keeps His people",
            "Righteousness": "Right standing with God through faith",
            "Assurance": "Confidence in God's unfailing love",
            "Character": "God shapes us to be like Christ",
            "Spiritual Warfare": "Standing firm in God's strength against evil",
            "Victory": "Christ has overcome and we share in His triumph",
            "Obedience": "Following God's commands out of love",
            "Faithfulness": "Remaining true to God regardless of circumstances",
            "Hope": "Confident expectation in God's promises",
            "Courage": "Boldness that comes from trusting God",
            "Provision": "God supplies all our needs",
            "Calling": "God's purpose and mission for our lives",
            "Worship": "Honoring God with our whole lives",
            "Service": "Serving others as unto the Lord",
            "Forgiveness": "Releasing others as God has released us",
            "Resurrection": "Victory over death through Christ",
            "Sacrifice": "Giving up something valuable for a greater purpose",
            "Identity": "Who we are in Christ",
            "Perseverance": "Enduring faithfully through trials",
            "Joy": "Deep gladness rooted in God's presence",
            "Humility": "Recognizing our dependence on God",
            "Purpose": "Living for God's glory and kingdom",
            "Eternity": "Life forever with God"
        ]
        return teachings[theme] ?? "God's faithfulness and love for His people"
    }

    private func getWrongThemeTeachings(_ theme: String) -> [String] {
        [
            "We must earn God's acceptance through works",
            "God is distant and uninvolved in our lives",
            "Human effort is the key to spiritual growth"
        ]
    }

    // MARK: - Comprehensive Question Banks by Book

    private var questionsByBook: [String: [QuizQuestion]] {
        [
            "Genesis": [
                QuizQuestion(question: "In whose image was humanity created?", correctAnswer: "God's image", wrongAnswers: ["Angels' image", "Nature's image", "Animals' image"], verseReference: "Genesis 1:27"),
                QuizQuestion(question: "What did God say about His creation?", correctAnswer: "It was very good", wrongAnswers: ["It was adequate", "It needed work", "It was incomplete"], verseReference: "Genesis 1:31"),
                QuizQuestion(question: "What was the consequence of eating the forbidden fruit?", correctAnswer: "Death and separation from God", wrongAnswers: ["Immediate physical death only", "Nothing happened", "They gained equal power to God"], verseReference: "Genesis 3"),
                QuizQuestion(question: "What did God promise Abraham?", correctAnswer: "To make him a great nation and bless all peoples through him", wrongAnswers: ["Immediate wealth", "Political power", "Long life only"], verseReference: "Genesis 12:2-3"),
                QuizQuestion(question: "How did Abraham demonstrate his faith on Mount Moriah?", correctAnswer: "He was willing to sacrifice Isaac, trusting God", wrongAnswers: ["He bargained with God", "He ran away", "He refused God's command"], verseReference: "Genesis 22")
            ],
            "Exodus": [
                QuizQuestion(question: "How did God appear to Moses at the burning bush?", correctAnswer: "As a fire that did not consume the bush", wrongAnswers: ["As a bright light", "As a loud voice only", "As an angel"], verseReference: "Exodus 3"),
                QuizQuestion(question: "What name did God reveal to Moses?", correctAnswer: "I AM WHO I AM", wrongAnswers: ["The Almighty One", "The Creator", "The King"], verseReference: "Exodus 3:14"),
                QuizQuestion(question: "How did God deliver Israel at the Red Sea?", correctAnswer: "He parted the waters for them to cross", wrongAnswers: ["He built a bridge", "They swam across", "They went around"], verseReference: "Exodus 14"),
                QuizQuestion(question: "What is the first of the Ten Commandments?", correctAnswer: "You shall have no other gods before me", wrongAnswers: ["Do not murder", "Honor your parents", "Do not steal"], verseReference: "Exodus 20:3"),
                QuizQuestion(question: "Why did God give the Law to Israel?", correctAnswer: "To show them how to live as His holy people", wrongAnswers: ["To make salvation impossible", "To punish them", "To limit their freedom"], verseReference: "Exodus 20")
            ],
            "Psalms": [
                QuizQuestion(question: "According to Psalm 23, who is the Lord?", correctAnswer: "My shepherd", wrongAnswers: ["My king only", "My judge", "My servant"], verseReference: "Psalm 23:1"),
                QuizQuestion(question: "What does the Psalmist say about God's Word?", correctAnswer: "It is a lamp to my feet and light to my path", wrongAnswers: ["It is too difficult to understand", "It is outdated", "It is optional"], verseReference: "Psalm 119:105"),
                QuizQuestion(question: "Where has the Psalmist hidden God's Word?", correctAnswer: "In my heart", wrongAnswers: ["In a book", "Under my bed", "In the temple"], verseReference: "Psalm 119:11"),
                QuizQuestion(question: "What sacrifice does God desire according to Psalm 51?", correctAnswer: "A broken and contrite heart", wrongAnswers: ["Burnt offerings", "Gold and silver", "Animal sacrifices"], verseReference: "Psalm 51:17"),
                QuizQuestion(question: "How does Psalm 139 describe God's knowledge of us?", correctAnswer: "He knows us completely, even before we were born", wrongAnswers: ["He only knows our actions", "He learns about us over time", "He doesn't pay attention"], verseReference: "Psalm 139")
            ],
            "Proverbs": [
                QuizQuestion(question: "What is the beginning of wisdom?", correctAnswer: "The fear of the LORD", wrongAnswers: ["Education", "Experience", "Age"], verseReference: "Proverbs 9:10"),
                QuizQuestion(question: "What should we trust with all our heart?", correctAnswer: "The LORD", wrongAnswers: ["Our own understanding", "Our feelings", "Other people"], verseReference: "Proverbs 3:5"),
                QuizQuestion(question: "What happens when we acknowledge God in all our ways?", correctAnswer: "He makes our paths straight", wrongAnswers: ["Life becomes easy", "We become wealthy", "Nothing changes"], verseReference: "Proverbs 3:6"),
                QuizQuestion(question: "What should we guard above all else?", correctAnswer: "Our heart, for it is the wellspring of life", wrongAnswers: ["Our money", "Our reputation", "Our possessions"], verseReference: "Proverbs 4:23"),
                QuizQuestion(question: "How does Proverbs describe a fool?", correctAnswer: "One who despises wisdom and instruction", wrongAnswers: ["One who lacks education", "One who is poor", "One who is young"], verseReference: "Proverbs 1:7")
            ],
            "Isaiah": [
                QuizQuestion(question: "What did Isaiah see in his vision of God?", correctAnswer: "The Lord seated on a throne, high and exalted", wrongAnswers: ["An empty temple", "A burning fire only", "Angels fighting"], verseReference: "Isaiah 6"),
                QuizQuestion(question: "What did Isaiah respond when God asked 'Who will go for us?'", correctAnswer: "Here am I, send me!", wrongAnswers: ["Send someone else", "I am not worthy", "Give me time to think"], verseReference: "Isaiah 6:8"),
                QuizQuestion(question: "According to Isaiah 53, whose sins did the servant bear?", correctAnswer: "Ours", wrongAnswers: ["His own", "Only Israel's", "No one's"], verseReference: "Isaiah 53:5"),
                QuizQuestion(question: "What happens to those who wait on the LORD?", correctAnswer: "They will renew their strength and soar like eagles", wrongAnswers: ["They will grow impatient", "Nothing special", "They will be disappointed"], verseReference: "Isaiah 40:31"),
                QuizQuestion(question: "By what are we healed according to Isaiah 53?", correctAnswer: "His wounds", wrongAnswers: ["Our efforts", "Time", "Medicine"], verseReference: "Isaiah 53:5")
            ],
            "Matthew": [
                QuizQuestion(question: "Who does Jesus say are blessed in the Beatitudes?", correctAnswer: "The poor in spirit, those who mourn, the meek", wrongAnswers: ["The wealthy and powerful", "The self-sufficient", "The proud"], verseReference: "Matthew 5"),
                QuizQuestion(question: "How does Jesus teach us to pray?", correctAnswer: "Our Father in heaven, hallowed be your name...", wrongAnswers: ["With many words to impress others", "Only in the temple", "Demanding what we want"], verseReference: "Matthew 6:9"),
                QuizQuestion(question: "What should we seek first?", correctAnswer: "God's kingdom and His righteousness", wrongAnswers: ["Wealth and security", "Personal happiness", "Fame and power"], verseReference: "Matthew 6:33"),
                QuizQuestion(question: "What does Jesus say about worry?", correctAnswer: "Do not worry; God cares for you more than the birds and flowers", wrongAnswers: ["Worry shows you care", "Worry is unavoidable", "Worry solves problems"], verseReference: "Matthew 6:25-34"),
                QuizQuestion(question: "What commission did Jesus give His disciples?", correctAnswer: "Go and make disciples of all nations", wrongAnswers: ["Stay in Jerusalem only", "Focus on Israel alone", "Build large buildings"], verseReference: "Matthew 28:19")
            ],
            "John": [
                QuizQuestion(question: "What was in the beginning according to John 1?", correctAnswer: "The Word (who was with God and was God)", wrongAnswers: ["Darkness", "Angels", "The earth"], verseReference: "John 1:1"),
                QuizQuestion(question: "What must a person be to see the kingdom of God?", correctAnswer: "Born again", wrongAnswers: ["Very religious", "Perfectly sinless", "Well-educated"], verseReference: "John 3:3"),
                QuizQuestion(question: "For God so loved the world that He gave His only ___?", correctAnswer: "Son", wrongAnswers: ["Law", "Prophet", "Angel"], verseReference: "John 3:16"),
                QuizQuestion(question: "What does Jesus call Himself in John 10?", correctAnswer: "The Good Shepherd", wrongAnswers: ["The Great King", "The Wise Teacher", "The Mighty Warrior"], verseReference: "John 10:11"),
                QuizQuestion(question: "Jesus said, 'I am the way, the truth, and the ___'", correctAnswer: "Life", wrongAnswers: ["Light", "Law", "Lord"], verseReference: "John 14:6"),
                QuizQuestion(question: "What did Jesus say He came to give us?", correctAnswer: "Life, and life abundantly", wrongAnswers: ["Wealth", "Political freedom", "Easy lives"], verseReference: "John 10:10")
            ],
            "Romans": [
                QuizQuestion(question: "How are we justified according to Romans?", correctAnswer: "By faith, not by works", wrongAnswers: ["By keeping the law", "By our good deeds", "By religious rituals"], verseReference: "Romans 5:1"),
                QuizQuestion(question: "What demonstrates God's love for us?", correctAnswer: "While we were still sinners, Christ died for us", wrongAnswers: ["Our good behavior", "Our religious efforts", "Our worthiness"], verseReference: "Romans 5:8"),
                QuizQuestion(question: "What can separate us from the love of Christ?", correctAnswer: "Nothing", wrongAnswers: ["Sin", "Death", "Suffering"], verseReference: "Romans 8:38-39"),
                QuizQuestion(question: "What should we offer to God as living sacrifices?", correctAnswer: "Our bodies (our whole selves)", wrongAnswers: ["Animals", "Money only", "Our possessions"], verseReference: "Romans 12:1"),
                QuizQuestion(question: "What are we in Christ according to Romans 8?", correctAnswer: "More than conquerors", wrongAnswers: ["Barely surviving", "Still condemned", "On our own"], verseReference: "Romans 8:37")
            ],
            "1 Corinthians": [
                QuizQuestion(question: "What is the greatest of faith, hope, and love?", correctAnswer: "Love", wrongAnswers: ["Faith", "Hope", "They are all equal"], verseReference: "1 Corinthians 13:13"),
                QuizQuestion(question: "What is love according to 1 Corinthians 13?", correctAnswer: "Patient and kind, not envious or boastful", wrongAnswers: ["A feeling only", "Getting what you want", "Conditional on others' behavior"], verseReference: "1 Corinthians 13:4"),
                QuizQuestion(question: "Without love, what is speaking in tongues compared to?", correctAnswer: "A resounding gong or clanging cymbal", wrongAnswers: ["Beautiful music", "Powerful preaching", "Divine revelation"], verseReference: "1 Corinthians 13:1")
            ],
            "Galatians": [
                QuizQuestion(question: "What are the fruits of the Spirit?", correctAnswer: "Love, joy, peace, patience, kindness, goodness, faithfulness, gentleness, self-control", wrongAnswers: ["Wealth, power, fame", "Religious rituals", "Strict rule-following"], verseReference: "Galatians 5:22-23"),
                QuizQuestion(question: "How should we live to avoid gratifying the flesh?", correctAnswer: "Walk by the Spirit", wrongAnswers: ["Follow strict rules", "Isolate ourselves", "Try harder on our own"], verseReference: "Galatians 5:16"),
                QuizQuestion(question: "What have those who belong to Christ crucified?", correctAnswer: "The flesh with its passions and desires", wrongAnswers: ["Their families", "Their hopes", "Their futures"], verseReference: "Galatians 5:24")
            ],
            "Ephesians": [
                QuizQuestion(question: "What should we put on to stand against the devil?", correctAnswer: "The full armor of God", wrongAnswers: ["Physical weapons", "Our own strength", "Political power"], verseReference: "Ephesians 6:11"),
                QuizQuestion(question: "What is the sword of the Spirit?", correctAnswer: "The Word of God", wrongAnswers: ["Prayer", "Fasting", "Good works"], verseReference: "Ephesians 6:17"),
                QuizQuestion(question: "What is the shield that extinguishes flaming arrows?", correctAnswer: "Faith", wrongAnswers: ["Hope", "Love", "Wealth"], verseReference: "Ephesians 6:16"),
                QuizQuestion(question: "By what are we saved according to Ephesians 2?", correctAnswer: "Grace through faith, not works", wrongAnswers: ["Our good deeds", "Religious ceremonies", "Our own efforts"], verseReference: "Ephesians 2:8-9")
            ],
            "Philippians": [
                QuizQuestion(question: "What attitude should we have according to Philippians 2?", correctAnswer: "The same attitude as Christ Jesus, who humbled Himself", wrongAnswers: ["Pride in our accomplishments", "Self-promotion", "Competitiveness"], verseReference: "Philippians 2:5"),
                QuizQuestion(question: "What should we do instead of being anxious?", correctAnswer: "Present our requests to God with thanksgiving", wrongAnswers: ["Worry more", "Figure it out ourselves", "Ignore problems"], verseReference: "Philippians 4:6"),
                QuizQuestion(question: "What will guard our hearts and minds?", correctAnswer: "The peace of God", wrongAnswers: ["Wealth", "Power", "Walls"], verseReference: "Philippians 4:7")
            ],
            "Hebrews": [
                QuizQuestion(question: "What is faith according to Hebrews 11?", correctAnswer: "Confidence in what we hope for and assurance of what we do not see", wrongAnswers: ["Blind belief without evidence", "A feeling", "Religious activity"], verseReference: "Hebrews 11:1"),
                QuizQuestion(question: "Who are the heroes listed in Hebrews 11?", correctAnswer: "Those who lived by faith: Abel, Noah, Abraham, Moses, and many others", wrongAnswers: ["The wealthy and powerful", "Political leaders", "Military conquerors"], verseReference: "Hebrews 11")
            ],
            "James": [
                QuizQuestion(question: "How should we consider trials according to James?", correctAnswer: "Pure joy, because testing produces perseverance", wrongAnswers: ["Punishment from God", "Bad luck", "Reasons to give up"], verseReference: "James 1:2-3"),
                QuizQuestion(question: "What should we do if we lack wisdom?", correctAnswer: "Ask God, who gives generously", wrongAnswers: ["Give up", "Rely on ourselves", "Ignore the problem"], verseReference: "James 1:5"),
                QuizQuestion(question: "What kind of faith is dead according to James?", correctAnswer: "Faith without works", wrongAnswers: ["New faith", "Quiet faith", "Private faith"], verseReference: "James 2:17")
            ],
            "1 Peter": [
                QuizQuestion(question: "What does Peter call believers?", correctAnswer: "A chosen people, a royal priesthood, a holy nation", wrongAnswers: ["Servants only", "Ordinary people", "Outsiders"], verseReference: "1 Peter 2:9"),
                QuizQuestion(question: "Who are we being built into as living stones?", correctAnswer: "A spiritual house", wrongAnswers: ["A physical temple", "A political kingdom", "An earthly organization"], verseReference: "1 Peter 2:5")
            ],
            "1 John": [
                QuizQuestion(question: "How does 1 John describe God?", correctAnswer: "God is love", wrongAnswers: ["God is angry", "God is distant", "God is indifferent"], verseReference: "1 John 4:8"),
                QuizQuestion(question: "What does perfect love cast out?", correctAnswer: "Fear", wrongAnswers: ["Joy", "Hope", "Faith"], verseReference: "1 John 4:18"),
                QuizQuestion(question: "Why do we love?", correctAnswer: "Because He first loved us", wrongAnswers: ["To earn salvation", "To look good", "Because we have to"], verseReference: "1 John 4:19")
            ],
            "Revelation": [
                QuizQuestion(question: "What does Revelation 21 promise?", correctAnswer: "A new heaven and new earth where God dwells with His people", wrongAnswers: ["The end of everything", "Eternal suffering", "An empty universe"], verseReference: "Revelation 21"),
                QuizQuestion(question: "What will God wipe away in the new creation?", correctAnswer: "Every tear from their eyes", wrongAnswers: ["Their memories", "Their identities", "Their joy"], verseReference: "Revelation 21:4")
            ]
        ]
    }

    // MARK: - Chapter-Specific Questions

    private var questionsByChapter: [String: [QuizQuestion]] {
        [
            "Genesis_1": [
                QuizQuestion(question: "What did God create on the first day?", correctAnswer: "Light", wrongAnswers: ["The sun", "Animals", "Humans"], verseReference: "Genesis 1:3"),
                QuizQuestion(question: "How many days did creation take?", correctAnswer: "Six days", wrongAnswers: ["Seven days", "One day", "Many years"], verseReference: "Genesis 1")
            ],
            "Genesis_3": [
                QuizQuestion(question: "Who tempted Eve?", correctAnswer: "The serpent", wrongAnswers: ["Adam", "An angel", "A stranger"], verseReference: "Genesis 3:1"),
                QuizQuestion(question: "What did Adam and Eve do after sinning?", correctAnswer: "Hid from God", wrongAnswers: ["Ran to God", "Nothing", "Blamed each other first"], verseReference: "Genesis 3:8")
            ],
            "Psalm_23": [
                QuizQuestion(question: "What does the shepherd do in green pastures?", correctAnswer: "Makes me lie down", wrongAnswers: ["Makes me work", "Leaves me alone", "Tests me"], verseReference: "Psalm 23:2"),
                QuizQuestion(question: "What will follow me all the days of my life?", correctAnswer: "Goodness and mercy", wrongAnswers: ["Trouble and sorrow", "Wealth and fame", "Nothing"], verseReference: "Psalm 23:6")
            ],
            "John_3": [
                QuizQuestion(question: "Who visited Jesus at night?", correctAnswer: "Nicodemus", wrongAnswers: ["Peter", "John", "Judas"], verseReference: "John 3:1-2"),
                QuizQuestion(question: "What did Jesus say happens to those who believe?", correctAnswer: "They have eternal life", wrongAnswers: ["They become wealthy", "They never struggle", "Nothing changes"], verseReference: "John 3:16")
            ]
        ]
    }

    // MARK: - Theme-Based Questions

    private var questionsByTheme: [String: [QuizQuestion]] {
        [
            "Faith": [
                QuizQuestion(question: "What does it mean to have faith?", correctAnswer: "Trusting God even when we can't see the outcome", wrongAnswers: ["Believing only when we see proof", "Having no doubts ever", "Feeling confident always"], verseReference: "Hebrews 11:1"),
                QuizQuestion(question: "How is faith demonstrated in the Bible?", correctAnswer: "Through obedience and trust in God's promises", wrongAnswers: ["Through perfect behavior", "Through religious rituals only", "Through earning God's favor"], verseReference: "James 2:17")
            ],
            "Love": [
                QuizQuestion(question: "How does the Bible describe God's love?", correctAnswer: "Unconditional, sacrificial, and eternal", wrongAnswers: ["Conditional on our behavior", "Limited to certain people", "A reward for good works"], verseReference: "1 John 4:8"),
                QuizQuestion(question: "How should we love others?", correctAnswer: "As Christ loved us—sacrificially", wrongAnswers: ["Only when they deserve it", "To get something in return", "Only those like us"], verseReference: "John 13:34")
            ],
            "Grace": [
                QuizQuestion(question: "What is grace?", correctAnswer: "Unmerited favor from God", wrongAnswers: ["Payment for good deeds", "What we earn through effort", "A temporary blessing"], verseReference: "Ephesians 2:8"),
                QuizQuestion(question: "How do we receive God's grace?", correctAnswer: "Through faith, not works", wrongAnswers: ["By being good enough", "By religious ceremonies", "By earning it"], verseReference: "Ephesians 2:8-9")
            ],
            "Salvation": [
                QuizQuestion(question: "Who can save us according to the Bible?", correctAnswer: "God alone through Jesus Christ", wrongAnswers: ["We save ourselves", "Any religious leader", "Good works alone"], verseReference: "Acts 4:12"),
                QuizQuestion(question: "What must we do to be saved?", correctAnswer: "Believe in the Lord Jesus", wrongAnswers: ["Be perfect", "Pay a price", "Complete many rituals"], verseReference: "Acts 16:31")
            ]
        ]
    }
}
