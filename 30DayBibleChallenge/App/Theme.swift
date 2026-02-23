import SwiftUI

// MARK: - App Theme Colors (Warm Duolingo Style)
extension Color {
    // Primary brand colors - warm brown
    static let appBrown = Color(hex: "8B6914")           // Warm golden brown
    static let appBrownDark = Color(hex: "6B5010")       // Darker brown
    static let appBrownLight = Color(hex: "C4A574")      // Light tan

    // Success green
    static let appGreen = Color(hex: "58CC02")           // Success green
    static let appGreenDark = Color(hex: "46A302")       // Darker green
    static let appGreenLight = Color(hex: "7ED321")      // Light green

    // CTA Blue (Duolingo style)
    static let appBlue = Color(hex: "1CB0F6")            // Bright cyan blue
    static let appBlueDark = Color(hex: "1899D6")        // Dark cyan blue

    // Accent colors
    static let appPurple = Color(hex: "CE82FF")          // Vibrant purple
    static let appPurpleDark = Color(hex: "A560E8")      // Dark purple
    static let appOrange = Color(hex: "FF9600")          // Bright orange
    static let appOrangeDark = Color(hex: "E58600")      // Dark orange
    static let appRed = Color(hex: "FF6B6B")             // Soft red
    static let appRedDark = Color(hex: "EA4B4B")         // Dark red
    static let appYellow = Color(hex: "FFC800")          // Bright yellow
    static let appYellowDark = Color(hex: "E5B400")      // Dark yellow
    static let appPink = Color(hex: "FFB5C5")            // Soft pink
    static let appTeal = Color(hex: "2BD9D9")            // Teal/cyan

    // Background colors - warm cream (like competitor)
    static let appBackground = Color(hex: "FFF8E7")       // Warm cream
    static let appBackgroundSecondary = Color(hex: "FFF5E0") // Slightly darker cream
    static let appCardBackground = Color(hex: "FFFDF5")   // Soft cream cards
    static let appCardBackgroundLight = Color(hex: "FFF8E7")

    // Warm tones
    static let appCream = Color(hex: "FFF8E7")
    static let appBeige = Color(hex: "FFE8C8")

    // Text colors
    static let appTextPrimary = Color(hex: "5C4813")     // Warm dark brown text
    static let appTextSecondary = Color(hex: "A89060")   // Medium brown text

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

    init(color: Color = .appBlue, textColor: Color = .white) {
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
        if color == .appBlue { return .appBlueDark }
        if color == .appBrown { return .appBrownDark }
        if color == .appOrange { return .appOrangeDark }
        if color == .appPurple { return .appPurpleDark }
        if color == .appRed { return .appRedDark }
        if color == .appGreen { return .appGreenDark }
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

// MARK: - Dove Mascot View (Happy/Sad based on streak)
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
            // Dove body
            doveBody

            // Face elements
            VStack(spacing: size * 0.02) {
                // Eyes
                HStack(spacing: size * 0.12) {
                    DoveEye(size: size * 0.22, mood: mood, isClosed: eyesClosed, isLeft: true)
                    DoveEye(size: size * 0.22, mood: mood, isClosed: eyesClosed, isLeft: false)
                }

                // Beak
                DoveBeak(size: size * 0.18, mood: mood)
                    .offset(y: -size * 0.02)
            }
            .offset(y: size * 0.02)

            // Blush cheeks
            if mood == .happy || mood == .excited || mood == .encouraging {
                HStack(spacing: size * 0.42) {
                    Circle()
                        .fill(Color(hex: "FFB3B8").opacity(0.65))
                        .frame(width: size * 0.09, height: size * 0.09)
                    Circle()
                        .fill(Color(hex: "FFB3B8").opacity(0.65))
                        .frame(width: size * 0.09, height: size * 0.09)
                }
                .offset(y: size * 0.08)
            }

            // Tears when sad
            if mood == .sad {
                HStack(spacing: size * 0.35) {
                    TearDrop(size: size * 0.08)
                    TearDrop(size: size * 0.08)
                }
                .offset(y: -size * 0.02)
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

    private var doveBody: some View {
        ZStack {
            // Glow effect behind mascot
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.appYellow.opacity(0.3), Color.appYellow.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)

            // Shadow
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(Color.gray.opacity(0.2))
                .frame(width: size * 0.9, height: size)
                .offset(y: 4)

            // Main dove body - white/cream
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(
                    LinearGradient(
                        colors: mood == .sad ? [Color(hex: "F0F0F5"), Color(hex: "E5E5EE")] : [Color(hex: "FDFCFA"), Color(hex: "F5F3EE")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.9, height: size)

            // Wing shadows on sides
            HStack {
                // Left wing hint
                WingFeathers(size: size, isLeft: true)
                Spacer()
                // Right wing hint
                WingFeathers(size: size, isLeft: false)
            }
            .frame(width: size * 0.95)

            // Head tuft
            HeadTuft(size: size)
                .offset(y: -size * 0.48)
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

// MARK: - Dove Eye (Pill-shaped like Duolingo)
struct DoveEye: View {
    let size: CGFloat
    let mood: MascotView.MascotMood
    let isClosed: Bool
    let isLeft: Bool

    var body: some View {
        ZStack {
            // Eye white - pill shaped
            RoundedRectangle(cornerRadius: size * 0.5)
                .fill(Color.white)
                .frame(width: size, height: isClosed ? size * 0.15 : size * 1.4)
                .shadow(color: Color.gray.opacity(0.3), radius: 4, y: 2)
                .rotationEffect(.degrees(isLeft ? 5 : -5))

            if !isClosed {
                // Pupil - pill shaped, grey
                RoundedRectangle(cornerRadius: size * 0.25)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "5A5858"), Color(hex: "2E2D2D")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.52, height: size * 0.8)
                    .offset(x: size * 0.12, y: mood == .sad ? size * 0.1 : -size * 0.05)
                    .rotationEffect(.degrees(isLeft ? 5 : -5))

                // Eye shine
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.22, height: size * 0.22)
                    .offset(x: size * 0.15, y: -size * 0.2)
                    .rotationEffect(.degrees(isLeft ? 5 : -5))

                // Worried eyebrows when sad
                if mood == .sad {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "5A5858"))
                        .frame(width: size * 0.7, height: 3)
                        .rotationEffect(.degrees(isLeft ? -12 : 12))
                        .offset(y: -size * 0.75)
                }
            }
        }
    }
}

// MARK: - Dove Beak
struct DoveBeak: View {
    let size: CGFloat
    let mood: MascotView.MascotMood

