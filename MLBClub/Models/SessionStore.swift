import Foundation
import Combine

struct AppUser: Identifiable, Equatable {
    let id: UUID
    let name: String
    let email: String
}

enum AuthError: LocalizedError {
    case duplicateEmail
    case invalidCredentials
    var errorDescription: String? {
        switch self {
        case .duplicateEmail: return "Este correo ya está registrado. Inicia sesión con tu cuenta."
        case .invalidCredentials: return "El correo o la contraseña no son correctos."
        }
    }
}

enum Validation {
    static func normalizedEmail(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func isValidEmail(_ value: String) -> Bool {
        let email = normalizedEmail(value)
        let pattern = #"^[A-Za-z0-9_%+-]+(?:\.[A-Za-z0-9_%+-]+)*@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)*\.[A-Za-z]{2,63}$"#
        return email.count <= 254 && email.range(of: pattern, options: .regularExpression) != nil
    }

    static func passwordError(_ password: String) -> String? {
        guard password.count >= 6 else { return "La contraseña debe tener al menos 6 caracteres." }
        guard password.rangeOfCharacter(from: .uppercaseLetters) != nil else {
            return "Incluye al menos una letra mayúscula."
        }
        let special = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}:/?\\|<>~")
        guard password.rangeOfCharacter(from: special) != nil else {
            return "Incluye un carácter especial como !, @ o #. Los puntos, comas, punto y coma y tildes no cuentan."
        }
        return nil
    }
}

@MainActor
final class SessionStore: ObservableObject {
    private struct MemoryAccount {
        let user: AppUser
        let password: String
    }
    @Published private(set) var currentUser: AppUser?
    private var accounts: [MemoryAccount] = []

    func contains(email: String) -> Bool {
        accounts.contains { $0.user.email == Validation.normalizedEmail(email) }
    }

    // Solo memoria, tal como exige la evaluación. No se escribe en disco.
    func register(name: String, email: String, password: String) throws -> AppUser {
        guard !contains(email: email) else { throw AuthError.duplicateEmail }
        let user = AppUser(id: UUID(), name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                           email: Validation.normalizedEmail(email))
        accounts.append(MemoryAccount(user: user, password: password))
        return user
    }

    func activate(_ user: AppUser) { currentUser = user }

    func login(email: String, password: String) throws {
        guard let account = accounts.first(where: {
            $0.user.email == Validation.normalizedEmail(email) && $0.password == password
        }) else { throw AuthError.invalidCredentials }
        currentUser = account.user
    }

    // Se conserva el registro en memoria para poder volver a iniciar sesión.
    func logout() { currentUser = nil }
}
