import Foundation

@MainActor
class MemoryViewModel: ObservableObject {
    @Published var cards: [MemoryCard] = []
    @Published var currentCardIndex = 0

    private let dataService = BibleDataService()

    func loadCards(for day: ReadingDay) {
        // Load memory verse cards for the day
        cards = generateCards(for: day)
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

        case 11:
            generatedCards = [
                MemoryCard(
                    reference: "Proverbs 3:5-6",
                    text: "Trust in the LORD with all your heart, and do not lean on your own understanding. In all your ways acknowledge him, and he will make straight your paths."
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
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].masteryLevel = min(5, cards[index].masteryLevel + 1)
        }
    }

    func markNeedsReview(_ card: MemoryCard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].masteryLevel = max(0, cards[index].masteryLevel - 1)
        }
    }

    var masteredCount: Int {
        cards.filter { $0.masteryLevel >= 3 }.count
    }

    var progress: Double {
        guard !cards.isEmpty else { return 0 }
        return Double(masteredCount) / Double(cards.count)
    }
}
