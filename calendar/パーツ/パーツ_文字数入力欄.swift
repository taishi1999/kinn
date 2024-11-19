import SwiftUI
import Combine

struct パーツ_文字数入力欄: View {
    @FocusState private var isTextFieldFocused: Bool
    @Binding var value: Int
    @State private var showFilter: Bool = true
    private let maxLength = 4  // 最大桁数

    var body: some View {
        VStack {
            TextField("10", text: Binding(
                get: { String(value) },
                set: { newValue in
                    // 新しい値をテキストに設定
                    value = Int(newValue) ?? value
                }
            ))
            .keyboardType(.numberPad)
//            .textFieldStyle(RoundedBorderTextFieldStyle())
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
            .fixedSize()
            .frame(height: 32)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(UIColor { traitCollection in
                        return traitCollection.userInterfaceStyle == .dark ? .systemGray2 : .systemGray5
                    }), lineWidth: 1)
            )
            .focused($isTextFieldFocused)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完了") {
                        isTextFieldFocused = false
                        showFilter = true
                        if value < 10 {
                            value = 10
                        }
                    }
                }
            }
            .overlay(
                showFilter ? Color.black.opacity(0.001)
                    .onTapGesture {
                        isTextFieldFocused = true
                        showFilter = false
                    } : nil
            )
            // onReceiveで入力制限を設定
            .onReceive(Just(value), perform: { _ in
                let textString = String(value)  // 現在のテキストを文字列で取得
                if textString.count > maxLength {
                    value = Int(textString.prefix(maxLength)) ?? value  // 4桁に切り詰め
                }
            })
        }

    }
}

struct パーツ_文字数入力欄_Previews: PreviewProvider {
    @State static var text = 100  // プレビュー用に`Int`型の変数を用意

    static var previews: some View {
        パーツ_文字数入力欄(value: $text)
    }
}
