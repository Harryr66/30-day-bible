import SwiftUI
import SwiftData
import FirebaseCore
import GoogleSignIn

@main
struct BibleChallengeApp: App {
    let modelContainer: ModelContainer
    @StateObject private var storeViewModel = StoreViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showSplash = true

    init() {
        // Configure Firebase
        FirebaseApp.configure()

        do {
            let schema = Schema([
                UserProgress.self,
                GameScore.self,
                VerseMastery.self
            ])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Show auth or main content based on auth state
                Group {
                    switch authViewModel.authState {
                    case .unknown:
                        // Loading state while checking auth
                        loadingView

                    case .unauthenticated:
                        // Show authentication screen
                        AuthenticationView()
                            .environmentObject(authViewModel)
                            .transition(.opacity)

                    case .authenticated:
                        // Show main app content
                        ContentView()
                            .environmentObject(storeViewModel)
                            .environmentObject(authViewModel)
                            .transition(.opacity)
                            .onAppear {
                                syncProgressOnLogin()
                            }
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: authViewModel.authState)

                // Splash screen on top
                if showSplash {
                    SplashScreenView {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showSplash = false
                        }
                    }
                    .zIndex(1)
                }
            }
            .onOpenURL { url in
                print("[URL DEBUG] Received URL: \(url)")
                print("[URL DEBUG] Scheme: \(url.scheme ?? "none")")
                // Handle Google Sign In callback
                if url.scheme?.starts(with: "com.googleusercontent.apps") == true {
                    print("[URL DEBUG] Handling as Google Sign In callback")
                    let handled = GIDSignIn.sharedInstance.handle(url)
                    print("[URL DEBUG] Google handled: \(handled)")
                } else {
                    print("[URL DEBUG] Handling as deep link")
                    handleDeepLink(url)
                }
            }
        }
        .modelContainer(modelContainer)
    }

    private var loadingView: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color.appBrown)

                Text("Loading...")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }

    private func handleDeepLink(_ url: URL) {
        // Handle widget tap deep links
        // URL scheme: biblechallenge://day/1
        guard url.scheme == "biblechallenge" else { return }

        if url.host == "day", let dayString = url.pathComponents.last, let day = Int(dayString) {
            NotificationCenter.default.post(
                name: .openReadingDay,
                object: nil,
                userInfo: ["day": day]
            )
        }
    }

    private func syncProgressOnLogin() {
        // Sync progress from cloud when user logs in
        Task {
            do {
                if let cloudUser = try await CloudSyncService.shared.pullProgress() {
                    // Apply cloud data to local progress
                    await MainActor.run {
                        let context = modelContainer.mainContext
                        let descriptor = FetchDescriptor<UserProgress>()
                        if let localProgress = try? context.fetch(descriptor).first {
                            cloudUser.applyTo(localProgress)
                            try? context.save()
                        }
                    }
                }
            } catch {
                print("Failed to sync progress: \(error)")
            }
        }
    }
}

extension Notification.Name {
    static let openReadingDay = Notification.Name("openReadingDay")
}
