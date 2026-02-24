import SwiftUI

/// Paywall shown when a free user reaches their session limit
struct SessionLimitPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeViewModel: StoreViewModel
    @ObservedObject var sessionManager: SessionManager
    @State private var showFullPaywall = false

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Sad mascot
                MascotView(mood: .sad, size: 100)

                // Message
                VStack(spacing: 12) {
                    Text("You've Used All Sessions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text("Free users get \(UserProgress.freeSessionLimit) lesson sessions per day")
                        .font(.subheadline)
                        .foregroundStyle(Color.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                // Timer display
                if let timeRemaining = sessionManager.timeUntilNextSession, timeRemaining > 0 {
                    VStack(spacing: 8) {
                        Text("Next free session in:")
                            .font(.caption)
                            .foregroundStyle(Color.white.opacity(0.6))

                        Text(sessionManager.formattedTimeRemaining)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appYellow)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                    )
                }

                // Pro benefits card
                VStack(spacing: 16) {
                    Text("Go Pro for Unlimited Access")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appTextPrimary)

                    VStack(alignment: .leading, spacing: 12) {
                        ProBenefitRow(icon: "infinity", text: "Unlimited lesson sessions")
                        ProBenefitRow(icon: "gamecontroller.fill", text: "All games unlocked")
                        ProBenefitRow(icon: "star.fill", text: "Earn bonus XP")
                        ProBenefitRow(icon: "sparkles", text: "Ad-free experience")
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.appCardBackground)
                )
                .padding(.horizontal)

                // CTA Buttons
                VStack(spacing: 12) {
                    // Upgrade button
                    Button {
                        showFullPaywall = true
                    } label: {
                        HStack {
                            Text("Upgrade to Pro")
                                .fontWeight(.bold)
                            Image(systemName: "crown.fill")
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "CC5200"))
                                    .offset(y: 4)
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "FF6B00"), Color(hex: "E65C00")],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            }
                        )
                    }

                    // Wait button
                    Button {
                        dismiss()
                    } label: {
                        Text("Wait for Free Session")
                            .font(.subheadline)
                            .foregroundStyle(Color.white.opacity(0.7))
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 32)

                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showFullPaywall) {
            PaywallView()
        }
    }
}

/// Row showing a Pro benefit
private struct ProBenefitRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.appGreen)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            Image(systemName: "checkmark")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(Color.appGreen)
        }
    }
}

#Preview {
    SessionLimitPaywallView(sessionManager: SessionManager())
        .environmentObject(StoreViewModel())
}
