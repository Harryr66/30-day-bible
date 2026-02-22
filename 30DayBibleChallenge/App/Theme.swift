import SwiftUI

// MARK: - App Theme Colors (Vibrant Duolingo Style)
extension Color {
    // Primary brand colors - bright and fun!
    static let appGreen = Color(hex: "58CC02")           // Duolingo green
    static let appGreenDark = Color(hex: "46A302")       // Darker green
    static let appGreenLight = Color(hex: "7ED321")      // Light green

    // Accent colors - rainbow vibes
    static let appBlue = Color(hex: "1CB0F6")            // Bright blue
    static let appBlueDark = Color(hex: "1899D6")        // Dark blue
    static let appPurple = Color(hex: "CE82FF")          // Vibrant purple
    static let appPurpleDark = Color(hex: "A560E8")      // Dark purple
    static let appOrange = Color(hex: "FF9600")          // Bright orange
    static let appOrangeDark = Color(hex: "E58600")      // Dark orange
    static let appRed = Color(hex: "FF4B4B")             // Bright red
    static let appRedDark = Color(hex: "EA2B2B")         // Dark red
    static let appYellow = Color(hex: "FFC800")          // Bright yellow
    static let appYellowDark = Color(hex: "E5B400")      // Dark yellow
    static let appPink = Color(hex: "FF86D0")            // Fun pink
    static let appTeal = Color(hex: "2BD9D9")            // Teal/cyan

    // Background colors - clean and bright
    static let appBackground = Color(hex: "FFFFFF")       // Pure white
    static let appBackgroundSecondary = Color(hex: "F7F7F7") // Light gray
    static let appCardBackground = Color(hex: "FFFFFF")   // White cards
    static let appCardBackgroundLight = Color(hex: "F0F0F0")

    // Legacy compatibility
    static let appBrown = appGreen                        // Map to green
    static let appBrownDark = appGreenDark
    static let appBrownLight = appGreenLight
    static let appCream = Color(hex: "FFFDF7")
    static let appBeige = Color(hex: "F0F0F0")

    // Text colors
    static let appTextPrimary = Color(hex: "3C3C3C")     // Dark gray
    static let appTextSecondary = Color(hex: "AFAFAF")   // Medium gray

    // Accent
    static let appAccent = appGreen

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

    init(color: Color = .appGreen, textColor: Color = .white) {
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
                    // Shadow layer
                    RoundedRectangle(cornerRadius: 16)
                        .fill(darkerColor(for: color))
                        .offset(y: configuration.isPressed ? 0 : 4)
                    // Main button
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color)
                        .offset(y: configuration.isPressed ? 4 : 0)
                }
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }

    private func darkerColor(for color: Color) -> Color {
        if color == .appGreen { return .appGreenDark }
        if color == .appBlue { return .appBlueDark }
        if color == .appOrange { return .appOrangeDark }
        if color == .appPurple { return .appPurpleDark }
        if color == .appRed { return .appRedDark }
        return color.opacity(0.7)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(Color.appBlue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appBlue, lineWidth: 2)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
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
                    .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
    }
}

extension View {
    func playfulCard(color: Color = .appCardBackground) -> some View {
        modifier(PlayfulCard(color: color))
    }
}

// MARK: - Bounce Animation
struct BounceAnimation: ViewModifier {
    @State private var animate = false
    let delay: Double

