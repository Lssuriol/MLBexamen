import Foundation

struct GameModel: Codable, Identifiable {
    let gamePk: Int
    let gameDate: String
    let officialDate: String
    let status: Status
    let teams: Teams
    let venue: Venue?

    var id: Int { gamePk }
    var isFinal: Bool {
        let detail = (status.detailedState ?? "").lowercased()
        return status.abstractGameState == "Final" && teams.home.score != nil && teams.away.score != nil
            && !detail.contains("cancel") && !detail.contains("postpon") && !detail.contains("suspend")
    }
    var startDate: Date? {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: gameDate) { return date }
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: gameDate)
    }
    var statusLabel: String {
        let detail = status.detailedState ?? ""
        if detail.localizedCaseInsensitiveContains("postpon") { return "Pospuesto" }
        if detail.localizedCaseInsensitiveContains("cancel") { return "Cancelado" }
        if detail.localizedCaseInsensitiveContains("suspend") { return "Suspendido" }
        if detail.localizedCaseInsensitiveContains("delay") { return "Demorado" }
        if isFinal { return "Finalizado" }
        if status.abstractGameState == "Live" { return "En juego · última consulta" }
        return status.startTimeTBD == true ? "Horario por confirmar" : "Programado"
    }
    func result(for teamID: Int) -> String? {
        guard isFinal, let home = teams.home.score, let away = teams.away.score else { return nil }
        guard teams.home.team.id == teamID || teams.away.team.id == teamID else { return nil }
        if home == away { return "Empate" }
        let won = teams.home.team.id == teamID ? home > away : away > home
        return won ? "Victoria" : "Derrota"
    }
    struct Status: Codable {
        let abstractGameState: String
        let detailedState: String?
        let startTimeTBD: Bool?
    }
    struct Teams: Codable { let away: Side; let home: Side }
    struct Side: Codable { let team: Team; let score: Int? }
    struct Team: Codable { let id: Int; let name: String }
    struct Venue: Codable { let name: String }
}

struct ScheduleResponse: Decodable {
    let dates: [Day]
    struct Day: Decodable { let games: [GameModel] }
    var games: [GameModel] { dates.flatMap(\.games) }
}

enum GameCalendar {
    static var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.firstWeekday = 2
        return value
    }
    static func key(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    static func monthStart(_ date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }
    static func monthEnd(_ date: Date) -> Date {
        let next = calendar.date(byAdding: .month, value: 1, to: monthStart(date)) ?? date
        return calendar.date(byAdding: .day, value: -1, to: next) ?? date
    }
    static func monthKey(_ date: Date) -> String { String(key(date).prefix(7)) }
    static func title(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "es_PE")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date).capitalized
    }
    static func days(in month: Date) -> [Date?] {
        let first = monthStart(month)
        let weekday = calendar.component(.weekday, from: first)
        let padding = (weekday - calendar.firstWeekday + 7) % 7
        let count = calendar.range(of: .day, in: .month, for: first)?.count ?? 0
        return Array(repeating: nil, count: padding) + (0..<count).map {
            calendar.date(byAdding: .day, value: $0, to: first)
        }
    }
}

extension ItemModel {
    var mlbTeamID: Int? {
        switch id {
        case "NYY": return 147
        case "BOS": return 111
        case "LAD": return 119
        case "SD": return 135
        case "SF": return 137
        case "HOU": return 117
        case "SEA": return 136
        case "CHC": return 112
        case "NYM": return 121
        case "PHI": return 143
        default: return nil
        }
    }
}
