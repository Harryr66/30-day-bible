import SwiftUI

/// Email/password authentication view with login and signup modes
struct EmailAuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isSignUpMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var showForgotPassword = false
    @State private var forgotPasswordEmail = ""
    @State private var animateContent = false

    @FocusState private var focusedField: Field?

    enum Field {
        case email, password, confirmPassword, displayName
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Mode toggle
                        modeToggle
                            .bounceIn(delay: 0)

                        // Form fields
                        formFields
                            .bounceIn(delay: 0.1)

                        // Submit button
                        submitButton
                            .bounceIn(delay: 0.2)

                        // Forgot password (login mode only)
                        if !isSignUpMode {
                            forgotPasswordButton
                                .bounceIn(delay: 0.3)
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle(isSignUpMode ? "Create Account" : "Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.appBlue)
                }
            }
            .alert("Reset Password", isPresented: $showForgotPassword) {
                TextField("Email", text: $forgotPasswordEmail)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)

                Button("Send Reset Link") {
                    Task {
                        await authViewModel.sendPasswordReset(email: forgotPasswordEmail)
                    }
                }

                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter your email address and we'll send you a link to reset your password.")
            }
            .onChange(of: authViewModel.authState) { _, newState in
                if newState == .authenticated {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Mode Toggle

    private var modeToggle: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isSignUpMode = false
                }
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(!isSignUpMode ? .white : Color.appTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(!isSignUpMode ? Color.appBlue : Color.clear)
                    )
            }

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isSignUpMode = true
                }
            } label: {
                Text("Sign Up")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(isSignUpMode ? .white : Color.appTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSignUpMode ? Color.appBlue : Color.clear)
                    )
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appCardBackground)
        )
    }

    // MARK: - Form Fields

    private var formFields: some View {
        VStack(spacing: 16) {
            // Display name (signup only)
            if isSignUpMode {
                AuthTextField(
                    icon: "person.fill",
                    placeholder: "Display Name (optional)",
                    text: $displayName,
                    contentType: .name,
                    keyboardType: .default,
                    isSecure: false
                )
                .focused($focusedField, equals: .displayName)
            }

            // Email field
            AuthTextField(
                icon: "envelope.fill",
                placeholder: "Email",
                text: $email,
                contentType: .emailAddress,
                keyboardType: .emailAddress,
                isSecure: false
            )
            .focused($focusedField, equals: .email)
            .textInputAutocapitalization(.never)

            // Password field
            AuthTextField(
                icon: "lock.fill",
                placeholder: "Password",
                text: $password,
                contentType: isSignUpMode ? .newPassword : .password,
                keyboardType: .default,
                isSecure: true
            )
            .focused($focusedField, equals: .password)

            // Confirm password (signup only)
            if isSignUpMode {
                AuthTextField(
                    icon: "lock.fill",
                    placeholder: "Confirm Password",
                    text: $confirmPassword,
                    contentType: .newPassword,
                    keyboardType: .default,
                    isSecure: true
                )
                .focused($focusedField, equals: .confirmPassword)

                // Password requirements hint
                Text("Password must be at least 6 characters")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button {
            focusedField = nil
            Task {
                if isSignUpMode {
                    guard password == confirmPassword else {
                        authViewModel.errorMessage = "Passwords don't match."
                        authViewModel.showError = true
                        return
                    }
                    await authViewModel.signUp(
                        email: email,
                        password: password,
                        displayName: displayName.isEmpty ? nil : displayName
                    )
                } else {
                    await authViewModel.signIn(email: email, password: password)
                }
            }
        } label: {
            HStack {
                if authViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(isSignUpMode ? "Create Account" : "Sign In")
                        .font(.headline)
                        .fontWeight(.bold)
                }
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
                        .fill(isFormValid ? Color.appBlue : Color.appBlue.opacity(0.5))
                }
            )
        }
        .disabled(!isFormValid || authViewModel.isLoading)
    }

    // MARK: - Forgot Password Button

    private var forgotPasswordButton: some View {
        Button {
            forgotPasswordEmail = email
            showForgotPassword = true
        } label: {
            Text("Forgot password?")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appBlue)
        }
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        let emailValid = !email.isEmpty && email.contains("@")
        let passwordValid = password.count >= 6

        if isSignUpMode {
            return emailValid && passwordValid && password == confirmPassword
        } else {
            return emailValid && !password.isEmpty
        }
    }
}

// MARK: - Auth Text Field Component

struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let contentType: UITextContentType
    let keyboardType: UIKeyboardType
    let isSecure: Bool

    @State private var isPasswordVisible = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.appTextSecondary)
                .frame(width: 24)

            if isSecure && !isPasswordVisible {
                SecureField(placeholder, text: $text)
                    .textContentType(contentType)
            } else {
                TextField(placeholder, text: $text)
                    .textContentType(contentType)
                    .keyboardType(keyboardType)
            }

            if isSecure {
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .font(.body)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appCardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appTextSecondary.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    EmailAuthView()
        .environmentObject(AuthViewModel())
}