    func body(content: Content) -> some View {
        content
            .offset(y: animate ? 0 : 30)
            .opacity(animate ? 1 : 0)
            .scaleEffect(animate ? 1 : 0.8)
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

// MARK: - Bible Mascot View (Happy/Sad based on streak)
struct MascotView: View {
    let mood: MascotMood
    let size: CGFloat

    @State private var isBopping = false
    @State private var eyesClosed = false

    enum MascotMood {
        case happy      // Has a streak
        case excited    // Long streak (7+ days)
        case sad        // No streak / streak lost
        case encouraging // First day / comeback
        case thinking   // Neutral
    }

    var body: some View {
        ZStack {
            // Book body
            bookBody

            // Face
            VStack(spacing: size * 0.03) {
                // Eyes
                HStack(spacing: size * 0.15) {
                    BibleEye(size: size * 0.18, mood: mood, isClosed: eyesClosed)
                    BibleEye(size: size * 0.18, mood: mood, isClosed: eyesClosed)
                }

                // Blush cheeks (when happy)
                if mood == .happy || mood == .excited {
                    HStack(spacing: size * 0.35) {
                        Circle()
                            .fill(Color.appPink.opacity(0.5))
                            .frame(width: size * 0.1, height: size * 0.08)
                        Circle()
                            .fill(Color.appPink.opacity(0.5))
                            .frame(width: size * 0.1, height: size * 0.08)
                    }
                    .offset(y: -size * 0.02)
                }

                // Mouth
                BibleMouth(size: size * 0.2, mood: mood)
            }
            .offset(y: size * 0.05)

            // Tears when sad
            if mood == .sad {
                HStack(spacing: size * 0.35) {
                    TearDrop(size: size * 0.08)
                        .offset(y: size * 0.02)
                    TearDrop(size: size * 0.08)
                        .offset(y: size * 0.02)
                }
                .offset(y: -size * 0.05)
            }

            // Sparkles when excited
            if mood == .excited {
                ForEach(0..<3) { i in
                    Image(systemName: "sparkle")
                        .font(.system(size: size * 0.12))
                        .foregroundStyle(Color.appYellow)
                        .offset(
                            x: CGFloat([-1, 1, 0][i]) * size * 0.5,
                            y: CGFloat([-0.4, -0.3, -0.55][i]) * size
                        )
                        .opacity(isBopping ? 1 : 0.5)
                }
            }

        }
        .offset(y: isBopping && (mood == .happy || mood == .excited) ? -3 : 0)
        .onAppear {
            startAnimations()
        }
    }

    private var bookBody: some View {
        ZStack {
            // Shadow
            RoundedRectangle(cornerRadius: size * 0.12)
                .fill(Color.appGreenDark)
                .frame(width: size * 0.85, height: size)
                .offset(y: 4)

            // Main book body
            RoundedRectangle(cornerRadius: size * 0.12)
                .fill(
                    LinearGradient(
                        colors: mood == .sad ? [Color.appBlue.opacity(0.7), Color.appBlueDark.opacity(0.7)] : [Color.appGreen, Color.appGreenDark],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.85, height: size)

            // Book spine highlight
            RoundedRectangle(cornerRadius: size * 0.12)
                .fill(Color.white.opacity(0.2))
                .frame(width: size * 0.85, height: size)
                .mask(
                    HStack {
                        Rectangle().frame(width: size * 0.1)
                        Spacer()
                    }
                )

            // Page edges (right side)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.9))
                .frame(width: size * 0.05, height: size * 0.7)
                .offset(x: size * 0.38)

            // Cross emblem
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.appYellow)
                    .frame(width: size * 0.06, height: size * 0.18)
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.appYellow)
                    .frame(width: size * 0.15, height: size * 0.06)
                    .offset(y: -size * 0.06)
            }
            .offset(y: -size * 0.32)
        }
    }

    private func startAnimations() {
        // Bopping animation for happy moods
        if mood == .happy || mood == .excited {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                isBopping = true
            }
        }

        // Blinking animation
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                eyesClosed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    eyesClosed = false
                }
            }
        }
    }
}

struct BibleEye: View {
    let size: CGFloat
    let mood: MascotView.MascotMood
    let isClosed: Bool

    var body: some View {
        ZStack {
            // Eye white
            Ellipse()
                .fill(Color.white)
                .frame(width: size, height: isClosed ? size * 0.1 : size * 0.9)

            if !isClosed {
                // Pupil
                Circle()
                    .fill(Color(hex: "3C3C3C"))
                    .frame(width: size * 0.5, height: size * 0.5)
                    .offset(y: mood == .sad ? 2 : 0)

                // Eye shine
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.18, height: size * 0.18)
                    .offset(x: -size * 0.1, y: -size * 0.1)

                // Worried eyebrows when sad
                if mood == .sad {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "3C3C3C"))
                        .frame(width: size * 0.6, height: 3)
                        .rotationEffect(.degrees(-15))
                        .offset(y: -size * 0.5)
                }
            }
        }
    }
}

struct BibleMouth: View {
    let size: CGFloat
    let mood: MascotView.MascotMood

