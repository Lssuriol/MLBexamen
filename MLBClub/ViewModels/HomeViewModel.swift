import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var items: [ItemModel] { didSet { applyFilters() } }
    @Published var searchText = "" { didSet { applyFilters() } }
    @Published var selectedLeague = "Todas" { didSet { applyFilters() } }
    @Published private(set) var filteredItems: [ItemModel]

    init(items: [ItemModel] = ItemModel.catalog) {
        self.items = items
        self.filteredItems = items
    }

    private func applyFilters() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        filteredItems = items.filter { item in
            let leagueMatches = selectedLeague == "Todas" || item.league == selectedLeague
            let searchableText = "\(item.name) \(item.city) \(item.id) \(item.league) \(item.division)"
            return leagueMatches && (query.isEmpty || searchableText.localizedStandardContains(query))
        }
    }
}
