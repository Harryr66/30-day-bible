import SwiftUI

// MARK: - App Theme Colors (Rustic + Playful)
extension Color {
    // Primary rustic colors
    static let appBrown = Color(hex: "8B5A2B")           // Warm saddle brown
    static let appBrownDark = Color(hex: "6B4423")       // Dark brown
    static let appBrownLight = Color(hex: "A67C52")      // Light brown/tan
    static let appCream = Color(hex: "FFF8F0")           // Warm cream
    static let appBeige = Color(hex: "F5E6D3")           // Soft beige

    // Fun accent colors (warm & playful)
    static let appGreen = Color(hex: "6B8E23")           // Olive/sage green
    static let appGreenDark = Color(hex: "556B2F")       // Dark olive
    static let appYellow = Color(hex: "DAA520")          // Goldenrod
    static let appOrange = Color(hex: "CD853F")          // Peru/terracotta
    static let appRed = Color(hex: "B22222")             // Firebrick red
    static let appBlue = Color(hex: "5F9EA0")            // Cadet blue
    static let appPurple = Color(hex: "9370DB")          // Medium purple
    static let appPink = Color(hex: "DB7093")            // Pale violet red
    static let appTeal = Color(hex: "008080")            // Teal accent

    // Background colors
    static let appBackground = Color(hex: "FFFAF5")      // Warm white
    static let appCardBackground = Color(hex: "FFFFFF")  // Pure white
    static let appCardBackgroundLight = Color(hex: "FFF5EB") // Slightly tinted

    // Text colors
    static let appTextPrimary = Color(hex: "3D2914")     // Dark brown text
    static let appTextSecondary = Color(hex: "8B7355")   // Medium brown text

    // Accent
    static let appAccent = appBrown

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Custom Button Styles
struct PlayfulButtonStyle: ButtonStyle {
    let color: Color
    let textColor: Color

    init(color: Color = .appBrown, textColor: Color = .white) {
        self.color = color
        self.textColor = textColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.opacity(0.3))
                        .offset(y: 4)
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color)
                        .offset(y: configuration.isPressed ? 4 : 0)
                }
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(Color.appBrown)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appBrownLight, lineWidth: 2)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.appCream))
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Playful Card Modifier
struct PlayfulCard: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(color)
                    .shadow(color: Color.appBrown.opacity(0.1), radius: 8, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.appBeige, lineWidth: 1)
            )
    }
}

extension View {
    func playfulCard(color: Color = .appCardBackground) -> some View {
        modifier(PlayfulCard(color: color))
    }
}

// MARK: - Rustic Card Modifier (with texture feel)
struct RusticCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.appCream)
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.appBeige.opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .shadow(color: Color.appBrown.opacity(0.15), radius: 6, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appBrownLight.opacity(0.3), lineWidth: 1)
            )
    }
}

extension View {
    func rusticCard() -> some View {
        modifier(RusticCard())
    }
}

// MARK: - Bounce Animation
struct BounceAnimation: ViewModifier {
    @State private var animate = false
    let delay: Double

    func body(content: Content) -> some View {
        content
            .offset(y: animate ? 0 : 20)
            .opacity(animate ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(delay)) {
                    animate = true
                }
            }
    }
}

extension View {
    func bounceIn(delay: Double = 0) -> some View {
        modifier(BounceAnimation(delay: delay))
    }
}

// MARK: - Mascot View (Rustic Bible Book Character)
struct MascotView: View {
    let mood: MascotMood
    let size: CGFloat

    enum MascotMood {
        case happy, excited, thinking, encouraging
    }

