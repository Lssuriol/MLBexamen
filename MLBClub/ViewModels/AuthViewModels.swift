import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = "" { didSet { errorMessage = nil } }
    @Published var password = "" { didSet { errorMessage = nil } }
    @Published private(set) var errorMessage: String?

    var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !password.isEmpty
    }

    func login(using session: SessionStore) {
        guard canSubmit else { errorMessage = "Completa todos los campos."; return }
        guard Validation.isValidEmail(email) else { errorMessage = "Ingresa un correo electrónico válido."; return }
        if let error = Validation.passwordError(password) { errorMessage = error; return }
        do {
            try session.login(email: email, password: password)
            password = ""
        } catch { errorMessage = error.localizedDescription }
    }
}

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var name = "" { didSet { errorMessage = nil } }
    @Published var email = "" { didSet { errorMessage = nil } }
    @Published var password = "" { didSet { errorMessage = nil } }
    @Published var confirmation = "" { didSet { errorMessage = nil } }
    @Published private(set) var errorMessage: String?
    @Published private(set) var successMessage: String?
    @Published private(set) var isSubmitting = false

    var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty && !confirmation.isEmpty && !isSubmitting
    }

    func register(using session: SessionStore) async {
        guard !isSubmitting else { return }
        errorMessage = nil
        successMessage = nil
        guard canSubmit else { errorMessage = "Completa todos los campos."; return }
        guard Validation.isValidEmail(email) else { errorMessage = "Ingresa un correo electrónico válido."; return }
        if let error = Validation.passwordError(password) { errorMessage = error; return }
        guard password == confirmation else { errorMessage = "Las contraseñas no coinciden."; return }
        guard !session.contains(email: email) else { errorMessage = AuthError.duplicateEmail.localizedDescription; return }
        do {
            let user = try session.register(name: name, email: email, password: password)
            isSubmitting = true
            successMessage = "Cuenta creada. ¡Bienvenido al club!"
            // Permite ver el feedback antes de que RootView muestre el Home.
            try await Task.sleep(nanoseconds: 1_200_000_000)
            session.activate(user)
            password = ""
            confirmation = ""
        } catch is CancellationError {
            successMessage = nil
        } catch { errorMessage = error.localizedDescription }
        isSubmitting = false
    }
}
