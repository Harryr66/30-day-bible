import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeViewModel: StoreViewModel
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Features
                    featuresSection

                    // Products
                    productsSection

                    // Terms
                    termsSection
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [Color.appBeige, Color.appBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Go Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(Color.appBrown)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Restore Purchases") {
                        Task {
                            await storeViewModel.restorePurchases()
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(Color.appBrown)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .overlay {
                if isPurchasing {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color.appBrown)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Rustic crown/scroll icon
            ZStack {
                Circle()
                    .fill(Color.appYellow.opacity(0.2))
                    .frame(width: 100, height: 100)

                Text("👑")
                    .font(.system(size: 50))
            }

            Text("Unlock Your Full\nBible Journey")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)

            Text("Get access to all games, exercises,\nand premium content")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }

    private var featuresSection: some View {
        VStack(spacing: 16) {
            FeatureRow(icon: "♾️", title: "Unlimited Sessions", description: "No daily limits on lessons and practice", color: .appGreen)
            FeatureRow(icon: "🎮", title: "All Games Unlocked", description: "Quiz, Memory, Fill-in-Blank, and more", color: .appOrange)
            FeatureRow(icon: "🧠", title: "Memory Verses", description: "Master Scripture with flashcard memorization", color: .appPurple)
            FeatureRow(icon: "✍️", title: "Fill in the Blank", description: "Complete passages and learn deeply", color: .appBlue)
            FeatureRow(icon: "🔥", title: "Streak Tracking", description: "Stay motivated with detailed progress", color: .appRed)
            FeatureRow(icon: "✨", title: "Ad-Free Experience", description: "Focus on what matters most", color: .appYellow)
        }
        .padding()
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.appBrown.opacity(0.1), radius: 8, y: 4)
    }

    private var productsSection: some View {
        VStack(spacing: 12) {
            ForEach(storeViewModel.products) { product in
                ProductCard(
                    product: product,
                    isSelected: selectedProduct?.id == product.id,
                    isBestValue: product.id.contains("lifetime")
                ) {
                    selectedProduct = product
                }
            }

            if storeViewModel.products.isEmpty {
                VStack(spacing: 16) {
                    if storeViewModel.isLoading {
                        ProgressView()
                            .tint(Color.appBrown)
                        Text("Loading products...")
                            .foregroundStyle(Color.appTextSecondary)
                    } else {
                        // Fallback when products fail to load
                        VStack(spacing: 8) {
                            Text("Lifetime Access")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            Text("$9.99")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.appBrown)
                            Text("One-time purchase")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.appBeige)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appBrown, lineWidth: 2)
                        )

                        Button {
                            Task {
                                await storeViewModel.loadProducts()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Retry Loading")
                            }
                            .font(.subheadline)
                            .foregroundStyle(Color.appBrown)
                        }
                    }
                }
                .padding()
            }

            // Purchase button
            if let product = selectedProduct {
                Button {
                    purchase(product)
                } label: {
                    HStack {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Continue")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.appBrown, Color.appBrownDark],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color.appBrown.opacity(0.3), radius: 4, y: 2)
                }
                .disabled(isPurchasing)
                .padding(.top)
            }
        }
    }

    private var termsSection: some View {
        VStack(spacing: 8) {
            Text("Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period. Manage subscriptions in Settings.")
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

            HStack {
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                Text("•")
                    .foregroundStyle(Color.appTextSecondary)
                Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
            }
            .font(.caption)
            .foregroundStyle(Color.appBrown)
        }
        .padding()
    }

    private func purchase(_ product: Product) {
        isPurchasing = true
        Task {
            do {
                try await storeViewModel.purchase(product)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isPurchasing = false
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.title2)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appTextPrimary)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.appGreen)
        }
    }
}

struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let isBestValue: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(product.displayName)
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)

                        if isBestValue {
                            Text("BEST VALUE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.appGreen)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }

                    Text(product.description)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(product.displayPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appBrown)

                    if product.id.contains("monthly") {
                        Text("per month")
                            .font(.caption2)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
            .padding()
            .background(isSelected ? Color.appBeige : Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.appBrown : Color.appBrownLight.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaywallView()
        .environmentObject(StoreViewModel())
}
