import SwiftUI

@MainActor
struct LoginView: View {
    @EnvironmentObject private var session: SessionStore
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        ZStack {
            ClubStyle.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    ClubMark().padding(.top, 26)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("BIENVENIDO AL CLUB").font(.caption.weight(.bold)).tracking(2).foregroundStyle(ClubStyle.accent)
                        Text("El béisbol,\nmás cerca de ti.").font(.system(size: 36, weight: .bold, design: .rounded))
                        Text("Inicia sesión y descubre los equipos de la MLB.")
                            .font(.subheadline).foregroundStyle(ClubStyle.muted)
                    }
                    VStack(spacing: 20) {
                        ClubField(title: "Correo electrónico", symbol: "envelope") {
                            TextField("tu@correo.com", text: $viewModel.email)
                                .keyboardType(.emailAddress).textContentType(.emailAddress)
                                .textInputAutocapitalization(.never).autocorrectionDisabled()
                                .accessibilityLabel("Correo electrónico")
                        }
                        ClubField(title: "Contraseña", symbol: "lock") {
                            SecureField("Tu contraseña", text: $viewModel.password)
                                .textContentType(.password).accessibilityLabel("Contraseña")
                        }
                        if let error = viewModel.errorMessage { FeedbackView(message: error) }
                        Button { viewModel.login(using: session) } label: {
                            HStack { Text("Entrar al club"); Image(systemName: "arrow.right") }
                        }
                        .buttonStyle(ClubButtonStyle()).disabled(!viewModel.canSubmit)
                        NavigationLink { RegisterView() } label: {
                            (Text("¿No tienes cuenta? ").foregroundColor(ClubStyle.muted) +
                             Text("Regístrate").bold().foregroundColor(ClubStyle.accent))
                                .font(.subheadline).padding(.vertical, 8)
                        }
                    }
                    Label("Primera visita: crea tu cuenta para comenzar.", systemImage: "info.circle")
                        .font(.footnote).foregroundStyle(ClubStyle.muted)
                    Text("MLB CLUB · EXPLORA EL DIAMANTE")
                        .font(.caption2.weight(.medium)).tracking(1).foregroundStyle(ClubStyle.muted)
                        .frame(maxWidth: .infinity).padding(.top, 12)
                }
                .padding(26).frame(maxWidth: 540).frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
