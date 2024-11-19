import SwiftUI

struct ボタンスタイル_バウンド: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(16)
            .foregroundColor(Color.primary)
            .background(Color(.systemBackground))

//            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.primary, lineWidth: 1) // ボーダーを追加
            )
            .cornerRadius(40)
            .shadow(color: Color.black, radius: 8, x: 0, y: 0) // 影を追加

            .scaleEffect(configuration.isPressed || isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .onChange(of: configuration.isPressed) { newValue in
                if newValue {
                    isPressed = true
                } else {
                    if isPressed {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isPressed = false
                            }
                        }
                    }
                }
            }
    }
}

struct ボタンスタイル_背景色変える: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Color.orange.opacity(configuration.isPressed ? 0.7 : 1.0) // 指が触れている間の不透明度変更
            )

            .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 12)}
}
