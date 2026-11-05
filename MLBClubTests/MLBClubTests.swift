import XCTest
@testable import MLBClub

final class MLBClubTests: XCTestCase {
    func testPasswordPolicy() {
        XCTAssertNotNil(Validation.passwordError("Ab1!"))
        XCTAssertNotNil(Validation.passwordError("abcdef!"))
        XCTAssertNotNil(Validation.passwordError("Abcdef."))
        XCTAssertNotNil(Validation.passwordError("Abcdef,"))
        XCTAssertNotNil(Validation.passwordError("Abcdef;"))
        XCTAssertNotNil(Validation.passwordError("Abcdeá"))
        XCTAssertNil(Validation.passwordError("MLB2026!"))
    }

    func testEmailFormatAndNormalization() {
        XCTAssertTrue(Validation.isValidEmail(" JOSE@correo.com "))
        XCTAssertFalse(Validation.isValidEmail("jose@correo"))
        XCTAssertFalse(Validation.isValidEmail("jose correo.com"))
        XCTAssertFalse(Validation.isValidEmail("jose..p@correo.com"))
        XCTAssertFalse(Validation.isValidEmail(".jose@correo.com"))
        XCTAssertFalse(Validation.isValidEmail("jose@-correo.com"))
        XCTAssertFalse(Validation.isValidEmail("jose@correo-.com"))
        XCTAssertEqual(Validation.normalizedEmail(" JOSE@correo.com "), "jose@correo.com")
    }

    @MainActor
    func testDuplicateEmailLogoutAndLogin() throws {
        let session = SessionStore()
        let user = try session.register(name: "Jose", email: "jose@correo.com", password: "MLB2026!")
        XCTAssertThrowsError(try session.register(name: "Otro", email: " JOSE@correo.com ", password: "Otra123!"))
        session.activate(user)
        XCTAssertEqual(session.currentUser?.id, user.id)
        session.logout()
        XCTAssertNil(session.currentUser)
        XCTAssertThrowsError(try session.login(email: user.email, password: "Incorrecta!"))
        try session.login(email: "JOSE@correo.com", password: "MLB2026!")
        XCTAssertEqual(session.currentUser?.id, user.id)
        XCTAssertFalse(SessionStore().contains(email: user.email))
    }

    @MainActor
    func testLoginValidationAndReactiveError() {
        let vm = LoginViewModel()
        let session = SessionStore()
        XCTAssertFalse(vm.canSubmit)
        vm.email = "incorrecto"
        vm.password = "MLB2026!"
        vm.login(using: session)
        XCTAssertNotNil(vm.errorMessage)
        vm.email = "jose@correo.com"
        XCTAssertNil(vm.errorMessage)
        vm.login(using: session)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertNil(session.currentUser)
    }

    @MainActor
    func testRegisterMismatchedPasswords() async {
        let vm = RegisterViewModel()
        let session = SessionStore()
        vm.name = "Jose"
        vm.email = "jose@correo.com"
        vm.password = "MLB2026!"
        vm.confirmation = "Otra123!"
        await vm.register(using: session)
        XCTAssertEqual(vm.errorMessage, "Las contraseñas no coinciden.")
        XCTAssertFalse(session.contains(email: vm.email))
    }

    @MainActor
    func testRegisterSuccessAuthenticates() async {
        let vm = RegisterViewModel()
        let session = SessionStore()
        vm.name = "Jose"
        vm.email = "jose@correo.com"
        vm.password = "MLB2026!"
        vm.confirmation = "MLB2026!"
        await vm.register(using: session)
        XCTAssertNotNil(vm.successMessage)
        XCTAssertEqual(session.currentUser?.email, "jose@correo.com")
        XCTAssertFalse(vm.isSubmitting)
        XCTAssertTrue(vm.password.isEmpty)
    }

    @MainActor
    func testReactiveSearchLeagueAndCatalogChanges() {
        let vm = HomeViewModel()
        XCTAssertGreaterThanOrEqual(vm.items.count, 8)
        XCTAssertEqual(Set(vm.items.map(\.id)).count, vm.items.count)
        vm.searchText = " New York "
        XCTAssertEqual(Set(vm.filteredItems.map(\.id)), Set(["NYY", "NYM"]))
        vm.selectedLeague = "Nacional"
        XCTAssertEqual(vm.filteredItems.map(\.id), ["NYM"])
        vm.searchText = "INEXISTENTE"
        XCTAssertTrue(vm.filteredItems.isEmpty)
        vm.searchText = ""
        vm.selectedLeague = "Todas"
        vm.items = []
        XCTAssertTrue(vm.filteredItems.isEmpty)
    }
}

private struct FixtureScheduleClient: ScheduleFetching {
    let values: [GameModel]
    func games(teamID: Int, from start: Date, through end: Date) async throws -> [GameModel] {
        values.filter { $0.officialDate >= GameCalendar.key(start) && $0.officialDate <= GameCalendar.key(end) }
    }
}
private struct UnavailableScheduleClient: ScheduleFetching {
    func games(teamID: Int, from start: Date, through end: Date) async throws -> [GameModel] {
        throw URLError(.notConnectedToInternet)
    }
}

