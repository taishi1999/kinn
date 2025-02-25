import SwiftUI
import WebKit
import MessageUI

struct SettingsView: View {
    @State private var showTerms = false
    @State private var showPrivacy = false
    @State private var isShowingMailView = false

    var body: some View {
        NavigationStack{
            Form{

                    Section {
                        
                            Button(action: {
                                showTerms = true
                            }) {
                                Text("📖 日記の設定")
                                    .foregroundColor(.primary)
                            }
                        }

                Section {
                    // メール送信ボタン
                    Button("💭 気軽に感想を送ってください！") {
                        if MFMailComposeViewController.canSendMail() {
                            isShowingMailView = true
                        } else {
                            // メールアドレスをエンコード
                            let email = "app.continote@gmail.com"
                            let subject = "フィードバック"
                            let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

                            let urlString = "mailto:\(email)?subject=\(encodedSubject)"

                            if let emailURL = URL(string: urlString) {
                                DispatchQueue.main.async {
                                    UIApplication.shared.open(emailURL) { success in
                                        if !success {
                                            // エラーハンドリング
                                            print("メールアプリを開けませんでした")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .foregroundColor(.primary)

                    Button("プライバシーポリシー") {
                        showPrivacy = true
                    }
                    .foregroundColor(.primary)
                }
            }

        }
        .sheet(isPresented: $isShowingMailView) {
            MailView(isShowing: $isShowingMailView)
        }
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
//        .sheet(isPresented: $showTerms) {
//            WebViewContainer(urlString: "https://github.co.jp/")
//        }
//        .sheet(isPresented: $showPrivacy) {
//            WebViewContainer(urlString: "https://github.co.jp/")
//        }


    }
}

#Preview {
    SettingsView()
}

struct WebViewContainer: View {
    let urlString: String

    var body: some View {
        WebView(urlString: urlString)
            .edgesIgnoringSafeArea(.bottom)
    }
}

struct WebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

// Mail
struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator

        // メールの初期設定
        vc.setToRecipients(["app.continote@gmail.com"])
        vc.setSubject("フィードバック")
        vc.setMessageBody("", isHTML: false)

        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(isShowing: $isShowing)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool

        init(isShowing: Binding<Bool>) {
            _isShowing = isShowing
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            isShowing = false
        }
    }
}