    var body: some View {
        switch mood {
        case .happy:
            // Happy smile
            HappyMouth(size: size)
        case .excited:
            // Big open smile
            ExcitedMouth(size: size)
        case .sad:
            // Frown
            SadMouth(size: size)
        case .encouraging:
            // Gentle smile
            HappyMouth(size: size * 0.8)
        case .thinking:
            // Neutral line
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "3C3C3C"))
                .frame(width: size * 0.5, height: 3)
        }
    }
}

struct HappyMouth: View {
    let size: CGFloat

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: size, y: 0),
                control: CGPoint(x: size/2, y: size * 0.7)
            )
        }
        .stroke(Color(hex: "3C3C3C"), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        .frame(width: size, height: size * 0.5)
    }
}

struct ExcitedMouth: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Open mouth
            Ellipse()
                .fill(Color(hex: "3C3C3C"))
                .frame(width: size, height: size * 0.7)

            // Tongue
            Ellipse()
                .fill(Color.appPink)
                .frame(width: size * 0.5, height: size * 0.3)
                .offset(y: size * 0.15)
        }
    }
}

struct SadMouth: View {
    let size: CGFloat

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: size * 0.3))
            path.addQuadCurve(
                to: CGPoint(x: size, y: size * 0.3),
                control: CGPoint(x: size/2, y: -size * 0.2)
            )
        }
        .stroke(Color(hex: "3C3C3C"), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        .frame(width: size, height: size * 0.5)
    }
}

struct TearDrop: View {
    let size: CGFloat
    @State private var falling = false

    var body: some View {
        Ellipse()
            .fill(Color.appBlue.opacity(0.6))
            .frame(width: size * 0.5, height: size)
            .offset(y: falling ? size * 2 : 0)
            .opacity(falling ? 0 : 1)
            .onAppear {
                withAnimation(.easeIn(duration: 1.5).repeatForever(autoreverses: false)) {
                    falling = true
                }
            }
    }
}

// MARK: - XP Badge
struct XPBadge: View {
    let amount: Int
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundStyle(Color.appYellow)
                .scaleEffect(isPulsing ? 1.1 : 1.0)
            Text("\(amount)")
                .font(.subheadline)
                .fontWeight(.black)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.appYellow.opacity(0.15))
        )
        .foregroundStyle(Color.appOrange)
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
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
            Text("\(days)")
                .font(.headline)
                .fontWeight(.black)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.appOrange.opacity(0.2), Color.appRed.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
        .foregroundStyle(Color.appOrange)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
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
                    .foregroundStyle(index < hearts ? Color.appRed : Color.appTextSecondary.opacity(0.3))
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
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
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
        let emoji: String
        var rotation: Double
        var scale: Double
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Text(particle.emoji)
                        .font(.largeTitle)
                        .scaleEffect(particle.scale)
                        .rotationEffect(.degrees(particle.rotation))
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
        let emojis = ["⭐️", "🎉", "✨", "🌟", "🎊", "💫", "🥳", "🏆"]
        for i in 0..<25 {
            let particle = Particle(
                x: CGFloat.random(in: 0...size.width),
                y: size.height + 100,
                emoji: emojis.randomElement()!,
                rotation: Double.random(in: 0...360),
                scale: Double.random(in: 0.5...1.2)
            )
            particles.append(particle)

            let index = i
            withAnimation(.interpolatingSpring(stiffness: 50, damping: 8).delay(Double(i) * 0.03)) {
                particles[index].y = CGFloat.random(in: -100...size.height * 0.5)
                particles[index].rotation = Double.random(in: -30...30)
            }
        }
    }
}

// MARK: - Decorative Divider
struct RusticDivider: View {
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.appGreen.opacity(0.3))
                .frame(height: 2)

            Circle()
                .fill(Color.appGreen)
                .frame(width: 8, height: 8)

            Rectangle()
                .fill(Color.appGreen.opacity(0.3))
                .frame(height: 2)
        }
        .padding(.horizontal)
    }
}

// MARK: - Wiggle Animation
extension View {
    func wiggle(_ isWiggling: Bool) -> some View {
        self.rotationEffect(.degrees(isWiggling ? 2 : -2))
            .animation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true), value: isWiggling)
    }
}