    var body: some View {
        ZStack {
            // Beak shape
            BeakShape()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "FFAD36"), Color(hex: "F2720C")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 1.0, height: size * 1.1)
                .shadow(color: Color.orange.opacity(0.3), radius: 3, y: 2)

            // Beak highlight
            Ellipse()
                .fill(Color(hex: "FFD980").opacity(0.6))
                .frame(width: size * 0.35, height: size * 0.2)
                .offset(x: -size * 0.1, y: -size * 0.25)
        }
    }
}

struct BeakShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.15, y: h * 0.15))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.5, y: h * 0.95),
            control: CGPoint(x: w * 0.1, y: h * 0.6)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.85, y: h * 0.15),
            control: CGPoint(x: w * 0.9, y: h * 0.6)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.15, y: h * 0.15),
            control: CGPoint(x: w * 0.5, y: 0)
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - Wing Feathers
struct WingFeathers: View {
    let size: CGFloat
    let isLeft: Bool

    var body: some View {
        VStack(spacing: size * 0.08) {
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "C8C6C0"))
                    .frame(width: size * 0.12 - CGFloat(i) * size * 0.02, height: 2)
                    .rotationEffect(.degrees(isLeft ? 25 : -25))
            }
        }
        .offset(x: isLeft ? -size * 0.35 : size * 0.35, y: size * 0.1)
    }
}

// MARK: - Head Tuft
struct HeadTuft: View {
    let size: CGFloat

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: size * 0.4, y: size * 0.1))
            path.addQuadCurve(
                to: CGPoint(x: size * 0.5, y: 0),
                control: CGPoint(x: size * 0.42, y: size * 0.03)
            )
            path.addQuadCurve(
                to: CGPoint(x: size * 0.6, y: size * 0.1),
                control: CGPoint(x: size * 0.58, y: size * 0.03)
            )
        }
        .fill(Color(hex: "E5E3DE"))
        .frame(width: size, height: size * 0.15)
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
                .fill(Color.appBrown.opacity(0.3))
                .frame(height: 2)

            Circle()
                .fill(Color.appBrown)
                .frame(width: 8, height: 8)

            Rectangle()
                .fill(Color.appBrown.opacity(0.3))
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

