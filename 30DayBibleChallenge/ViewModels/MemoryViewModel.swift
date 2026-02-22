import Foundation
import SwiftData

@MainActor
class MemoryViewModel: ObservableObject {
    @Published var cards: [MemoryCard] = []
    @Published var currentCardIndex = 0

    private let dataService = BibleDataService()
    private var modelContext: ModelContext?
    private var masteryCache: [String: VerseMastery] = [:]

    func loadCards(for day: ReadingDay, context: ModelContext) {
        self.modelContext = context
        cards = generateCards(for: day)
        loadMasteryLevels()
    }

    private func loadMasteryLevels() {
        guard let context = modelContext else { return }

        // Fetch all mastery records for current card references
        let references = cards.map { $0.reference }

        for reference in references {
            let descriptor = FetchDescriptor<VerseMastery>(
                predicate: #Predicate { $0.verseReference == reference }
            )

            if let existing = try? context.fetch(descriptor).first {
                masteryCache[reference] = existing
                // Update card's mastery level
                if let index = cards.firstIndex(where: { $0.reference == reference }) {
                    cards[index].masteryLevel = existing.masteryLevel
                }
            }
        }
    }

    private func generateCards(for day: ReadingDay) -> [MemoryCard] {
        // Generate memory verse cards based on the day's content
        var generatedCards: [MemoryCard] = []

        switch day.id {
        case 1:
            generatedCards = [
                MemoryCard(
                    reference: "Genesis 1:1",
                    text: "In the beginning God created the heavens and the earth."
                ),
                MemoryCard(
                    reference: "Genesis 1:27",
                    text: "So God created man in his own image, in the image of God he created him; male and female he created them."
                ),
                MemoryCard(
                    reference: "Genesis 1:31",
                    text: "And God saw everything that he had made, and behold, it was very good."
                )
            ]

        case 2:
            generatedCards = [
                MemoryCard(
                    reference: "Genesis 2:7",
                    text: "Then the LORD God formed the man of dust from the ground and breathed into his nostrils the breath of life, and the man became a living creature."
                ),
                MemoryCard(
                    reference: "Genesis 2:18",
                    text: "Then the LORD God said, 'It is not good that the man should be alone; I will make him a helper fit for him.'"
                )
            ]

        case 3:
            generatedCards = [
                MemoryCard(
                    reference: "Genesis 3:15",
                    text: "I will put enmity between you and the woman, and between your offspring and her offspring; he shall bruise your head, and you shall bruise his heel."
                )
            ]

        case 4:
            generatedCards = [
                MemoryCard(
                    reference: "Genesis 12:2-3",
                    text: "And I will make of you a great nation, and I will bless you and make your name great, so that you will be a blessing. I will bless those who bless you, and him who dishonors you I will curse."
                )
            ]

        case 5:
            generatedCards = [
                MemoryCard(
                    reference: "Genesis 22:8",
                    text: "Abraham said, 'God will provide for himself the lamb for a burnt offering, my son.' So they went both of them together."
                )
            ]

        case 6:
            generatedCards = [
                MemoryCard(
                    reference: "Exodus 3:14",
                    text: "God said to Moses, 'I AM WHO I AM.' And he said, 'Say this to the people of Israel: I AM has sent me to you.'"
                )
            ]

        case 7:
            generatedCards = [
                MemoryCard(
                    reference: "Exodus 20:3",
                    text: "You shall have no other gods before me."
                ),
                MemoryCard(
                    reference: "Exodus 20:12",
                    text: "Honor your father and your mother, that your days may be long in the land that the LORD your God is giving you."
                )
            ]

        case 8:
            generatedCards = [
                MemoryCard(
                    reference: "Psalm 23:1",
                    text: "The LORD is my shepherd; I shall not want."
                ),
                MemoryCard(
                    reference: "Psalm 23:4",
                    text: "Even though I walk through the valley of the shadow of death, I will fear no evil, for you are with me."
                ),
                MemoryCard(
                    reference: "Psalm 23:6",
                    text: "Surely goodness and mercy shall follow me all the days of my life, and I shall dwell in the house of the LORD forever."
                )
            ]

        case 9:
            generatedCards = [
                MemoryCard(
                    reference: "Psalm 1:1-2",
                    text: "Blessed is the man who walks not in the counsel of the wicked, nor stands in the way of sinners, nor sits in the seat of scoffers; but his delight is in the law of the LORD."
                )
            ]

        case 10:
            generatedCards = [
                MemoryCard(
                    reference: "Psalm 119:105",
                    text: "Your word is a lamp to my feet and a light to my path."
                ),
                MemoryCard(
                    reference: "Psalm 119:11",
                    text: "I have stored up your word in my heart, that I might not sin against you."
                )
            ]

        case 11:
            generatedCards = [
                MemoryCard(
                    reference: "Proverbs 3:5-6",
                    text: "Trust in the LORD with all your heart, and do not lean on your own understanding. In all your ways acknowledge him, and he will make straight your paths."
                )
            ]

        case 12:
            generatedCards = [
                MemoryCard(
                    reference: "Proverbs 1:7",
                    text: "The fear of the LORD is the beginning of knowledge; fools despise wisdom and instruction."
                )
            ]

        case 13:
            generatedCards = [
                MemoryCard(
                    reference: "Isaiah 53:5",
                    text: "But he was pierced for our transgressions; he was crushed for our iniquities; upon him was the chastisement that brought us peace."
                )
            ]

        case 14:
            generatedCards = [
                MemoryCard(
                    reference: "Isaiah 40:31",
                    text: "But they who wait for the LORD shall renew their strength; they shall mount up with wings like eagles; they shall run and not be weary."
                )
            ]

        case 15:
            generatedCards = [
                MemoryCard(
                    reference: "Jeremiah 29:11",
                    text: "For I know the plans I have for you, declares the LORD, plans for welfare and not for evil, to give you a future and a hope."
                )
            ]

        case 16:
            generatedCards = [
                MemoryCard(
                    reference: "Daniel 3:17-18",
                    text: "Our God whom we serve is able to deliver us from the burning fiery furnace, and he will deliver us out of your hand, O king."
                )
            ]

        case 17:
            generatedCards = [
                MemoryCard(
                    reference: "Micah 6:8",
                    text: "He has told you, O man, what is good; and what does the LORD require of you but to do justice, and to love kindness, and to walk humbly with your God?"
                )
            ]

        case 18:
            generatedCards = [
                MemoryCard(
                    reference: "Matthew 5:14",
                    text: "You are the light of the world. A city set on a hill cannot be hidden."
                ),
                MemoryCard(
                    reference: "Matthew 5:16",
                    text: "Let your light shine before others, so that they may see your good works and give glory to your Father who is in heaven."
                )
            ]

        case 19:
            generatedCards = [
                MemoryCard(
                    reference: "Matthew 6:33",
                    text: "But seek first the kingdom of God and his righteousness, and all these things will be added to you."
                )
            ]

        case 20:
            generatedCards = [
                MemoryCard(
                    reference: "Matthew 11:28",
                    text: "Come to me, all who labor and are heavy laden, and I will give you rest."
                )
            ]

        case 21:
            generatedCards = [
                MemoryCard(
                    reference: "Matthew 28:19-20",
                    text: "Go therefore and make disciples of all nations, baptizing them in the name of the Father and of the Son and of the Holy Spirit, teaching them to observe all that I have commanded you."
                )
            ]

        case 22:
            generatedCards = [
                MemoryCard(
                    reference: "John 3:3",
                    text: "Jesus answered him, 'Truly, truly, I say to you, unless one is born again he cannot see the kingdom of God.'"
                ),
                MemoryCard(
                    reference: "John 3:16",
                    text: "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life."
                ),
                MemoryCard(
                    reference: "John 3:17",
                    text: "For God did not send his Son into the world to condemn the world, but in order that the world might be saved through him."
                )
            ]

        case 23:
            generatedCards = [
                MemoryCard(
                    reference: "John 14:6",
                    text: "Jesus said to him, 'I am the way, and the truth, and the life. No one comes to the Father except through me.'"
                )
            ]

        case 24:
            generatedCards = [
                MemoryCard(
                    reference: "Acts 1:8",
                    text: "But you will receive power when the Holy Spirit has come upon you, and you will be my witnesses in Jerusalem and in all Judea and Samaria, and to the end of the earth."
                )
            ]

        case 25:
            generatedCards = [
                MemoryCard(
                    reference: "Acts 2:38",
                    text: "And Peter said to them, 'Repent and be baptized every one of you in the name of Jesus Christ for the forgiveness of your sins, and you will receive the gift of the Holy Spirit.'"
                )
            ]

        case 26:
            generatedCards = [
                MemoryCard(
                    reference: "Romans 3:23",
                    text: "For all have sinned and fall short of the glory of God."
                ),
                MemoryCard(
                    reference: "Romans 6:23",
                    text: "For the wages of sin is death, but the free gift of God is eternal life in Christ Jesus our Lord."
                )
            ]

        case 27:
            generatedCards = [
                MemoryCard(
                    reference: "Romans 8:28",
                    text: "And we know that for those who love God all things work together for good, for those who are called according to his purpose."
                ),
                MemoryCard(
                    reference: "Romans 8:38-39",
                    text: "For I am sure that neither death nor life, nor angels nor rulers, nor things present nor things to come, nor powers, nor height nor depth, nor anything else in all creation, will be able to separate us from the love of God in Christ Jesus our Lord."
                )
            ]

        case 28:
            generatedCards = [
                MemoryCard(
                    reference: "1 Corinthians 13:4-5",
                    text: "Love is patient and kind; love does not envy or boast; it is not arrogant or rude."
                ),
                MemoryCard(
                    reference: "1 Corinthians 13:13",
                    text: "So now faith, hope, and love abide, these three; but the greatest of these is love."
                )
            ]

        case 29:
            generatedCards = [
                MemoryCard(
                    reference: "Galatians 5:22-23",
                    text: "But the fruit of the Spirit is love, joy, peace, patience, kindness, goodness, faithfulness, gentleness, self-control; against such things there is no law."
                )
            ]

        case 30:
            generatedCards = [
                MemoryCard(
                    reference: "Ephesians 6:11",
                    text: "Put on the whole armor of God, that you may be able to stand against the schemes of the devil."
                ),
                MemoryCard(
                    reference: "Ephesians 6:12",
                    text: "For we do not wrestle against flesh and blood, but against the rulers, against the authorities, against the cosmic powers over this present darkness."
                )
            ]

        default:
            // Create a default card for the day's memory verse
            generatedCards = [
                MemoryCard(
                    reference: day.memoryVerse,
                    text: "Memory verse from \(day.book) - \(day.theme)"
                )
            ]
        }

        return generatedCards
    }

