import Foundation
import SwiftUI
import FirebaseAuth
import AuthenticationServices

/// Authentication state for the app
enum AuthState: Equatable {
    case unknown       // Initial state, checking auth
    case authenticated // User is signed in
    case unauthenticated // User is not signed in
}

/// User information for display
struct AuthUser: Equatable {
    let id: String
    let email: String?
    let displayName: String?
    let isAnonymous: Bool

    init(from firebaseUser: User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email
        self.displayName = firebaseUser.displayName
        self.isAnonymous = firebaseUser.isAnonymous
    }
}

/// ViewModel for managing authentication state and operations
@MainActor
class AuthViewModel: ObservableObject {
    @Published var authState: AuthState = .unknown
    @Published var currentUser: AuthUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        setupAuthStateListener()
    }

    deinit {
        if let handle = authStateHandle {
            AuthService.shared.removeAuthStateListener(handle)
        }
    }

    // MARK: - Auth State Listener

    private func setupAuthStateListener() {
        authStateHandle = AuthService.shared.addAuthStateListener { [weak self] user in
            Task { @MainActor in
                guard let self = self else { return }
                if let user = user {
                    self.currentUser = AuthUser(from: user)
                    self.authState = .authenticated
                } else {
                    self.currentUser = nil
                    self.authState = .unauthenticated
                }
            }
        }
    }

    // MARK: - Email Authentication

    /// Sign in with email and password
    func signIn(email: String, password: String) async {
        guard !email.isEmpty, !password.isEmpty else {
            showError(message: "Please enter email and password.")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let user = try await AuthService.shared.signInWithEmail(email: email, password: password)
            currentUser = AuthUser(from: user)
            authState = .authenticated
        } catch let error as AuthService.AuthError {
            showError(message: error.localizedDescription)
        } catch {
            showError(message: "An unexpected error occurred.")
        }

        isLoading = false
    }

    /// Create a new account with email and password
    func signUp(email: String, password: String, displayName: String? = nil) async {
        guard !email.isEmpty, !password.isEmpty else {
            showError(message: "Please enter email and password.")
            return
        }

        guard password.count >= 6 else {
            showError(message: "Password must be at least 6 characters.")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let user = try await AuthService.shared.signUp(email: email, password: password)

            // Update display name if provided
            if let displayName = displayName, !displayName.isEmpty {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                try? await changeRequest.commitChanges()
            }

            currentUser = AuthUser(from: user)
            authState = .authenticated
        } catch let error as AuthService.AuthError {
            showError(message: error.localizedDescription)
        } catch {
            showError(message: "An unexpected error occurred.")
        }

        isLoading = false
    }

    /// Send password reset email
    func sendPasswordReset(email: String) async {
        guard !email.isEmpty else {
            showError(message: "Please enter your email address.")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await AuthService.shared.sendPasswordReset(email: email)
            showError(message: "Password reset email sent! Check your inbox.")
        } catch let error as AuthService.AuthError {
            showError(message: error.localizedDescription)
        } catch {
            showError(message: "An unexpected error occurred.")
        }

        isLoading = false
    }

    // MARK: - Google Sign In

    /// Sign in with Google
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await AuthService.shared.signInWithGoogle()
            currentUser = AuthUser(from: user)
            authState = .authenticated
        } catch let error as AuthService.AuthError {
            // Don't show error if user cancelled
            if case .googleSignInFailed = error {
                // User cancelled, don't show error
            } else {
                showError(message: error.localizedDescription)
            }
        } catch {
            showError(message: "Google Sign In failed.")
        }

        isLoading = false
    }

    // MARK: - Sign in with Apple

    /// Prepare the Apple Sign In request
    func handleAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) async {
        let nonce = await AuthService.shared.generateNonce()
        request.requestedScopes = [.fullName, .email]
        request.nonce = await AuthService.shared.sha256(nonce)
    }

    /// Handle Sign in with Apple completion
    func handleAppleSignInCompletion(_ result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil

        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                showError(message: "Unable to fetch identity token.")
                isLoading = false
                return
            }

            let nonce = await AuthService.shared.generateNonce()

            do {
                let user = try await AuthService.shared.signInWithApple(
                    idTokenString: idTokenString,
                    nonce: nonce,
                    fullName: appleIDCredential.fullName
                )
                currentUser = AuthUser(from: user)
                authState = .authenticated
            } catch let error as AuthService.AuthError {
                showError(message: error.localizedDescription)
            } catch {
                showError(message: "Sign in with Apple failed.")
            }

        case .failure(let error):
            // Don't show error if user cancelled
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                showError(message: "Sign in with Apple failed.")
            }
        }

        isLoading = false
    }

    // MARK: - Account Management

    /// Sign out the current user
    func signOut() {
        Task {
            do {
                try await AuthService.shared.signOut()
                await MainActor.run {
                    currentUser = nil
                    authState = .unauthenticated
                }
            } catch {
                await MainActor.run {
                    showError(message: "Failed to sign out.")
                }
            }
        }
    }

    /// Delete the current user's account
    func deleteAccount() async {
        isLoading = true
        errorMessage = nil

        do {
            try await AuthService.shared.deleteAccount()
            currentUser = nil
            authState = .unauthenticated
        } catch let error as AuthService.AuthError {
            showError(message: error.localizedDescription)
        } catch {
            showError(message: "Failed to delete account.")
        }

        isLoading = false
    }

    // MARK: - Helpers

    private func showError(message: String) {
        errorMessage = message
        showError = true
    }

    func clearError() {
        errorMessage = nil
        showError = false
    }
}