// MARK: - Dove in Nest Scene
struct DoveNestScene: View {
    let mood: MascotView.MascotMood
    @State private var cloudOffset1: CGFloat = 0
    @State private var cloudOffset2: CGFloat = 0
    @State private var doveOffset: CGFloat = 0
    @State private var eyesClosed = false
    @State private var isBopping = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Sky background gradient
                LinearGradient(
                    colors: [
                        Color(hex: "87CEEB"),  // Light sky blue
                        Color(hex: "B8E0F0"),  // Lighter blue
                        Color(hex: "F0E6D3")   // Warm horizon
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Sun glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "FFF8DC").opacity(0.8),
                                Color(hex: "FFE4B5").opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geo.size.width * 0.4
                        )
                    )
                    .frame(width: geo.size.width * 0.8, height: geo.size.width * 0.8)
                    .offset(x: geo.size.width * 0.3, y: -geo.size.height * 0.15)

                // Clouds
                CloudShape()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 80, height: 35)
                    .offset(x: -geo.size.width * 0.25 + cloudOffset1, y: -geo.size.height * 0.3)

                CloudShape()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 60, height: 28)
                    .offset(x: geo.size.width * 0.2 + cloudOffset2, y: -geo.size.height * 0.25)

                CloudShape()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 50, height: 22)
                    .offset(x: geo.size.width * 0.05 + cloudOffset1 * 0.5, y: -geo.size.height * 0.35)

                // Nest
                NestView(width: geo.size.width * 0.55)
                    .offset(y: geo.size.height * 0.22)

                // Dove sitting in nest
                DoveInNest(mood: mood, size: geo.size.width * 0.35, eyesClosed: eyesClosed)
                    .offset(y: geo.size.height * 0.08 + doveOffset)

                // Sparkles when excited
                if mood == .excited {
                    ForEach(0..<5) { i in
                        Image(systemName: "sparkle")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appYellow)
                            .offset(
                                x: CGFloat([-50, 50, -30, 40, 0][i]),
                                y: CGFloat([-40, -35, -55, -50, -65][i]) + geo.size.height * 0.08
                            )
                            .opacity(isBopping ? 1 : 0.4)
                    }
                }
            }
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Cloud floating animation
        withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
            cloudOffset1 = 20
        }
        withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true).delay(1)) {
            cloudOffset2 = -15
        }

        // Dove gentle bob
        if mood == .happy || mood == .excited {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                doveOffset = -3
                isBopping = true
            }
        }

        // Blinking
        Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
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

// MARK: - Cloud Shape
struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.2, y: h * 0.8))
        path.addQuadCurve(to: CGPoint(x: w * 0.1, y: h * 0.5), control: CGPoint(x: 0, y: h * 0.7))
        path.addQuadCurve(to: CGPoint(x: w * 0.25, y: h * 0.2), control: CGPoint(x: w * 0.05, y: h * 0.2))
        path.addQuadCurve(to: CGPoint(x: w * 0.5, y: h * 0.1), control: CGPoint(x: w * 0.35, y: 0))
        path.addQuadCurve(to: CGPoint(x: w * 0.75, y: h * 0.2), control: CGPoint(x: w * 0.65, y: 0))
        path.addQuadCurve(to: CGPoint(x: w * 0.9, y: h * 0.5), control: CGPoint(x: w * 0.95, y: h * 0.2))
        path.addQuadCurve(to: CGPoint(x: w * 0.8, y: h * 0.8), control: CGPoint(x: w, y: h * 0.7))
        path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.8))
        path.closeSubpath()

        return path
    }
}

// MARK: - Tree Branch
struct TreeBranch: View {
    let isLeft: Bool

    var body: some View {
        ZStack {
            // Main branch
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "8B6914"))
                .frame(width: 60, height: 8)
                .rotationEffect(.degrees(isLeft ? -20 : 20))

            // Small branches
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "8B6914"))
                .frame(width: 25, height: 5)
                .rotationEffect(.degrees(isLeft ? 30 : -30))
                .offset(x: isLeft ? 15 : -15, y: -12)

            // Leaves
            ForEach(0..<3) { i in
                Ellipse()
                    .fill(Color(hex: "4A7C23").opacity(0.8))
                    .frame(width: 18, height: 10)
                    .rotationEffect(.degrees(Double(i * 30 - 30)))
                    .offset(
                        x: isLeft ? CGFloat(20 + i * 8) : CGFloat(-20 - i * 8),
                        y: CGFloat(-15 + i * 5)
                    )
            }
        }
    }
}

// MARK: - Nest View
struct NestView: View {
    let width: CGFloat

    var body: some View {
        ZStack {
            // Nest base
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "8B6914"), Color(hex: "6B4F0A")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width, height: width * 0.35)

