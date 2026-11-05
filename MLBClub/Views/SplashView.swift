import SwiftUI

struct SplashView: View {
    let onFinish: () -> Void
    @State private var hasAppeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            ClubStyle.background.ignoresSafeArea()
            Circle().fill(ClubStyle.navy.opacity(0.025)).frame(width: 370, height: 370)
            Circle().stroke(ClubStyle.red.opacity(0.12), lineWidth: 1).frame(width: 285, height: 285)
            VStack(spacing: 24) {
                ClubMark(size: 250)
                VStack(spacing: 8) {
                    Text("MLB CLUB").font(.system(size: 38, weight: .black, design: .rounded)).tracking(3)
                    Text("Tu próxima entrada empieza aquí.").font(.subheadline).foregroundStyle(ClubStyle.muted)
                }
                ProgressView().tint(ClubStyle.accent).padding(.top, 12)
            }
            .opacity(hasAppeared ? 1 : 0)
            .scaleEffect(hasAppeared || reduceMotion ? 1 : 0.8)
        }
        .task {
            withAnimation(.easeOut(duration: reduceMotion ? 0.1 : 0.8)) { hasAppeared = true }
            do { try await Task.sleep(nanoseconds: 2_000_000_000) }
            catch { return }
            onFinish()
        }
    }
}
