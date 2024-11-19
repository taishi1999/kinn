import SwiftUI

struct パーツ_ライナーグラデーション: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(.black).opacity(0.5), Color(.black).opacity(0)]),
            startPoint: .bottom,
            endPoint: .top
        )
        .frame(height: 16)
        .padding(.horizontal, UIScreen.main.bounds.width <= 375 ? 16 : 20)
    }
}