            // Nest texture - twigs
            ForEach(0..<8) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "A07818").opacity(0.7))
                    .frame(width: width * 0.4, height: 4)
                    .rotationEffect(.degrees(Double(i * 25 - 90)))
                    .offset(y: -width * 0.05)
            }

            // Inner nest hollow
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "5A4010"), Color(hex: "7A5A14")],
                        center: .center,
                        startRadius: 0,
                        endRadius: width * 0.3
                    )
                )
                .frame(width: width * 0.7, height: width * 0.22)
                .offset(y: -width * 0.04)

            // Front rim of nest
            Ellipse()
                .stroke(Color(hex: "9A6A12"), lineWidth: 6)
                .frame(width: width * 0.85, height: width * 0.25)
                .offset(y: width * 0.02)
        }
    }
}

// MARK: - Dove In Nest (simplified version for scene)
struct DoveInNest: View {
    let mood: MascotView.MascotMood
    let size: CGFloat
    let eyesClosed: Bool

    var body: some View {
        ZStack {
            // Dove body - rounded white shape
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "FDFCFA"), Color(hex: "F0EDE6")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size, height: size * 0.85)
                .shadow(color: Color.gray.opacity(0.2), radius: 4, y: 2)

            // Wing hints
            Ellipse()
                .fill(Color(hex: "E8E6E0"))
                .frame(width: size * 0.3, height: size * 0.5)
                .rotationEffect(.degrees(-20))
                .offset(x: -size * 0.32, y: size * 0.05)

            Ellipse()
                .fill(Color(hex: "E8E6E0"))
                .frame(width: size * 0.3, height: size * 0.5)
                .rotationEffect(.degrees(20))
                .offset(x: size * 0.32, y: size * 0.05)

            // Face
            VStack(spacing: size * 0.02) {
                // Eyes
                HStack(spacing: size * 0.15) {
                    DoveNestEye(size: size * 0.18, isClosed: eyesClosed, isLeft: true, mood: mood)
                    DoveNestEye(size: size * 0.18, isClosed: eyesClosed, isLeft: false, mood: mood)
                }

                // Beak
                BeakShape()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FFAD36"), Color(hex: "F2720C")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.18, height: size * 0.2)
                    .offset(y: -size * 0.02)
            }
            .offset(y: -size * 0.08)

            // Blush cheeks
            if mood == .happy || mood == .excited {
                HStack(spacing: size * 0.32) {
                    Circle()
                        .fill(Color(hex: "FFB3B8").opacity(0.5))
                        .frame(width: size * 0.08, height: size * 0.08)
                    Circle()
                        .fill(Color(hex: "FFB3B8").opacity(0.5))
                        .frame(width: size * 0.08, height: size * 0.08)
                }
                .offset(y: -size * 0.02)
            }

            // Head tuft - prominent feathers
            ZStack {
                // Center feather (tallest)
                Ellipse()
                    .fill(Color(hex: "F5F3EE"))
                    .frame(width: size * 0.08, height: size * 0.18)
                    .offset(y: -size * 0.48)

                // Left feather
                Ellipse()
                    .fill(Color(hex: "EAE8E2"))
                    .frame(width: size * 0.07, height: size * 0.14)
                    .rotationEffect(.degrees(-20))
                    .offset(x: -size * 0.06, y: -size * 0.44)

                // Right feather
                Ellipse()
                    .fill(Color(hex: "EAE8E2"))
                    .frame(width: size * 0.07, height: size * 0.14)
                    .rotationEffect(.degrees(20))
                    .offset(x: size * 0.06, y: -size * 0.44)
            }
        }
    }
}

struct DoveNestEye: View {
    let size: CGFloat
    let isClosed: Bool
    let isLeft: Bool
    let mood: MascotView.MascotMood

    var body: some View {
        ZStack {
            // Eye white - pill shaped
            RoundedRectangle(cornerRadius: size * 0.5)
                .fill(Color.white)
                .frame(width: size, height: isClosed ? size * 0.12 : size * 1.3)
                .shadow(color: Color.gray.opacity(0.2), radius: 2, y: 1)
                .rotationEffect(.degrees(isLeft ? 5 : -5))

            if !isClosed {
                // Pupil
                RoundedRectangle(cornerRadius: size * 0.22)
                    .fill(Color(hex: "4A4848"))
                    .frame(width: size * 0.48, height: size * 0.7)
                    .offset(x: size * 0.1, y: mood == .sad ? size * 0.08 : -size * 0.04)
                    .rotationEffect(.degrees(isLeft ? 5 : -5))

                // Highlight
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.18, height: size * 0.18)
                    .offset(x: size * 0.12, y: -size * 0.15)
                    .rotationEffect(.degrees(isLeft ? 5 : -5))
            }
        }
    }
}
