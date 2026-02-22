import SwiftUI

struct VerseCard: View {
    let verse: BibleVerse
    var showReference: Bool = true
    var style: VerseCardStyle = .default

    enum VerseCardStyle {
        case `default`
        case compact
        case featured
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showReference {
                Text(verse.reference)
                    .font(referenceFont)
                    .foregroundStyle(.indigo)
            }

            Text(verse.text)
                .font(textFont)
                .lineSpacing(lineSpacing)
                .foregroundStyle(.primary)
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay {
            if style == .featured {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.indigo.opacity(0.3), lineWidth: 1)
            }
        }
    }

    private var referenceFont: Font {
        switch style {
        case .compact: return .caption
        case .default: return .subheadline
        case .featured: return .headline
        }
    }

    private var textFont: Font {
        switch style {
        case .compact: return .caption
        case .default: return .body
        case .featured: return .title3
        }
    }

    private var lineSpacing: CGFloat {
        switch style {
        case .compact: return 2
        case .default: return 4
        case .featured: return 6
        }
    }

    private var padding: CGFloat {
        switch style {
        case .compact: return 8
        case .default: return 12
        case .featured: return 16
        }
    }

    private var cornerRadius: CGFloat {
        switch style {
        case .compact: return 8
        case .default: return 12
        case .featured: return 16
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .compact: return .clear
        case .default: return Color(.systemGray6)
        case .featured: return Color(.systemBackground)
        }
    }
}

struct PassageCard: View {
    let passage: BiblePassage
    var maxVerses: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Reference header
            HStack {
                Text(passage.reference)
                    .font(.headline)
                    .foregroundStyle(.indigo)

                Spacer()

                Image(systemName: "book.fill")
                    .foregroundStyle(.indigo.opacity(0.5))
            }

            Divider()

            // Verses
            let versesToShow = maxVerses != nil ? Array(passage.verses.prefix(maxVerses!)) : passage.verses

            ForEach(versesToShow) { verse in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(verse.verse)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 20, alignment: .trailing)

                    Text(verse.text)
                        .font(.body)
                }
            }

            if let max = maxVerses, passage.verses.count > max {
                Text("+ \(passage.verses.count - max) more verses")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
}

struct QuoteCard: View {
    let text: String
    let reference: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.title)
                .foregroundStyle(.indigo.opacity(0.3))

            Text(text)
                .font(.body)
                .italic()
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("— \(reference)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.indigo.opacity(0.05), .purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            VerseCard(
                verse: BibleVerse(
                    book: "John",
                    chapter: 3,
                    verse: 16,
                    text: "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life."
                ),
                style: .featured
            )

            VerseCard(
                verse: BibleVerse(
                    book: "Psalm",
                    chapter: 23,
                    verse: 1,
                    text: "The LORD is my shepherd; I shall not want."
                ),
                style: .default
            )

            VerseCard(
                verse: BibleVerse(
                    book: "Proverbs",
                    chapter: 3,
                    verse: 5,
                    text: "Trust in the LORD with all your heart."
                ),
                style: .compact
            )

            QuoteCard(
                text: "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.",
                reference: "John 3:16"
            )
        }
        .padding()
    }
}
