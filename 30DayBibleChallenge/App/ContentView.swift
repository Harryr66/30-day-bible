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

                ReadingPlanView(selectedDay: $selectedDay)
                    .tag(1)

                GamesMenuView()
                    .tag(2)

                SettingsView()
                    .tag(3)
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
                color: .appOrange,
                isSelected: selectedTab == 0,
                bounce: bounceTab == 0
            ) {
                selectTab(0)
            }

            ColorfulTabButton(
                icon: "book.fill",
                label: "Plan",
                color: .appBrown,
                isSelected: selectedTab == 1,
                bounce: bounceTab == 1
            ) {
                selectTab(1)
            }

            ColorfulTabButton(
                icon: "gamecontroller.fill",
                label: "Games",
                color: .appPurple,
                isSelected: selectedTab == 2,
                bounce: bounceTab == 2
            ) {
                selectTab(2)
            }

            ColorfulTabButton(
                icon: "person.fill",
                label: "Profile",
                color: .appGreen,
                isSelected: selectedTab == 3,
                bounce: bounceTab == 3
            ) {
                selectTab(3)
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

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    // Background circle
                    Circle()
                        .fill(
                            isSelected
                                ? color.opacity(0.2)
                                : Color.clear
                        )
                        .frame(width: 48, height: 48)

                    // Icon with colored background pill
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: isSelected
                                        ? [color, color.opacity(0.8)]
                                        : [color.opacity(0.15), color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 42, height: 36)
                            .shadow(color: isSelected ? color.opacity(0.4) : Color.clear, radius: 4, y: 2)

                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(isSelected ? .white : color)
                    }
                    .scaleEffect(bounce ? 1.15 : 1.0)
                }

                Text(label)
                    .font(.caption2)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundStyle(isSelected ? color : Color.appTextSecondary)
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
            HStack(spacing: 16) {
                Text("👑")
                    .font(.largeTitle)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Go Premium!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appTextPrimary)

                    Text("Unlock all games & features")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.appYellow)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.appYellow.opacity(0.2), Color.appOrange.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.appYellow.opacity(0.5), lineWidth: 2)
            )
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
                // Open notifications
            }

            SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .appGreen) {
                // Open help
            }

            SettingsRow(icon: "doc.text.fill", title: "Privacy Policy", color: .appTextSecondary) {
                // Open privacy
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