    var body: some View {
        ZStack {
            // Book spine shadow
            RoundedRectangle(cornerRadius: size * 0.15)
                .fill(Color.appBrownDark)
                .frame(width: size * 0.9, height: size * 1.15)
                .offset(x: 3, y: 3)

            // Book body (leather-bound look)
            RoundedRectangle(cornerRadius: size * 0.15)
                .fill(
                    LinearGradient(
                        colors: [Color.appBrown, Color.appBrownDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size * 1.2)

            // Book spine detail
            Rectangle()
                .fill(Color.appBrownDark.opacity(0.5))
                .frame(width: 4, height: size)
                .offset(x: -size * 0.4)

            // Gold decoration lines
            VStack(spacing: size * 0.15) {
                Rectangle()
                    .fill(Color.appYellow.opacity(0.6))
                    .frame(width: size * 0.5, height: 2)
                Rectangle()
                    .fill(Color.appYellow.opacity(0.6))
                    .frame(width: size * 0.3, height: 2)
            }
            .offset(y: -size * 0.4)

            // Face
            VStack(spacing: size * 0.05) {
                // Eyes
                HStack(spacing: size * 0.2) {
                    EyeView(size: size * 0.15, mood: mood)
                    EyeView(size: size * 0.15, mood: mood)
                }

                // Rosy cheeks
                HStack(spacing: size * 0.35) {
                    Circle()
                        .fill(Color.appPink.opacity(0.4))
                        .frame(width: size * 0.1, height: size * 0.08)
                    Circle()
                        .fill(Color.appPink.opacity(0.4))
                        .frame(width: size * 0.1, height: size * 0.08)
                }
                .offset(y: -size * 0.02)

                // Mouth
                MouthView(size: size * 0.25, mood: mood)
            }
            .offset(y: size * 0.1)

            // Bookmark ribbon
            Path { path in
                path.move(to: CGPoint(x: size * 0.3, y: -size * 0.6))
                path.addLine(to: CGPoint(x: size * 0.3, y: size * 0.7))
                path.addLine(to: CGPoint(x: size * 0.35, y: size * 0.6))
                path.addLine(to: CGPoint(x: size * 0.4, y: size * 0.7))
                path.addLine(to: CGPoint(x: size * 0.4, y: -size * 0.6))
            }
            .fill(Color.appRed)
        }
    }
}

struct EyeView: View {
    let size: CGFloat
    let mood: MascotView.MascotMood

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.appCream)
                .frame(width: size, height: size)

            Circle()
                .fill(Color.appBrownDark)
                .frame(width: size * 0.5, height: size * 0.5)
                .offset(y: mood == .thinking ? -2 : 0)

            // Eye sparkle
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.15, height: size * 0.15)
                .offset(x: -size * 0.1, y: -size * 0.1)
        }
    }
}

struct MouthView: View {
    let size: CGFloat
    let mood: MascotView.MascotMood

    var body: some View {
        switch mood {
        case .happy, .excited:
            // Smile
            Circle()
                .trim(from: 0.1, to: 0.4)
                .stroke(Color.appBrownDark, lineWidth: 3)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(180))
        case .thinking:
            // Neutral
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.appBrownDark)
                .frame(width: size * 0.5, height: 4)
        case .encouraging:
            // Big smile
            Circle()
                .trim(from: 0.05, to: 0.45)
                .stroke(Color.appBrownDark, lineWidth: 4)
                .frame(width: size * 1.2, height: size)
                .rotationEffect(.degrees(180))
        }
    }
}

// MARK: - XP Badge
struct XPBadge: View {
    let amount: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundStyle(Color.appYellow)
            Text("\(amount) XP")
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.appYellow.opacity(0.2)))
        .foregroundStyle(Color.appBrownDark)
    }
}

// MARK: - Streak Badge
struct StreakBadge: View {
    let days: Int
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 4) {
            Text("🔥")
                .font(.title3)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isAnimating)
            Text("\(days)")
                .font(.headline)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.appOrange.opacity(0.2)))
        .foregroundStyle(Color.appOrange)
        .onAppear { isAnimating = true }
    }
}

// MARK: - Hearts View
struct HeartsView: View {
    let hearts: Int
    let maxHearts: Int = 5

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<maxHearts, id: \.self) { index in
                Image(systemName: index < hearts ? "heart.fill" : "heart")
                    .foregroundStyle(index < hearts ? Color.appRed : Color.appTextSecondary)
                    .font(.caption)
            }
        }
    }
}

// MARK: - Progress Ring
struct ProgressRing: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6), value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Celebration View
struct CelebrationView: View {
    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let color: Color
        let emoji: String
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Text(particle.emoji)
                        .font(.title)
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onAppear {
                createParticles(in: geo.size)
            }
        }
        .allowsHitTesting(false)
    }

    private func createParticles(in size: CGSize) {
        let emojis = ["⭐️", "🎉", "✨", "🌟", "📖", "🙏", "💫", "🕊️"]
        for i in 0..<20 {
            let particle = Particle(
                x: CGFloat.random(in: 0...size.width),
                y: size.height + 50,
                color: [.appYellow, .appGreen, .appBlue, .appPurple].randomElement()!,
                emoji: emojis.randomElement()!
            )
            particles.append(particle)

            withAnimation(.easeOut(duration: 2).delay(Double(i) * 0.05)) {
                particles[i].y = CGFloat.random(in: -50...size.height * 0.3)
            }
        }
    }
}

// MARK: - Decorative Divider
struct RusticDivider: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Color.appBrownLight.opacity(0.3))
                .frame(height: 1)

            Image(systemName: "leaf.fill")
                .font(.caption2)
                .foregroundStyle(Color.appGreen.opacity(0.5))

            Rectangle()
                .fill(Color.appBrownLight.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.horizontal)
    }
}
