import SwiftUI

@MainActor
struct DetailView: View {
    let item: ItemModel

    var body: some View {
        ZStack {
            ClubStyle.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    teamHeader
                    if let teamID = item.mlbTeamID { TeamScheduleView(teamID: teamID) }
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Información del equipo").font(.title2.weight(.bold))
                        VStack(spacing: 0) {
                            AttributeRow(title: "Ciudad", value: item.city, symbol: "mappin.and.ellipse")
                            Divider().padding(.horizontal, 18)
                            AttributeRow(title: "Liga", value: item.league, symbol: "trophy")
                            Divider().padding(.horizontal, 18)
                            AttributeRow(title: "División", value: item.division, symbol: "square.grid.2x2")
                            Divider().padding(.horizontal, 18)
                            AttributeRow(title: "Abreviatura", value: item.id, symbol: "textformat.abc")
                        }.background(.white, in: RoundedRectangle(cornerRadius: 12))
                        Text(item.story).font(.subheadline).foregroundStyle(ClubStyle.muted).lineSpacing(5)
                    }
                }
                .padding(20).frame(maxWidth: 720).frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(item.id).navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.white, for: .navigationBar).toolbarBackground(.visible, for: .navigationBar)
    }

    private var teamHeader: some View {
        VStack(alignment: .leading, spacing: 20) {
            ZStack {
                Rectangle().fill(Color(hex: item.colorHex).opacity(0.08))
                Image(systemName: item.symbol)
                    .font(.system(size: 76, weight: .light))
                    .foregroundStyle(ClubStyle.navy)
            }
            .frame(height: 155)
            .overlay(alignment: .bottom) { Rectangle().fill(Color(hex: item.colorHex)).frame(height: 3) }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 8) {
                Text("LIGA \(item.league.uppercased()) · \(item.division.uppercased())")
                    .font(.system(size: 10, weight: .bold)).tracking(1).foregroundStyle(ClubStyle.muted)
                Text(item.name).font(.system(size: 29, weight: .bold)).tracking(-0.5)
                Label(item.city, systemImage: "mappin.and.ellipse")
                    .font(.subheadline).foregroundStyle(ClubStyle.muted)
            }
        }
    }
}

private struct AttributeRow: View {
    let title: String
    let value: String
    let symbol: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol).foregroundStyle(ClubStyle.muted).frame(width: 24)
            Text(title).foregroundStyle(ClubStyle.muted)
            Spacer(minLength: 12)
            Text(value).fontWeight(.semibold).multilineTextAlignment(.trailing)
        }.font(.subheadline).padding(18)
    }
}
