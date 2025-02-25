import SwiftUI

struct ページ_フィードバック: View {
    @State private var feedbackText: String = ""
    @State private var isLoading: Bool = false
    @State private var isDisabled: Bool = true

    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
//            Text("気軽に意見を送ってください！")
//                .font(.callout)
//                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
//                .foregroundColor(.secondary)
            ZStack(alignment: .topLeading){

                TextEditor(text: $feedbackText)
                    .frame(height: 150)
                //                .padding()
                //                .background(Color(UIColor.systemGray6))
                //                .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5)))
                    .onChange(of: feedbackText) { newValue in
                        isDisabled = newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    }

                Text("気軽に意見を送ってください！")
                               .opacity(feedbackText.isEmpty ? 0.3 : 0.0)
                               .padding(.init(top: 9, leading: 8, bottom: 0, trailing: 0))
                               .allowsHitTesting(false)
            }

            パーツ_ボタン_ローディング(
                isLoading: $isLoading,
                isDisabled: isDisabled,
                ボタンテキスト: "送信",
                action: {
                    isLoading = true
                    sendFeedback()
                }
            )

            Spacer()
        }
        .padding()
        .navigationTitle("フィードバックを送る")
    }

    private func sendFeedback() {
        // 送信処理（仮）
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            feedbackText = "" // 送信後にクリア
            isDisabled = true
        }
    }
}

struct フィードバックページ_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ページ_フィードバック()
        }
    }
}
