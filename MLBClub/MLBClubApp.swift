import SwiftUI

@main
@MainActor
struct MLBClubApp: App {
    @StateObject private var session = SessionStore()
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(session)
                .foregroundStyle(ClubStyle.navy)
                .preferredColorScheme(.light).tint(ClubStyle.accent)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var hasFinishedSplash = false

    var body: some View {
        Group {
            if !hasFinishedSplash {
                SplashView { hasFinishedSplash = true }
            } else if let user = session.currentUser {
                NavigationStack { HomeView(user: user) }
            } else {
                NavigationStack { LoginView() }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: hasFinishedSplash)
        .animation(.easeInOut(duration: 0.3), value: session.currentUser != nil)
    }
}
