import SwiftUI

struct ConfirmationDialogExample: View {
    @State private var isDialogVisible = false

    var body: some View {
        VStack {
            Button("ダイアログを開く") {
                isDialogVisible = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .confirmationDialog(
            "", // タイトルを空にする
            isPresented: $isDialogVisible,
            titleVisibility: .hidden // タイトルを完全に非表示
        ) {
            Button("設定をオフにする", role: .destructive) {
                print("Option 1 selected")
            }

//            Button("Option 2") { print("Option 2 selected") }
            Button("キャンセル", role: .cancel) { }
        }
    }
}

// プレビュー
struct ConfirmationDialogExample_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationDialogExample()
    }
}
