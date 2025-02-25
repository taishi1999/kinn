import SwiftUI

struct ページ_ブロック画面: View {
    var action: () -> Void
    @State private var isAnimating = false
    @Environment(\.presentationMode) var presentationMode // フルスクリーンを閉じるために必要

    @State private var フラグ_日記エディタ表示 = false  // シートの表示状態を管理

    var body: some View {
        VStack {
            Button(action: {
                // フルスクリーンを閉じるアクション
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("閉じる")
                    .font(.headline)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Spacer()

            // 鍵アイコンとブロック実行中メッセージ
            VStack(spacing: 16) {
//                Image(systemName: "lock.fill")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 24, height: 24)
//                    .padding(20)
//                //                            .background(Color.primary.opacity(0.2))
//                    .clipShape(Circle())
//                    .overlay(
//                        Circle()
//                            .stroke(Color.primary, lineWidth: 1)
//                    )
//                    .foregroundColor(.primary)

                Text("📖")
                    .font(.system(size: 56)) // フォントサイズを調整
//                    .frame(width: 24, height: 24)


                VStack(spacing: 4){
                    Text("日記を書く時間です！")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("10/23(金) 12:00-13:00")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                }
            }

            Spacer()

            // 日記を書く促進メッセージ
            VStack(spacing: 16) {
//                Text("日記を書いてブロックを解除しましょう！")
//                    .foregroundColor(.primary)
//                    .fontWeight(.bold)

                パーツ_共通ボタン(ボタンテキスト: "今日の日記を書く", action:action)
                    .padding(.horizontal,24)
                    .fullScreenCover(isPresented: $フラグ_日記エディタ表示) {
                        NavigationView {
                            ページ_日記エディタ {
                                フラグ_日記エディタ表示 = false  // 保存完了後にシートを閉じる
                            }
                            .navigationBarTitleDisplayMode(.inline)
                        }
                        .interactiveDismissDisabled(true)
                        .presentationDetents([.large])
                    }
            }
            .padding(.bottom, 40)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

//struct ページ_ブロック画面_Previews: PreviewProvider {
//    static var previews: some View {
//        ページ_ブロック画面()
//    }
//}
