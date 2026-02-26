import SwiftUI
import AuthenticationServices

/// Main authentication screen with Google Sign In and email options
struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEmailAuth = false
    @State private var animateContent = false

    var body: some View {
        ZStack {
            // Background
            Color.appBackground
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    Spacer(minLength: 40)

                    // Logo and welcome section
                    welcomeSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)

                    // Mascot
                    mascotSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)

                    // Sign in buttons
                    authButtonsSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 40)

                    // Terms and privacy
                    termsSection
                        .opacity(animateContent ? 1 : 0)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }

            // Loading overlay
            if authViewModel.isLoading {
                loadingOverlay
            }
        }
        .sheet(isPresented: $showEmailAuth) {
            EmailAuthView()
                .environmentObject(authViewModel)
        }
        .alert("Oops!", isPresented: $authViewModel.showError) {
            Button("OK") {
                authViewModel.clearError()
            }
        } message: {
            Text(authViewModel.errorMessage ?? "An error occurred.")
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animateContent = true
            }
        }
    }

    // MARK: - Welcome Section

    private var welcomeSection: some View {
        VStack(spacing: 12) {
            Text("30 Day Bible Challenge")
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)

            Text("Build your daily Bible reading habit")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
        }
    }

    // MARK: - Mascot Section

    private var mascotSection: some View {
        VStack(spacing: 16) {
            DoveNestScene(mood: .encouraging)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color.black.opacity(0.1), radius: 12, y: 6)

            Text("Let's begin your journey!")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.appTextPrimary)
        }
    }

    // MARK: - Auth Buttons Section

    private var authButtonsSection: some View {
        VStack(spacing: 16) {
            // Sign in with Google button
            Button {
                Task {
                    await authViewModel.signInWithGoogle()
                }
            } label: {
                HStack(spacing: 12) {
                    GoogleLogoView()
                        .frame(width: 20, height: 20)

                    Text("Continue with Google")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.15), radius: 4, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            // Divider
            HStack {
                Rectangle()
                    .fill(Color.appTextSecondary.opacity(0.3))
                    .frame(height: 1)

                Text("or")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.horizontal, 16)

                Rectangle()
                    .fill(Color.appTextSecondary.opacity(0.3))
                    .frame(height: 1)
            }

            // Email sign in button
            Button {
                showEmailAuth = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "envelope.fill")
                        .font(.title3)

                    Text("Continue with Email")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appBlueDark)
                            .offset(y: 4)

                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appBlue)
                    }
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Terms Section

    private var termsSection: some View {
        VStack(spacing: 8) {
            Text("By continuing, you agree to our")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)

            HStack(spacing: 4) {
                Button("Terms of Service") {
                    if let url = URL(string: "https://harryr66.github.io/30-day-bible/terms.html") {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appBlue)

                Text("and")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)

                Button("Privacy Policy") {
                    if let url = URL(string: "https://harryr66.github.io/30-day-bible/privacy.html") {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appBlue)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)

                Text("Signing in...")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.appCardBackground)
            )
        }
    }
}

// MARK: - Google Logo View

struct GoogleLogoView: View {
    var body: some View {
        ZStack {
            // G letter styled like Google logo
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            Color(hex: "4285F4"), // Blue
                            Color(hex: "34A853"), // Green
                            Color(hex: "FBBC05"), // Yellow
                            Color(hex: "EA4335"), // Red
                            Color(hex: "4285F4")  // Blue again
                        ],
                        center: .center
                    ),
                    lineWidth: 3
                )

            // White background for the G opening
            Rectangle()
                .fill(Color.white)
                .frame(width: 12, height: 8)
                .offset(x: 4, y: 0)

            // Blue horizontal bar
            Rectangle()
                .fill(Color(hex: "4285F4"))
                .frame(width: 8, height: 3)
                .offset(x: 2, y: 0)
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthViewModel())
}
