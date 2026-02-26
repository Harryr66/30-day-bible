import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var doveOffset: CGFloat = 300
    @State private var doveScale: CGFloat = 0.5
    @State private var showFeathers = false
    @State private var feathers: [Feather] = []
    @State private var showTitle = false
    @State private var isComplete = false

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "87CEEB"),
                    Color(hex: "B8E0F0"),
                    Color(hex: "F5F0E6")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

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
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: 100, y: -200)

            // Feathers
            ForEach(feathers) { feather in
                FeatherView(feather: feather)
            }

            // Main dove
            VStack(spacing: 20) {
                ZStack {
                    // Glow behind dove
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 180, height: 180)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)

                    // Dove body
                    SplashDoveView()
                        .frame(width: 120, height: 120)
                }
                .offset(y: doveOffset)
                .scaleEffect(doveScale)

                // Title
                if showTitle {
                    VStack(spacing: 8) {
                        Text("Bible Challenge")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: "6B4423"))

                        Text("Daily Scripture")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(hex: "8B7355"))
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // Generate feathers
        feathers = (0..<20).map { _ in Feather() }

        // Dove pops up from bottom
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            doveOffset = 0
            doveScale = 1.0
            showFeathers = true
        }

        // Start floating animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAnimating = true
        }

        // Show title
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showTitle = true
            }
        }

        // Complete splash
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                isComplete = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onComplete()
            }
        }
    }
}

// MARK: - Feather
struct Feather: Identifiable {
    let id = UUID()
    let startX: CGFloat = CGFloat.random(in: -150...150)
    let startY: CGFloat = CGFloat.random(in: 0...100)
    let rotation: Double = Double.random(in: -180...180)
    let scale: CGFloat = CGFloat.random(in: 0.3...0.8)
    let delay: Double = Double.random(in: 0...0.3)
    let duration: Double = Double.random(in: 1.5...2.5)
    let endX: CGFloat = CGFloat.random(in: -200...200)
    let endY: CGFloat = CGFloat.random(in: -400 ... -200)
}

struct FeatherView: View {
    let feather: Feather
    @State private var animate = false

    var body: some View {
        Text("🪶")
            .font(.system(size: 24))
            .scaleEffect(feather.scale)
            .rotationEffect(.degrees(animate ? feather.rotation + 360 : feather.rotation))
            .offset(
                x: animate ? feather.endX : feather.startX,
                y: animate ? feather.endY : feather.startY
            )
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(
                    .easeOut(duration: feather.duration)
                    .delay(feather.delay)
                ) {
                    animate = true
                }
            }
    }
}

// MARK: - Splash Dove (Duolingo-style with head tuft)
struct SplashDoveView: View {
    @State private var isBopping = false
    let size: CGFloat = 120

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
                .shadow(color: Color.gray.opacity(0.3), radius: 8, y: 4)

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
                    // Left eye
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: size * 0.22, height: size * 0.22)
                        Circle()
                            .fill(Color.black)
                            .frame(width: size * 0.12, height: size * 0.12)
                        Circle()
                            .fill(Color.white)
                            .frame(width: size * 0.05, height: size * 0.05)
                            .offset(x: -size * 0.02, y: -size * 0.02)
                    }

                    // Right eye
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: size * 0.22, height: size * 0.22)
                        Circle()
                            .fill(Color.black)
                            .frame(width: size * 0.12, height: size * 0.12)
                        Circle()
                            .fill(Color.white)
                            .frame(width: size * 0.05, height: size * 0.05)
                            .offset(x: -size * 0.02, y: -size * 0.02)
                    }
                }

                // Beak
                SplashBeakShape()
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
            HStack(spacing: size * 0.32) {
                Circle()
                    .fill(Color(hex: "FFB3B8").opacity(0.5))
                    .frame(width: size * 0.1, height: size * 0.1)
                Circle()
                    .fill(Color(hex: "FFB3B8").opacity(0.5))
                    .frame(width: size * 0.1, height: size * 0.1)
            }
            .offset(y: -size * 0.02)

            // Head tuft - prominent feathers (the signature look!)
            ZStack {
                // Center feather (tallest)
                Ellipse()
                    .fill(Color(hex: "F5F3EE"))
                    .frame(width: size * 0.1, height: size * 0.22)
                    .offset(y: -size * 0.52)

                // Left feather
                Ellipse()
                    .fill(Color(hex: "EAE8E2"))
                    .frame(width: size * 0.08, height: size * 0.16)
                    .rotationEffect(.degrees(-25))
                    .offset(x: -size * 0.08, y: -size * 0.46)

                // Right feather
                Ellipse()
                    .fill(Color(hex: "EAE8E2"))
                    .frame(width: size * 0.08, height: size * 0.16)
                    .rotationEffect(.degrees(25))
                    .offset(x: size * 0.08, y: -size * 0.46)
            }
            .scaleEffect(isBopping ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isBopping)
        }
        .scaleEffect(isBopping ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isBopping)
        .onAppear {
            isBopping = true
        }
    }
}

// MARK: - Splash Beak Shape
struct SplashBeakShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.2),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.2))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    SplashScreenView(onComplete: {})
}
