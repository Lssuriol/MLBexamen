import Foundation
import Combine

protocol ScheduleFetching {
    func games(teamID: Int, from start: Date, through end: Date) async throws -> [GameModel]
}

struct MLBScheduleClient: ScheduleFetching {
    func games(teamID: Int, from start: Date, through end: Date) async throws -> [GameModel] {
        var components = URLComponents(string: "https://statsapi.mlb.com/api/v1/schedule")!
        components.queryItems = [
            URLQueryItem(name: "sportId", value: "1"),
            URLQueryItem(name: "teamId", value: String(teamID)),
            URLQueryItem(name: "startDate", value: GameCalendar.key(start)),
            URLQueryItem(name: "endDate", value: GameCalendar.key(end))
        ]
        guard let url = components.url else { throw URLError(.badURL) }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(ScheduleResponse.self, from: data).games
    }
}

struct ScheduleSnapshot: Codable {
    let fetchedAt: Date
    let games: [GameModel]
}

struct SavedSchedule: Codable {
    var months: [String: ScheduleSnapshot] = [:]
    var recent: ScheduleSnapshot?
}

struct ScheduleDiskStore {
    let directory: URL
    init(directory: URL? = nil) {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        self.directory = directory ?? base.appendingPathComponent("MLBClub/Schedules", isDirectory: true)
    }
    private func file(for teamID: Int) -> URL { directory.appendingPathComponent("team-\(teamID).json") }
    func read(teamID: Int) -> SavedSchedule {
        guard let data = try? Data(contentsOf: file(for: teamID)),
              let saved = try? JSONDecoder().decode(SavedSchedule.self, from: data) else { return SavedSchedule() }
        return saved
    }
    func write(_ saved: SavedSchedule, teamID: Int) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try JSONEncoder().encode(saved).write(to: file(for: teamID), options: .atomic)
    }
}

@MainActor
final class ScheduleViewModel: ObservableObject {
    let teamID: Int
    @Published private(set) var month: Date
    @Published var selectedDate: Date
    @Published private(set) var saved: SavedSchedule
    @Published private(set) var isLoading = false
    @Published private(set) var monthNotice: String?
    @Published private(set) var historyNotice: String?
    @Published private(set) var saveNotice: String?
    private let client: any ScheduleFetching
    private let disk: ScheduleDiskStore
    private let now: () -> Date
    private var loadID = UUID()

    init(teamID: Int, client: any ScheduleFetching = MLBScheduleClient(),
         disk: ScheduleDiskStore = ScheduleDiskStore(), now: @escaping () -> Date = Date.init) {
        self.teamID = teamID
        self.client = client
        self.disk = disk
        self.now = now
        self.month = GameCalendar.monthStart(now())
        self.selectedDate = now()
        self.saved = disk.read(teamID: teamID)
    }

    var monthKey: String { GameCalendar.monthKey(month) }
    var monthSnapshot: ScheduleSnapshot? { saved.months[monthKey] }
    var monthGames: [GameModel] { monthSnapshot?.games ?? [] }
    var dayGames: [GameModel] { games(on: selectedDate) }
    var recentGames: [GameModel] {
        let end = GameCalendar.calendar.startOfDay(for: now())
        let start = GameCalendar.calendar.date(byAdding: .day, value: -29, to: end) ?? end
        let startKey = GameCalendar.key(start)
        let endKey = GameCalendar.key(end)
        return (saved.recent?.games ?? []).filter {
            $0.isFinal && $0.officialDate >= startKey && $0.officialDate <= endKey
        }.sorted { $0.gameDate > $1.gameDate }
    }
    var wins: Int { recentGames.filter { $0.result(for: teamID) == "Victoria" }.count }
    var losses: Int { recentGames.filter { $0.result(for: teamID) == "Derrota" }.count }

    func games(on date: Date) -> [GameModel] {
        monthGames.filter { $0.officialDate == GameCalendar.key(date) }.sorted { $0.gameDate < $1.gameDate }
    }
    func changeMonth(by value: Int) {
        guard let next = GameCalendar.calendar.date(byAdding: .month, value: value, to: month) else { return }
        month = next
        selectedDate = next
        monthNotice = nil
    }
    func goToToday() {
        month = GameCalendar.monthStart(now())
        selectedDate = now()
    }

    private func fetch(from start: Date, through end: Date) async -> Result<[GameModel], Error> {
        do { return .success(try await client.games(teamID: teamID, from: start, through: end)) }
        catch { return .failure(error) }
    }

    func load() async {
        let ticket = UUID()
        loadID = ticket
        let requestedMonth = month
        let key = monthKey
        let today = now()
        let historyStart = GameCalendar.calendar.date(byAdding: .day, value: -29, to: today) ?? today
        isLoading = true
        monthNotice = nil
        historyNotice = nil
        saveNotice = nil
        defer { if loadID == ticket { isLoading = false } }

        async let calendarResult = fetch(from: GameCalendar.monthStart(requestedMonth), through: GameCalendar.monthEnd(requestedMonth))
        async let historyResult = fetch(from: historyStart, through: today)
        let (calendarData, historyData) = await (calendarResult, historyResult)
        guard !Task.isCancelled, loadID == ticket else { return }
        var updated = saved
        var didUpdate = false
        switch calendarData {
        case .success(let games):
            updated.months[key] = ScheduleSnapshot(fetchedAt: now(), games: unique(games))
            didUpdate = true
        case .failure:
            monthNotice = updated.months[key] == nil
                ? "No se pudo consultar el calendario. Revisa tu conexión e inténtalo de nuevo."
                : "No se pudo actualizar. Se muestra la última consulta guardada."
        }
        switch historyData {
        case .success(let games):
            updated.recent = ScheduleSnapshot(fetchedAt: now(), games: unique(games))
            didUpdate = true
        case .failure:
            historyNotice = updated.recent == nil
                ? "No se pudo consultar el historial. Puedes volver a intentarlo."
                : "Historial sin actualizar. Se muestran los resultados guardados que corresponden a los últimos 30 días."
        }
        guard didUpdate else { return }
        // Mantiene hasta 12 meses consultados por equipo, más el historial reciente.
        let retained = Set(updated.months.sorted { $0.value.fetchedAt > $1.value.fetchedAt }.prefix(12).map(\.key))
        updated.months = updated.months.filter { retained.contains($0.key) }
        saved = updated
        do { try disk.write(updated, teamID: teamID) }
        catch { saveNotice = "Los datos se consultaron, pero no se pudieron guardar en este dispositivo." }
    }
    private func unique(_ games: [GameModel]) -> [GameModel] {
        var seen = Set<Int>()
        return games.filter { seen.insert($0.id).inserted }.sorted { $0.gameDate < $1.gameDate }
    }
}
