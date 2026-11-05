import SwiftUI

@MainActor
struct RegisterView: View {
    @EnvironmentObject private var session: SessionStore
    @StateObject private var viewModel = RegisterViewModel()

    var body: some View {
        ZStack {
            ClubStyle.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ClubMark(size: 115)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("TU LUGAR EN LA TRIBUNA").font(.caption.weight(.bold)).tracking(2).foregroundStyle(ClubStyle.accent)
                        Text("Únete al club.").font(.system(size: 34, weight: .bold, design: .rounded))
                        Text("Crea tu cuenta y empieza a explorar.").font(.subheadline).foregroundStyle(ClubStyle.muted)
                    }
                    ClubField(title: "Nombre", symbol: "person") {
                        TextField("¿Cómo te llamas?", text: $viewModel.name)
                            .textContentType(.name).textInputAutocapitalization(.words).accessibilityLabel("Nombre")
                    }
                    ClubField(title: "Correo electrónico", symbol: "envelope") {
                        TextField("tu@correo.com", text: $viewModel.email)
                            .keyboardType(.emailAddress).textContentType(.emailAddress)
                            .textInputAutocapitalization(.never).autocorrectionDisabled().accessibilityLabel("Correo electrónico")
                    }
                    ClubField(title: "Contraseña", symbol: "lock") {
                        SecureField("Crea una contraseña", text: $viewModel.password)
                            .textContentType(.newPassword).accessibilityLabel("Contraseña")
                    }
                    Text("Mínimo 6 caracteres, una mayúscula y un símbolo como !, @ o #. Los puntos, comas, punto y coma y tildes no cuentan como símbolo.")
                        .font(.footnote).foregroundStyle(ClubStyle.muted)
                    ClubField(title: "Confirmar contraseña", symbol: "lock.shield") {
                        SecureField("Repite tu contraseña", text: $viewModel.confirmation)
                            .textContentType(.newPassword).accessibilityLabel("Confirmar contraseña")
                    }
                    if let error = viewModel.errorMessage { FeedbackView(message: error) }
                    if let success = viewModel.successMessage { FeedbackView(message: success, isSuccess: true) }
                    Button {
                        Task { await viewModel.register(using: session) }
                    } label: {
                        HStack {
                            if viewModel.isSubmitting { ProgressView().tint(.white) }
                            Text(viewModel.isSubmitting ? "Preparando tu entrada…" : "Crear mi cuenta")
                            if !viewModel.isSubmitting { Image(systemName: "arrow.right") }
                        }
                    }
                    .buttonStyle(ClubButtonStyle()).disabled(!viewModel.canSubmit)
                }
                .disabled(viewModel.isSubmitting)
                .padding(26).frame(maxWidth: 540).frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("Crear cuenta").navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(viewModel.isSubmitting)
        .toolbarBackground(ClubStyle.background, for: .navigationBar).toolbarBackground(.visible, for: .navigationBar)
    }
}
