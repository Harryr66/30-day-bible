import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var selectedDay: Int?
    @EnvironmentObject var storeViewModel: StoreViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            TabView(selection: $selectedTab) {
                HomeView(selectedDay: $selectedDay)
                    .tag(0)

                LessonBrowserView()
                    .tag(1)

                ReadingPlanView(selectedDay: $selectedDay)
                    .tag(2)

                GamesMenuView()
                    .tag(3)

                SettingsView()
                    .tag(4)
            }

            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .onReceive(NotificationCenter.default.publisher(for: .openReadingDay)) { notification in
            if let day = notification.userInfo?["day"] as? Int {
                selectedDay = day
                selectedTab = 0
            }
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @State private var bounceTab: Int? = nil

    var body: some View {
        HStack(spacing: 0) {
            ColorfulTabButton(
                icon: "house.fill",
                label: "Home",
                color: .appBlue,
                isSelected: selectedTab == 0,
                bounce: bounceTab == 0
            ) {
                selectTab(0)
            }

            ColorfulTabButton(
                icon: "safari.fill",
                label: "Explore",
                color: .appTeal,
                isSelected: selectedTab == 1,
                bounce: bounceTab == 1
            ) {
                selectTab(1)
            }

            ColorfulTabButton(
                icon: "book.fill",
                label: "Plan",
                color: .appBrown,
                isSelected: selectedTab == 2,
                bounce: bounceTab == 2
            ) {
                selectTab(2)
            }

            ColorfulTabButton(
                icon: "gamecontroller.fill",
                label: "Games",
                color: .appOrange,
                isSelected: selectedTab == 3,
                bounce: bounceTab == 3
            ) {
                selectTab(3)
            }

            ColorfulTabButton(
                icon: "person.fill",
                label: "Profile",
                color: .appGreen,
                isSelected: selectedTab == 4,
                bounce: bounceTab == 4
            ) {
                selectTab(4)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            Color.appCardBackground
                .shadow(color: Color.black.opacity(0.1), radius: 15, y: -5)
        )
    }

    private func selectTab(_ index: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedTab = index
            bounceTab = index
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            bounceTab = nil
        }
    }
}

struct ColorfulTabButton: View {
    let icon: String
    let label: String
    let color: Color
    let isSelected: Bool
    let bounce: Bool
    let action: () -> Void

    private var darkerColor: Color {
        if color == .appBlue { return .appBlueDark }
        if color == .appOrange { return Color(hex: "D97800") }
        if color == .appBrown { return Color(hex: "5A4010") }
        if color == .appPurple { return Color(hex: "9050CC") }
        if color == .appGreen { return Color(hex: "3EA302") }
        return color.opacity(0.8)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                ZStack {
                    // 3D Icon button style
                    ZStack {
                        // Bottom shadow layer
                        RoundedRectangle(cornerRadius: 12)
                            .fill(darkerColor)
                            .frame(width: 44, height: 44)
                            .offset(y: 3)

                        // Main icon background
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.85)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 44, height: 44)

                        // Highlight at top
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.35), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                            .frame(width: 44, height: 44)

                        // Icon
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 1, y: 1)
                    }
                    .scaleEffect(bounce ? 1.1 : 1.0)
                }

                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

struct SettingsView: View {
    @EnvironmentObject var storeViewModel: StoreViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var progress: [UserProgress]
    @State private var showPaywall = false

    private var userProgress: UserProgress {
        if let existing = progress.first {
            return existing
        }
        let newProgress = UserProgress()
        modelContext.insert(newProgress)
        return newProgress
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Profile header
                    profileHeader
                        .bounceIn(delay: 0)

                    // Stats cards
                    statsCards
                        .bounceIn(delay: 0.1)

                    // Premium card
                    if !userProgress.isPremium {
                        premiumCard
                            .bounceIn(delay: 0.2)
                    }

                    // Settings list
                    settingsList
                        .bounceIn(delay: 0.3)
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appTextPrimary)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.appGreen, .appBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Text("👤")
                    .font(.system(size: 40))
            }

            VStack(spacing: 4) {
                Text("Bible Learner")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)

                HStack(spacing: 8) {
                    if userProgress.isPremium {
                        Text("⭐️ PREMIUM")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appYellow)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.appYellow.opacity(0.2)))
                    }

                    Text("Level \(max(1, userProgress.completedDays.count / 3))")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .playfulCard()
    }

    private var statsCards: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "🔥",
                value: "\(userProgress.currentStreak)",
                label: "Day Streak",
                color: .appOrange
            )

            StatCard(
                icon: "⭐️",
                value: "\(userProgress.completedDays.count * 50)",
                label: "Total XP",
                color: .appYellow
            )

            StatCard(
                icon: "📖",
                value: "\(userProgress.completedDays.count)",
                label: "Completed",
                color: .appGreen
            )
        }
    }

    private var premiumCard: some View {
        Button {
            showPaywall = true
        } label: {
            VStack(spacing: 0) {
                // Main content
                HStack(spacing: 16) {
                    // Crown icon with glow
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 40
                                )
                            )
                            .frame(width: 70, height: 70)

                        Text("👑")
                            .font(.system(size: 44))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Go Premium")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        Text("Unlimited sessions & all games")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))

                        HStack(spacing: 12) {
                            Text("$9.99/mo")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.85))

                            Text("•")
                                .foregroundStyle(.white.opacity(0.6))

                            Text("$49 lifetime")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.85))
                        }
                    }

                    Spacer()

                    // Arrow button
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40, height: 40)

                        Circle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 40, height: 40)
                            .offset(y: 3)
                            .zIndex(-1)

                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(hex: "E65C00"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .background(
                ZStack {
                    // Bold orange gradient
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FF6B00"),
                                    Color(hex: "E65C00"),
                                    Color(hex: "CC5200")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Subtle shine overlay
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color.white.opacity(0.0)
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color(hex: "E65C00").opacity(0.4), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }

    private var settingsList: some View {
        VStack(spacing: 2) {
            SettingsRow(icon: "arrow.clockwise", title: "Restore Purchases", color: .appBlue) {
                Task {
                    await storeViewModel.restorePurchases()
                }
            }

            SettingsRow(icon: "bell.fill", title: "Notifications", color: .appPurple) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }

            SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .appGreen) {
                if let url = URL(string: "mailto:support@biblechallenge.app") {
                    UIApplication.shared.open(url)
                }
            }

            SettingsRow(icon: "doc.text.fill", title: "Privacy Policy", color: .appTextSecondary) {
                if let url = URL(string: "https://example.com/privacy") {
                    UIApplication.shared.open(url)
                }
            }
        }
        .playfulCard()
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.title2)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)

            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .playfulCard()
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
                    .frame(width: 30)

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environmentObject(StoreViewModel())
}
