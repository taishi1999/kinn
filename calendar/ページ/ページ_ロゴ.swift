import SwiftUI
struct ページ_ロゴ: View {
    var body: some View {
        VStack {
            // SF Symbolsのアイコンを代用
            Image(systemName: "scribble.variable") // 適当なSF Symbolsアイコンを指定
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.white) // アイコンの色を指定
        }
        .background(Color.black) // 背景色を黒に設定
        .edgesIgnoringSafeArea(.all) // 画面全体をカバー
    }
}
