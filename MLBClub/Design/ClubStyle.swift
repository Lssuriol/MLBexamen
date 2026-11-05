import SwiftUI

enum ClubStyle {
    static let background = Color(hex: 0xF4F6F8)
    static let surface = Color.white
    static let navy = Color(hex: 0x041E42)
    static let muted = Color(hex: 0x536174)
    static let accent = Color(hex: 0x0067B1)
    static let red = Color(hex: 0xBF0D3E)
    static let success = Color(hex: 0x176B48)
}

extension Color {
    init(hex: UInt) {
        self.init(.sRGB, red: Double((hex >> 16) & 255) / 255,
                  green: Double((hex >> 8) & 255) / 255,
                  blue: Double(hex & 255) / 255, opacity: 1)
    }
}

struct ClubButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded))
            .frame(maxWidth: .infinity).padding(.vertical, 17)
            .foregroundStyle(.white)
            .background(ClubStyle.navy.opacity(isEnabled ? 1 : 0.35), in: RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct ClubField<Content: View>: View {
    let title: String
    let symbol: String
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(ClubStyle.muted)
            HStack(spacing: 12) {
                Image(systemName: symbol).foregroundStyle(ClubStyle.accent).frame(width: 22)
                content().foregroundStyle(ClubStyle.navy)
            }
            .padding(16).background(ClubStyle.surface, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(ClubStyle.navy.opacity(0.12)))
        }
    }
}

struct FeedbackView: View {
    let message: String
    var isSuccess = false
    var body: some View {
        Label(message, systemImage: isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
            .font(.subheadline).foregroundStyle(isSuccess ? ClubStyle.success : ClubStyle.red)
            .frame(maxWidth: .infinity, alignment: .leading).padding(14)
            .background((isSuccess ? ClubStyle.success : ClubStyle.red).opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            .accessibilityLabel(message)
    }
}

struct ClubMark: View {
    // Se usa exactamente el logo proporcionado, sin redibujarlo ni estirarlo.
    var size: CGFloat = 156
    var body: some View {
        Image("MLBLogo")
            .resizable().scaledToFit()
            .frame(width: size, height: size * 328 / 608)
            .accessibilityLabel("Major League Baseball")
    }
}

struct TeamBadge: View {
    let item: ItemModel
    var size: CGFloat = 62
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8).fill(Color(hex: item.colorHex))
                .overlay(RoundedRectangle(cornerRadius: 8).fill(ClubStyle.navy.opacity(0.22)))
            Text(item.id).font(.system(size: size * 0.29, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size).accessibilityHidden(true)
    }
}
