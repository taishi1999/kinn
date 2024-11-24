import SwiftUI

struct パーツ_ライナーグラデーション: View {
    var height: CGFloat
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(.black).opacity(1), Color(.black).opacity(0)]),
            startPoint: .bottom,
            endPoint: .top
        )
        .frame(height: height)
//        .padding(.horizontal, UIScreen.main.bounds.width <= 375 ? 16 : 20)
    }
}
