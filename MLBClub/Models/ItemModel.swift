import Foundation

struct ItemModel: Identifiable, Hashable {
    let id: String
    let name: String
    let city: String
    let league: String
    let division: String
    let symbol: String
    let colorHex: UInt
    let story: String

    var subtitle: String { "\(city) · \(division)" }

    // Catálogo local de ejemplo; no representa resultados deportivos en vivo.
    static let catalog: [ItemModel] = [
        .init(id: "NYY", name: "New York Yankees", city: "New York", league: "Americana", division: "Este", symbol: "baseball.fill", colorHex: 0x5576AA, story: "Un clásico del béisbol de Nueva York. Su identidad combina la tradición del juego con una afición que acompaña cada entrada. Explora su ubicación dentro de la Liga Americana y descubre más equipos desde el catálogo."),
        .init(id: "BOS", name: "Boston Red Sox", city: "Boston", league: "Americana", division: "Este", symbol: "baseball.fill", colorHex: 0xBD3039, story: "Boston vive el béisbol con pasión. Los Red Sox forman parte de la División Este de la Liga Americana, donde cada serie ofrece una oportunidad para conocer las rivalidades y la cultura de este deporte."),
        .init(id: "LAD", name: "Los Angeles Dodgers", city: "Los Angeles", league: "Nacional", division: "Oeste", symbol: "baseball.fill", colorHex: 0x1478DF, story: "El azul de Los Ángeles es parte de una identidad reconocible en el béisbol. Los Dodgers representan a la ciudad en la División Oeste de la Liga Nacional. Esta ficha reúne sus datos básicos para explorar la organización de la MLB."),
        .init(id: "SD", name: "San Diego Padres", city: "San Diego", league: "Nacional", division: "Oeste", symbol: "baseball.fill", colorHex: 0xA28738, story: "San Diego aporta su propia personalidad al béisbol de la costa oeste. Los Padres compiten en la Liga Nacional y comparten división con otros equipos de la región. Usa el buscador para comparar sus datos con los demás clubes."),
        .init(id: "SF", name: "San Francisco Giants", city: "San Francisco", league: "Nacional", division: "Oeste", symbol: "baseball.fill", colorHex: 0xF47735, story: "Los Giants llevan el nombre de San Francisco al diamante. Su combinación de naranja y negro acompaña una cultura de béisbol muy presente en la ciudad. Pertenecen a la División Oeste de la Liga Nacional."),
        .init(id: "HOU", name: "Houston Astros", city: "Houston", league: "Americana", division: "Oeste", symbol: "baseball.fill", colorHex: 0xEB6E1F, story: "Houston tiene su lugar en la Liga Americana con los Astros. El club forma parte de la División Oeste. En este catálogo puedes encontrarlo por su nombre, su ciudad, su abreviatura o su división."),
        .init(id: "SEA", name: "Seattle Mariners", city: "Seattle", league: "Americana", division: "Oeste", symbol: "baseball.fill", colorHex: 0x159B93, story: "La identidad de los Mariners está ligada a Seattle y a su carácter marítimo. El equipo pertenece a la División Oeste de la Liga Americana. Revisa los atributos de esta ficha para ubicarlo dentro de la estructura de la MLB."),
        .init(id: "CHC", name: "Chicago Cubs", city: "Chicago", league: "Nacional", division: "Central", symbol: "baseball.fill", colorHex: 0x377DE0, story: "Los Cubs son una de las identidades del béisbol de Chicago. En la Liga Nacional, forman parte de la División Central. Su ficha ofrece un punto de partida para recorrer los equipos por ciudad y por liga."),
        .init(id: "NYM", name: "New York Mets", city: "New York", league: "Nacional", division: "Este", symbol: "baseball.fill", colorHex: 0xF07835, story: "Los Mets aportan otra forma de vivir el béisbol en Nueva York. Pertenecen a la División Este de la Liga Nacional. Desde el Home puedes buscar la ciudad para encontrar también al otro equipo neoyorquino del catálogo."),
        .init(id: "PHI", name: "Philadelphia Phillies", city: "Philadelphia", league: "Nacional", division: "Este", symbol: "baseball.fill", colorHex: 0xE84358, story: "Philadelphia acompaña a los Phillies con una afición apasionada. Este club forma parte de la División Este de la Liga Nacional. El catálogo permite localizarlo por su nombre completo, su ciudad o la abreviatura PHI.")
    ]
}
