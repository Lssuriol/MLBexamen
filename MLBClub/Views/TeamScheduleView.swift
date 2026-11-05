import SwiftUI

@MainActor
struct TeamScheduleView: View {
    let teamID: Int
    @StateObject private var viewModel: ScheduleViewModel
    @State private var selectedSection = "Calendario"
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)

    init(teamID: Int) {
        self.teamID = teamID
        _viewModel = StateObject(wrappedValue: ScheduleViewModel(teamID: teamID))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Partidos").font(.title2.weight(.bold)).accessibilityAddTraits(.isHeader)
                Spacer()
                Button {
                    Task { await viewModel.load() }
                } label: {
                    if viewModel.isLoading { ProgressView() }
                    else { Label("Actualizar", systemImage: "arrow.clockwise").font(.caption.weight(.semibold)) }
                }
                .disabled(viewModel.isLoading).accessibilityLabel("Actualizar partidos")
            }
            Picker("Consultar partidos", selection: $selectedSection) {
                Text("Calendario").tag("Calendario")
                Text("Últimos 30 días").tag("Historial")
            }.pickerStyle(.segmented)

            if selectedSection == "Calendario" { calendarContent }
            else { historyContent }

            if let notice = viewModel.saveNotice { noticeText(notice) }
            Text("Fuente: MLB Stats API. Días según la fecha oficial de MLB; horas en la zona de tu dispositivo. Los marcadores corresponden a la última consulta.")
                .font(.caption2).foregroundStyle(ClubStyle.muted).lineSpacing(3)
        }
        .task(id: viewModel.monthKey) { await viewModel.load() }
    }

    private var calendarContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(spacing: 16) {
                HStack {
                    Button { viewModel.changeMonth(by: -1) } label: {
                        Image(systemName: "chevron.left").frame(width: 40, height: 40)
                    }.accessibilityLabel("Mes anterior")
                    Spacer(minLength: 0)
                    Text(GameCalendar.title(viewModel.month)).font(.subheadline.weight(.semibold))
                    Spacer(minLength: 0)
                    Button { viewModel.changeMonth(by: 1) } label: {
                        Image(systemName: "chevron.right").frame(width: 40, height: 40)
                    }.accessibilityLabel("Mes siguiente")
                }
                LazyVGrid(columns: columns, spacing: 7) {
                    ForEach(Array(["L", "M", "X", "J", "V", "S", "D"].enumerated()), id: \.offset) { _, day in
                        Text(day).font(.caption.weight(.semibold)).foregroundStyle(ClubStyle.muted)
                            .frame(maxWidth: .infinity).padding(.bottom, 6)
                    }
                    ForEach(Array(GameCalendar.days(in: viewModel.month).enumerated()), id: \.offset) { _, date in
                        if let date = date { dayCell(date) }
                        else { Color.clear.frame(height: 44).accessibilityHidden(true) }
                    }
                }
                HStack {
                    HStack(spacing: 6) {
                        Circle().fill(ClubStyle.red).frame(width: 5, height: 5)
                        Text("Día con partido").font(.caption2).foregroundStyle(ClubStyle.muted)
                    }
                    Spacer()
                    Button("Hoy") { viewModel.goToToday() }.font(.caption.weight(.semibold))
                }
            }
            .padding(14).background(.white, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(ClubStyle.navy.opacity(0.08)))

            if let notice = viewModel.monthNotice { noticeText(notice) }
            if let snapshot = viewModel.monthSnapshot {
                lastUpdate(snapshot.fetchedAt)
                if viewModel.monthGames.isEmpty {
                    emptyText("No hay partidos publicados para este mes.")
                } else {
                    Text(viewModel.selectedDate.formatted(.dateTime.day().month(.wide).locale(Locale(identifier: "es_PE"))))
                        .font(.subheadline.weight(.semibold))
                    if viewModel.dayGames.isEmpty { emptyText("No hay partidos para el día seleccionado.") }
                    ForEach(viewModel.dayGames) { game in GameResultRow(game: game, teamID: teamID) }
                }
            } else if viewModel.isLoading { emptyText("Consultando el calendario…") }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let selected = GameCalendar.calendar.isDate(date, inSameDayAs: viewModel.selectedDate)
        let gameCount = viewModel.games(on: date).count
        return Button { viewModel.selectedDate = date } label: {
            VStack(spacing: 4) {
                Text("\(GameCalendar.calendar.component(.day, from: date))")
                    .font(.system(size: 14, weight: selected ? .bold : .regular))
                HStack(spacing: 2) {
                    ForEach(0..<min(gameCount, 2), id: \.self) { _ in
                        Circle().fill(selected ? Color.white : ClubStyle.red).frame(width: 4, height: 4)
                    }
                }.frame(height: 4)
            }
            .frame(maxWidth: .infinity).frame(height: 44)
            .foregroundStyle(selected ? .white : ClubStyle.navy)
            .background(selected ? ClubStyle.navy : .clear, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(date.formatted(date: .complete, time: .omitted)), \(gameCount) partidos")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var historyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let notice = viewModel.historyNotice { noticeText(notice) }
            if let snapshot = viewModel.saved.recent {
                HStack(spacing: 0) {
                    summaryValue("Jugados", value: viewModel.recentGames.count)
                    Divider()
                    summaryValue("Victorias", value: viewModel.wins)
                    Divider()
                    summaryValue("Derrotas", value: viewModel.losses)
                }
                .padding(.vertical, 18).background(.white, in: RoundedRectangle(cornerRadius: 12))
                .fixedSize(horizontal: false, vertical: true)
                lastUpdate(snapshot.fetchedAt)
                if viewModel.recentGames.isEmpty {
                    emptyText("No hay partidos finalizados en los últimos 30 días. Puedes consultar otros meses en el calendario.")
                }
                ForEach(viewModel.recentGames) { game in GameResultRow(game: game, teamID: teamID) }
            } else if viewModel.isLoading { emptyText("Consultando los resultados…") }
        }
    }
    private func summaryValue(_ label: String, value: Int) -> some View {
        VStack(spacing: 7) {
            Text("\(value)").font(.system(size: 25, weight: .bold)).monospacedDigit()
            Text(label).font(.caption).foregroundStyle(ClubStyle.muted)
        }.frame(maxWidth: .infinity)
    }
    private func lastUpdate(_ date: Date) -> some View {
        Label("Última consulta: \(date.formatted(date: .abbreviated, time: .shortened))", systemImage: "internaldrive")
            .font(.caption2).foregroundStyle(ClubStyle.muted)
    }
    private func noticeText(_ message: String) -> some View {
        Label(message, systemImage: "info.circle")
            .font(.caption).foregroundStyle(ClubStyle.muted).fixedSize(horizontal: false, vertical: true)
    }
    private func emptyText(_ message: String) -> some View {
        Text(message).font(.subheadline).foregroundStyle(ClubStyle.muted)
            .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 12)
    }
}

