import SwiftUI
import CoreData
import UIKit

// UITextView のカスタムクラス
class CustomTextView: UITextView, UITextViewDelegate {
    var onTextChanged: ((String) -> Void)?

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.delegate = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
    }

    // テキストが変更されたときにバインディングされた値を更新
    func textViewDidChange(_ textView: UITextView) {
        onTextChanged?(textView.text)
    }

    // コピー、ペースト、カットなどのメニューを無効化
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

// SwiftUI 用に UIViewRepresentable を使用してカスタム UITextView をラップ
struct TextViewWrapper: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> CustomTextView {
        let textView = CustomTextView()
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 18)

        // UITextView からのテキスト変更を反映
        textView.onTextChanged = { newText in
            text = newText
        }

        // オートフォーカスを有効にする
        DispatchQueue.main.async {
            textView.becomeFirstResponder()  // 自動でフォーカス
        }

        return textView
    }

    func updateUIView(_ uiView: CustomTextView, context: Context) {
        uiView.text = text
    }
}

struct InterfaceTestView: View {
    private var safeAreaInsets: UIEdgeInsets {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first?.safeAreaInsets ?? .zero
    }

    var body: some View {
        GeometryReader { geometry in
            Color.gray
            VStack {
                Text("画面サイズ")
                Text("幅：\(UIScreen.main.bounds.width) 高さ：\(UIScreen.main.bounds.height)")

                Text("SafeArea")
                Text("上：\(safeAreaInsets.top)")
                Text("下：\(safeAreaInsets.bottom)")
                Text("左：\(safeAreaInsets.left)")
                Text("右：\(safeAreaInsets.right)")

                Text("SafeAresサイズ（黄色部分）")
                Text("幅：\(geometry.size.width) 高さ：\(geometry.size.height)")
            }
        }
    }
}

struct InterfaceTestView_Previews: PreviewProvider {
    static var previews: some View {
        InterfaceTestView()
    }
}


//---------
//リンクに色つける試行錯誤▲
//struct LinkTextView: UIViewRepresentable {
//    @Binding var text: String
//
//    func makeUIView(context: Context) -> UITextView {
//        let textView = UITextView()
//        textView.isEditable = true  // 編集可能に設定
//        textView.isSelectable = true  // 選択可能に設定
//        textView.dataDetectorTypes = []  // 自動リンク検出は無効化してカスタムリンクを設定
//        textView.delegate = context.coordinator
//
//        // Attributed Textの設定
//        let attributedString = NSMutableAttributedString(string: text)
//
//        // "Here is a link:"の範囲を取得して通常の色を設定
//        let plainTextRange = (text as NSString).range(of: "Here is a link:")
//        attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: plainTextRange)
//
//        // リンク文字列の範囲を取得し、NSRangeに変換してリンクを設定
//        if let range = text.range(of: "https://www.apple.com") {
//            let nsRange = NSRange(range, in: text)
//            attributedString.addAttribute(.link, value: "https://www.apple.com", range: nsRange)
//            attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: nsRange)  // リンクの色を青色に設定
//        }
//
//        textView.attributedText = attributedString
//        return textView
//    }
//
//    func updateUIView(_ uiView: UITextView, context: Context) {
//        // Attributed Textを再設定
//        let attributedString = NSMutableAttributedString(string: text)
//
//        // "Here is a link:"の範囲を取得して通常の色を設定
//        let plainTextRange = (text as NSString).range(of: "Here is a link:")
//        attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: plainTextRange)
//
//        // リンク文字列の範囲を取得し、リンクを再設定
//        if let range = text.range(of: "https://www.apple.com") {
//            let nsRange = NSRange(range, in: text)
//            attributedString.addAttribute(.link, value: "https://www.apple.com", range: nsRange)
//            attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: nsRange)  // リンクの色を青色に設定
//        }
//
//        uiView.attributedText = attributedString
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(self)
//    }
//
//    class Coordinator: NSObject, UITextViewDelegate {
//        var parent: LinkTextView
//
//        init(_ parent: LinkTextView) {
//            self.parent = parent
//        }
//
//        // カーソルの位置が変更された際に呼び出されるメソッド
//        func textViewDidChangeSelection(_ textView: UITextView) {
//            let cursorPosition = textView.selectedRange.location
//
//            // カーソルがリンク部分にあるかどうかをチェック
//            if cursorPosition > 0, cursorPosition <= textView.attributedText.length {
//                let attributes = textView.attributedText.attributes(at: cursorPosition - 1, effectiveRange: nil)
//
//                if attributes[.link] != nil {
//                    // カーソルがリンク内にある場合
//                    print("in")
//                    textView.text = "in"
//                } else {
//                    // リンク外にカーソルがある場合
//                    print("out")
//                    textView.text = "out"
//                }
//            } else {
//                // テキスト範囲外の時も out と表示
//                print("out")
//                textView.text = "out"
//            }
//        }
//    }
//}
//
//struct LinkTextView_Preview: PreviewProvider {
//    @State static var text = "Here is a link: https://www.apple.com"
//
//    static var previews: some View {
//        LinkTextView(text: $text)
//    }
//}

//-----
//// UITextViewをSwiftUIで使用するためのラッパー
//struct ClickableTextView: UIViewRepresentable {
//    class Coordinator: NSObject, UITextViewDelegate {
//        var parent: ClickableTextView
//
//        init(_ parent: ClickableTextView) {
//            self.parent = parent
//        }
//
//        // リンクをタップしたときに呼び出される
//        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//            // リンクがタップされたらtrueを返す（遷移を許可）
//            return true
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIView(context: Context) -> UITextView {
//        let textView = UITextView()
//        textView.isEditable = true // 編集不可
//        textView.isScrollEnabled = true // スクロール可能
//        textView.delegate = context.coordinator // デリゲート設定
//
//        // 通常の文字列
//        let text = "この部分の色を変えたい！そしてここも。"
//
//        // NSAttributedStringの作成
//        let attributedString = NSMutableAttributedString(string: text)
//
//        // デフォルトの文字色をprimaryカラーに設定
//        let primaryColor = UIColor.label
//        attributedString.addAttribute(.foregroundColor, value: primaryColor, range: NSRange(location: 0, length: text.count))
//
//        // 色を変更したい部分の範囲
//        let firstRange = (text as NSString).range(of: "この部分")
//        let secondRange = (text as NSString).range(of: "ここも")
//
//        // "この部分"を赤色にしてリンクを追加
//        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: firstRange)
//        attributedString.addAttribute(.link, value: "https://www.apple.com", range: firstRange)
//
//        // "ここも"を青色に
//        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: secondRange)
//
//        // UITextViewに設定
//        textView.attributedText = attributedString
//
//        // リンクをタップ可能にする
//        textView.isUserInteractionEnabled = true
//        textView.isSelectable = true
////        textView.isEditable = false
//        textView.dataDetectorTypes = [.link] // リンクを自動検出
//
//        return textView
//    }
//
//    func updateUIView(_ uiView: UITextView, context: Context) {
//        // 必要に応じて更新処理
//    }
//}
//
//// SwiftUIプレビューで表示
//struct ClickableTextView_Previews: PreviewProvider {
//    static var previews: some View {
//        ClickableTextView()
//            .frame(height: 200)
//    }
//}
//

