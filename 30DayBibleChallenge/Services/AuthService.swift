import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import CryptoKit

/// Service for handling Firebase Authentication
/// Supports Email/Password, Google Sign In, and Sign in with Apple
actor AuthService {
    static let shared = AuthService()

    // Current nonce for Sign in with Apple (used for security)
    private var currentNonce: String?

    enum AuthError: Error, LocalizedError {
        case invalidCredentials
        case emailAlreadyInUse
        case weakPassword
        case userNotFound
        case networkError
        case googleSignInFailed
        case appleSignInFailed
        case tokenError
        case noRootViewController
        case unknown(Error)

        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return "Invalid email or password."
            case .emailAlreadyInUse:
                return "This email is already registered."
            case .weakPassword:
                return "Password must be at least 6 characters."
            case .userNotFound:
                return "No account found with this email."
            case .networkError:
                return "Network error. Please check your connection."
            case .googleSignInFailed:
                return "Google Sign In failed. Please try again."
            case .appleSignInFailed:
                return "Sign in with Apple failed. Please try again."
            case .tokenError:
                return "Authentication token error."
            case .noRootViewController:
                return "Unable to present sign in."
            case .unknown(let error):
                return error.localizedDescription
            }
        }
    }

    // MARK: - Email/Password Authentication

    /// Sign in with email and password
    func signInWithEmail(email: String, password: String) async throws -> User {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return result.user
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    /// Create a new account with email and password
    func signUp(email: String, password: String) async throws -> User {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return result.user
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    /// Send password reset email
    func sendPasswordReset(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Google Sign In

    /// Sign in with Google
    func signInWithGoogle() async throws -> User {
        print("[AUTH DEBUG] Starting Google Sign In...")

        // Use client ID from Info.plist (GIDClientID) since OAuth client is in different GCP project
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
            print("[AUTH DEBUG] ERROR: No GIDClientID found in Info.plist")
            throw AuthError.tokenError
        }
        print("[AUTH DEBUG] Client ID: \(clientID)")

        // Get root view controller on main thread
        let rootViewController: UIViewController = try await MainActor.run {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController else {
                print("[AUTH DEBUG] ERROR: No root view controller")
                throw AuthError.noRootViewController
            }
            print("[AUTH DEBUG] Got root view controller: \(type(of: rootVC))")
            return rootVC
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        print("[AUTH DEBUG] Configured GIDSignIn, presenting sign-in...")

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            print("[AUTH DEBUG] Google Sign In successful, user: \(result.user.profile?.email ?? "no email")")

            guard let idToken = result.user.idToken?.tokenString else {
                print("[AUTH DEBUG] ERROR: No ID token")
                throw AuthError.tokenError
            }
            print("[AUTH DEBUG] Got ID token, authenticating with Firebase...")

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )

            let authResult = try await Auth.auth().signIn(with: credential)
            print("[AUTH DEBUG] Firebase auth successful! User: \(authResult.user.uid)")
            return authResult.user
        } catch let error as GIDSignInError {
            print("[AUTH DEBUG] GIDSignInError: \(error.localizedDescription), code: \(error.code)")
            if error.code == .canceled {
                throw AuthError.googleSignInFailed
            }
            throw AuthError.unknown(error)
        } catch let error as NSError {
            print("[AUTH DEBUG] NSError: \(error.domain) - \(error.code) - \(error.localizedDescription)")
            throw self.mapFirebaseError(error)
        }
    }

    // MARK: - Sign in with Apple

    /// Generate a nonce for Sign in with Apple
    func generateNonce() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return nonce
    }

    /// Get SHA256 hash of a string for Sign in with Apple
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }

    /// Sign in with Apple using the authorization credential
    func signInWithApple(idTokenString: String, nonce: String, fullName: PersonNameComponents?) async throws -> User {
        guard let currentNonce = currentNonce else {
            throw AuthError.tokenError
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: currentNonce,
            fullName: fullName
        )

        do {
            let result = try await Auth.auth().signIn(with: credential)
            self.currentNonce = nil
            return result.user
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Account Management

    /// Sign out the current user
    func signOut() throws {
        // Sign out from Google
        GIDSignIn.sharedInstance.signOut()

        // Sign out from Firebase
        do {
            try Auth.auth().signOut()
        } catch {
            throw AuthError.unknown(error)
        }
    }

    /// Delete the current user's account
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }

        do {
            try await user.delete()
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    /// Get the current user
    var currentUser: User? {
        Auth.auth().currentUser
    }

    // MARK: - Auth State

    /// Listen to auth state changes
    nonisolated func addAuthStateListener(_ listener: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle {
        Auth.auth().addStateDidChangeListener { _, user in
            listener(user)
        }
    }

    /// Remove auth state listener
    nonisolated func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }

    // MARK: - Private Helpers

    private func mapFirebaseError(_ error: NSError) -> AuthError {
        guard let errorCode = AuthErrorCode(rawValue: error.code) else {
            return .unknown(error)
        }

        switch errorCode {
        case .invalidEmail, .wrongPassword, .invalidCredential:
            return .invalidCredentials
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .userNotFound:
            return .userNotFound
        case .networkError:
            return .networkError
        default:
            return .unknown(error)
        }
    }

    /// Generate a random nonce string for Sign in with Apple
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
}
