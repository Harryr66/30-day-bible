import SwiftUI
import SwiftData

struct ReadingPlanView: View {
    @Binding var selectedDay: Int?
    @Environment(\.modelContext) private var modelContext
    @Query private var progress: [UserProgress]
    @State private var navigateToDay: ReadingDay?

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
                VStack(spacing: 24) {
                    // Progress header
                    progressHeader
                        .bounceIn(delay: 0)

                    // Journey path
                    journeyPath
                        .bounceIn(delay: 0.1)
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Your Journey")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appTextPrimary)
                }
            }
            .navigationDestination(item: $navigateToDay) { day in
                DailyReadingView(day: day)
            }
        }
    }

    private var progressHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Progress")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appTextPrimary)

                    Text("\(userProgress.completedDays.count) of 30 days")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer()

                ZStack {
                    ProgressRing(
                        progress: Double(userProgress.completedDays.count) / 30.0,
                        size: 60,
                        lineWidth: 8,
                        color: .appBrown
                    )

                    Text("\(Int(Double(userProgress.completedDays.count) / 30.0 * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appBrown)
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.appCardBackgroundLight)
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.appBrown, .appBrownLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * Double(userProgress.completedDays.count) / 30.0, height: 12)
                }
            }
            .frame(height: 12)

            // Stats row
            HStack(spacing: 20) {
                StatPill(icon: "🔥", value: "\(userProgress.currentStreak)", label: "Streak")
                StatPill(icon: "⭐️", value: "\(userProgress.completedDays.count * 50)", label: "XP")
                StatPill(icon: "🏆", value: "\(userProgress.longestStreak)", label: "Best")
            }
        }
        .padding()
        .playfulCard()
    }

    private var journeyPath: some View {
        VStack(spacing: 0) {
            ForEach(Array(ReadingPlan.days.enumerated()), id: \.element.id) { index, day in
                JourneyNode(
                    day: day,
                    isCompleted: userProgress.isDayComplete(day.id),
                    isToday: day.id == ReadingPlan.today().id,
                    isLocked: !canAccessDay(day.id),
                    isLast: index == ReadingPlan.days.count - 1
                ) {
                    if canAccessDay(day.id) {
                        navigateToDay = day
                    }
                }
            }
        }
    }

    private func canAccessDay(_ dayId: Int) -> Bool {
        // Can access if it's day 1, or if the previous day is completed
        if dayId == 1 { return true }
        return userProgress.isDayComplete(dayId - 1) || userProgress.isDayComplete(dayId)
    }
}

struct StatPill: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Text(icon)
                .font(.caption)

            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)

                Text(label)
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.appCardBackgroundLight))
    }
}

struct JourneyNode: View {
    let day: ReadingDay
    let isCompleted: Bool
    let isToday: Bool
    let isLocked: Bool
    let isLast: Bool
    let action: () -> Void

    @State private var isPressed = false

    var nodeColor: Color {
        if isCompleted { return .appGreen }
        if isToday { return .appYellow }
        if isLocked { return .appCardBackgroundLight }
        return .appBlue
    }

    var body: some View {
        HStack(spacing: 16) {
            // Path line and node
            VStack(spacing: 0) {
                // Node
                Button(action: action) {
                    ZStack {
                        Circle()
                            .fill(nodeColor)
                            .frame(width: 50, height: 50)
                            .shadow(color: nodeColor.opacity(0.5), radius: isToday ? 10 : 0)

                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        } else if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                        } else {
                            Text("\(day.id)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
                .scaleEffect(isPressed ? 0.9 : 1)
                .disabled(isLocked)

                // Connecting line
                if !isLast {
                    Rectangle()
                        .fill(isCompleted ? Color.appGreen : Color.appCardBackgroundLight)
                        .frame(width: 4, height: 40)
                }
            }

            // Day info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Day \(day.id)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(isToday ? Color.appYellow : Color.appTextSecondary)

                    if isToday && !isCompleted {
                        Text("TODAY")
                            .font(.caption2)
                            .fontWeight(.black)
                            .foregroundStyle(Color.appBackground)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.appYellow))
                    }
                }

                Text(day.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(isLocked ? Color.appTextSecondary : Color.appTextPrimary)

                Text(day.reference)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(.vertical, 8)
            .opacity(isLocked ? 0.5 : 1)

            Spacer()

            // Chevron
            if !isLocked {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isLocked {
                action()
            }
        }
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

#Preview {
    ReadingPlanView(selectedDay: .constant(nil))
        .environmentObject(StoreViewModel())
}
