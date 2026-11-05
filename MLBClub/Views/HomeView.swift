import SwiftUI

@MainActor
struct HomeView: View {
    let user: AppUser
    @EnvironmentObject private var session: SessionStore
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingLogout = false

    var body: some View {
        ZStack {
            ClubStyle.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    directoryHeader
                    VStack(alignment: .leading, spacing: 18) {
                        leagueFilter
                        HStack(alignment: .firstTextBaseline) {
                            Text(viewModel.selectedLeague == "Todas" ? "Todos los equipos" : "Liga \(viewModel.selectedLeague)")
                                .font(.subheadline.weight(.semibold))
                            Spacer(minLength: 12)
                            Text("\(viewModel.filteredItems.count) resultados")
                                .font(.caption).monospacedDigit().foregroundStyle(ClubStyle.muted)
                        }
                        if viewModel.filteredItems.isEmpty {
                            emptyResults
                        } else {
                            teamDirectory
                        }
                    }
                }
                .padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 32)
                .frame(maxWidth: 720).frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("MLB CLUB").navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.white, for: .navigationBar).toolbarBackground(.visible, for: .navigationBar)
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Buscar equipo o ciudad")
        .navigationDestination(for: ItemModel.self) { item in DetailView(item: item) }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { ClubMark(size: 64) }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showingLogout = true } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 17, weight: .medium)).foregroundStyle(ClubStyle.navy)
                }.accessibilityLabel("Cerrar sesión")
            }
        }
        .confirmationDialog("¿Cerrar sesión?", isPresented: $showingLogout, titleVisibility: .visible) {
            Button("Cerrar sesión", role: .destructive) { session.logout() }
            Button("Cancelar", role: .cancel) { }
        } message: { Text("Podrás volver a entrar con la cuenta que creaste durante esta ejecución.") }
    }

    private var directoryHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Rectangle().fill(ClubStyle.red).frame(width: 18, height: 3)
                Text("MAJOR LEAGUE BASEBALL")
                    .font(.system(size: 10, weight: .bold)).tracking(1.3)
                    .foregroundStyle(ClubStyle.muted)
            }
            Text("Equipos")
                .font(.system(size: 34, weight: .bold)).tracking(-0.8)
                .foregroundStyle(ClubStyle.navy)
                .accessibilityAddTraits(.isHeader)
            Text("Hola, \(user.name). Consulta los equipos por liga y conoce sus datos.")
                .font(.subheadline).foregroundStyle(ClubStyle.muted)
                .lineSpacing(3).fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var leagueFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["Todas", "Americana", "Nacional"], id: \.self) { league in
                    Button {
                        viewModel.selectedLeague = league
                    } label: {
                        Text(league)
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.horizontal, 18).frame(minHeight: 42)
                            .foregroundStyle(viewModel.selectedLeague == league ? .white : ClubStyle.navy)
                            .background(viewModel.selectedLeague == league ? ClubStyle.navy : .white,
                                        in: RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(ClubStyle.navy.opacity(viewModel.selectedLeague == league ? 0 : 0.12)))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(league == "Todas" ? "Todas las ligas" : "Liga \(league)")
                    .accessibilityAddTraits(viewModel.selectedLeague == league ? .isSelected : [])
                }
            }.padding(1)
        }
    }

    private var teamDirectory: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.filteredItems) { item in
                NavigationLink(value: item) {
                    TeamRow(item: item)
                }
                .buttonStyle(DirectoryRowButtonStyle())
                if item.id != viewModel.filteredItems.last?.id {
                    Divider().padding(.leading, 80)
                }
            }
        }
        .background(.white, in: RoundedRectangle(cornerRadius: 12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(ClubStyle.navy.opacity(0.07)))
    }

    private var emptyResults: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "magnifyingglass").font(.title2).foregroundStyle(ClubStyle.muted)
            Text("No hay equipos con estos filtros").font(.headline)
            Text("Prueba con otro nombre, ciudad o liga.")
                .font(.subheadline).foregroundStyle(ClubStyle.muted)
            Button("Limpiar filtros") {
                viewModel.searchText = ""
                viewModel.selectedLeague = "Todas"
            }.font(.subheadline.weight(.semibold)).padding(.top, 4)
        }
        .padding(24).frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct TeamRow: View {
    let item: ItemModel
    var body: some View {
        HStack(spacing: 16) {
            TeamBadge(item: item, size: 48)
            VStack(alignment: .leading, spacing: 7) {
                Text(item.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(ClubStyle.navy)
                    .fixedSize(horizontal: false, vertical: true)
                Label("\(item.city) · \(item.league) · \(item.division)", systemImage: item.symbol)
                    .font(.system(size: 12)).foregroundStyle(ClubStyle.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(ClubStyle.muted.opacity(0.7))
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16).padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

private struct DirectoryRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? ClubStyle.navy.opacity(0.05) : Color.clear)
    }
}