extension MLBClubTests {
    private func sampleGame(id: Int, date: String, final: Bool = true, homeScore: Int? = 5,
                            awayScore: Int? = 2) -> GameModel {
        GameModel(gamePk: id, gameDate: "\(date)T23:00:00Z", officialDate: date,
                  status: .init(abstractGameState: final ? "Final" : "Preview", detailedState: nil, startTimeTBD: false),
                  teams: .init(away: .init(team: .init(id: 111, name: "Boston Red Sox"), score: awayScore),
                               home: .init(team: .init(id: 147, name: "New York Yankees"), score: homeScore)),
                  venue: .init(name: "Estadio de prueba"))
    }
    private func fixedDate(_ value: String) -> Date {
        ISO8601DateFormatter().date(from: value + "T12:00:00Z")!
    }

    func testScheduleDecodesMissingScoresAndCanceledGame() throws {
        let json = #"{"dates":[{"games":[{"gamePk":1,"gameDate":"2026-11-05T23:00:00Z","officialDate":"2026-11-05","status":{"abstractGameState":"Final","detailedState":"Cancelled"},"teams":{"away":{"team":{"id":111,"name":"Boston"}},"home":{"team":{"id":147,"name":"New York"}}}}]}]}"#
        let response = try JSONDecoder().decode(ScheduleResponse.self, from: Data(json.utf8))
        XCTAssertEqual(response.games.count, 1)
        XCTAssertFalse(response.games[0].isFinal)
        XCTAssertEqual(response.games[0].statusLabel, "Cancelado")
        XCTAssertNil(response.games[0].result(for: 147))
    }

    func testGameOutcomeAndTeamIDs() {
        let game = sampleGame(id: 10, date: "2026-11-05")
        XCTAssertEqual(game.result(for: 147), "Victoria")
        XCTAssertEqual(game.result(for: 111), "Derrota")
        XCTAssertNil(game.result(for: 119))
        XCTAssertNil(sampleGame(id: 11, date: "2026-11-05", final: false).result(for: 147))
        XCTAssertEqual(Set(ItemModel.catalog.compactMap(\.mlbTeamID)).count, 10)
    }

    func testCalendarHandlesMonthAndLeapYear() {
        let february = fixedDate("2024-02-15")
        let days = GameCalendar.days(in: february).compactMap { $0 }
        XCTAssertEqual(days.count, 29)
        XCTAssertEqual(GameCalendar.key(days.first!), "2024-02-01")
        XCTAssertEqual(GameCalendar.key(days.last!), "2024-02-29")
        XCTAssertEqual(GameCalendar.key(GameCalendar.monthEnd(february)), "2024-02-29")
    }

    @MainActor
    func testSchedulePersistsAndSurvivesNetworkFailure() async throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: folder) }
        let disk = ScheduleDiskStore(directory: folder)
        let today = fixedDate("2026-11-05")
        let games = [sampleGame(id: 10, date: "2026-10-07"),
                     sampleGame(id: 11, date: "2026-10-06"),
                     sampleGame(id: 12, date: "2026-11-05", final: false, homeScore: nil, awayScore: nil),
                     sampleGame(id: 13, date: "2026-11-01", homeScore: 1, awayScore: 3)]
        let vm = ScheduleViewModel(teamID: 147, client: FixtureScheduleClient(values: games), disk: disk, now: { today })
        await vm.load()
        XCTAssertEqual(vm.monthGames.count, 2)
        XCTAssertEqual(vm.recentGames.count, 2)
        XCTAssertEqual(vm.wins, 1)
        XCTAssertEqual(vm.losses, 1)
        XCTAssertNil(vm.saveNotice)
        XCTAssertNotNil(disk.read(teamID: 147).months["2026-11"])
        let offline = ScheduleViewModel(teamID: 147, client: UnavailableScheduleClient(), disk: disk, now: { today })
        XCTAssertEqual(offline.monthGames.count, 2)
        await offline.load()
        XCTAssertEqual(offline.recentGames.count, 2)
        XCTAssertNotNil(offline.monthNotice)
        XCTAssertNotNil(offline.historyNotice)
        XCTAssertFalse(offline.isLoading)
        XCTAssertTrue(disk.read(teamID: 111).months.isEmpty)
    }

    @MainActor
    func testCalendarKeepsDoubleheadersAndRemovesDuplicateIDs() async {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: folder) }
        let today = fixedDate("2026-11-05")
        let game = sampleGame(id: 10, date: "2026-10-07")
        let second = sampleGame(id: 11, date: "2026-10-07")
        let vm = ScheduleViewModel(teamID: 147, client: FixtureScheduleClient(values: [game, game, second]),
                                   disk: ScheduleDiskStore(directory: folder), now: { today })
        vm.changeMonth(by: -1)
        await vm.load()
        XCTAssertEqual(vm.monthGames.count, 2)
        XCTAssertEqual(vm.games(on: fixedDate("2026-10-07")).count, 2)
    }
}