    func markMastered(_ card: MemoryCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }

        cards[index].masteryLevel = min(5, cards[index].masteryLevel + 1)
        saveMastery(for: cards[index])
    }

    func markNeedsReview(_ card: MemoryCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }

        cards[index].masteryLevel = max(0, cards[index].masteryLevel - 1)
        saveMastery(for: cards[index])
    }

    func saveMastery(for card: MemoryCard) {
        guard let context = modelContext else { return }

        if let existing = masteryCache[card.reference] {
            // Update existing record
            existing.masteryLevel = card.masteryLevel
            existing.lastReviewedDate = Date()
            existing.nextReviewDate = VerseMastery.calculateNextReview(masteryLevel: card.masteryLevel)
        } else {
            // Create new record
            let mastery = VerseMastery(verseReference: card.reference, masteryLevel: card.masteryLevel)
            context.insert(mastery)
            masteryCache[card.reference] = mastery
        }

        try? context.save()
    }

    func saveAllMastery() {
        guard let context = modelContext else { return }

        for card in cards {
            saveMastery(for: card)
        }

        try? context.save()
    }

    var masteredCount: Int {
        cards.filter { $0.masteryLevel >= 3 }.count
    }

    var progress: Double {
        guard !cards.isEmpty else { return 0 }
        return Double(masteredCount) / Double(cards.count)
    }
}