private struct GameResultRow: View {
    let game: GameModel
    let teamID: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text(game.officialDate).font(.caption.weight(.medium))
                Spacer(minLength: 10)
                Text(game.result(for: teamID) ?? game.statusLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(game.result(for: teamID) == "Victoria" ? ClubStyle.success : ClubStyle.muted)
                    .multilineTextAlignment(.trailing)
            }
            VStack(spacing: 10) {
                scoreLine(game.teams.away, location: "Visitante")
                scoreLine(game.teams.home, location: "Local")
            }
            if let venue = game.venue {
                Label(venue.name, systemImage: "mappin.and.ellipse")
                    .font(.caption2).foregroundStyle(ClubStyle.muted)
            }
            if !game.isFinal, game.status.startTimeTBD != true, let date = game.startDate {
                Text("Hora: \(date.formatted(date: .omitted, time: .shortened))")
                    .font(.caption2).foregroundStyle(ClubStyle.muted)
            }
        }
        .padding(18).background(.white, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(ClubStyle.navy.opacity(0.07)))
    }
    private func scoreLine(_ side: GameModel.Side, location: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(side.team.name).font(.system(size: 14, weight: side.team.id == teamID ? .semibold : .regular))
                Text(location).font(.caption2).foregroundStyle(ClubStyle.muted)
            }
            Spacer(minLength: 0)
            Text(side.score.map(String.init) ?? "—").font(.title3.weight(.semibold)).monospacedDigit()
        }
    }
}
