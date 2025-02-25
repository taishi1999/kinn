//設定用
import SwiftUI
import Combine
//Button {
//    isPresented = true
//} label: {
//    HStack {
//        Text("ブロックするアプリ")
//            .foregroundColor(.primary)
//        Spacer()
//        Text("選択")
//            .foregroundColor(Color(.gray))
//        Image(systemName: "chevron.down")
//            .font(.system(size: 16, weight: .medium))
//            .fontWeight(.regular)
//            .foregroundColor(Color(.systemGray2))
//            .frame(width: 20, height: 20)
//    }
//    .padding(.vertical,8)
//}
//.familyActivityPicker(
//    isPresented: $isPresented,
//    selection: $selection
//)
struct パーツ_文字数入力欄_v2: View {
    @Binding var characterCount: Int
    @FocusState private var isFocused: Bool

    var body: some View {
        Button{
            isFocused = true
        } label: {
            HStack(spacing: 4) {
                Text("文字数")
                    .foregroundColor(.primary)
                Spacer()
                TextField(
                    "1",
                    text: Binding<String>(
                        get: { String(characterCount) },
                        set: { characterCount = Int($0.prefix(4)) ?? 0 }
                    )
                )
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button(action: {
                                    isFocused = false
                                }) {
                                    Text("完了")
                                        .font(.system(size: 16, weight: .bold))
                                }
                    }
                }
                .keyboardType(.numberPad) // 数字入力専用のキーボードを設定
                .fixedSize()
                .font(.callout)
                .focused($isFocused) // フォーカスの状態をバインド

                Text("文字")
                    .font(.callout) // Callout サイズ
                    .foregroundColor(.secondary)
//                    .padding(.vertical, 6)
            }
            .padding(.vertical,8)
        }
    }
}

struct パーツ_文字数入力欄: View {
    @FocusState private var isTextFieldFocused: Bool
    @Binding var value: Int
    @State private var showFilter: Bool = true
    private let maxLength = 4  // 最大桁数

    var body: some View {
        VStack {
            TextField("1", text: Binding(
                get: { String(value) },
//                set: { newValue in
//                    // 新しい値をテキストに設定
//                    value = Int(newValue) ?? value
//                }
                set: {
                    value = Int($0.prefix(maxLength)) ?? 0
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
//                        dismiss()
                        isTextFieldFocused = false
//                        showFilter = true
//                        if value < 10 {
//                            value = 10
//                        }
                    }
                }
            }
            // onReceiveで入力制限を設定
//            .onReceive(Just(value), perform: { _ in
//                let textString = String(value)  // 現在のテキストを文字列で取得
//                if textString.count > maxLength {
//                    value = Int(textString.prefix(maxLength)) ?? value  // 4桁に切り詰め
//                }
//            })
        }
    }
}

struct パーツ_文字数入力欄_Previews: PreviewProvider {
    @State static var text = 100  // プレビュー用に`Int`型の変数を用意

    static var previews: some View {
        パーツ_文字数入力欄(value: $text)
    }
}

//オンボーディング用
import UIKit

struct CharacterCountTextField: UIViewRepresentable {
    @Binding var text: String
    var characterLimit: Int
    var focusOnAppear: Bool // フォーカス設定

    func makeUIView(context: Context) -> NoPasteTextField {
        let textField = NoPasteTextField()
        textField.delegate = context.coordinator
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        textField.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        
        textField.layer.borderColor = UIColor.gray.cgColor // ボーダーの色
            textField.layer.borderWidth = 1.0 // ボーダーの幅
            textField.layer.cornerRadius = 8.0 // ボーダーの角を丸くする（必要に応じて設定）
        // ツールバー
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: context.coordinator, action: #selector(context.coordinator.dismissKeyboard))
//        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        toolbar.items = [flexibleSpace, doneButton]
//        textField.inputAccessoryView = toolbar

        DispatchQueue.main.async {
            if focusOnAppear {
                textField.becomeFirstResponder() // フォーカスを設定
            }
        }

        return textField
    }

    func updateUIView(_ uiView: NoPasteTextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, characterLimit: characterLimit)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CharacterCountTextField
        var characterLimit: Int

        init(_ parent: CharacterCountTextField, characterLimit: Int) {
            self.parent = parent
            self.characterLimit = characterLimit
        }

        @objc func dismissKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)

            if prospectiveText.isEmpty || prospectiveText.count <= characterLimit {
                if prospectiveText == "0" {
                    DispatchQueue.main.async {
                        self.parent.text = "1"
                        textField.text = "1"
                    }
                    return false
                }
                parent.text = prospectiveText
                return true
            }
            return false
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.parent.text = textField.text ?? ""
            }
        }
    }
}

class NoPasteTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return false // ペーストを無効化
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
