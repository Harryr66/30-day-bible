import SwiftUI
import SwiftData

@main
struct BibleChallengeApp: App {
    let modelContainer: ModelContainer
    @StateObject private var storeViewModel = StoreViewModel()

    init() {
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
            ContentView()
                .environmentObject(storeViewModel)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        .modelContainer(modelContainer)
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
}

extension Notification.Name {
    static let openReadingDay = Notification.Name("openReadingDay")
}
