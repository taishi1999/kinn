import SwiftUI
import WebKit
import MessageUI

struct ページ_設定: View {
    @ObservedObject var diaryTaskManager: DiaryTaskManager
    @State private var isShowingMailView = false
    @State private var isNotificationEnabled = false // 通知設定の状態を保持
//    @Binding var interval: TimeInterval

    private func formattedTime(_ date: Date) -> String {
           let formatter = DateFormatter()
           formatter.dateFormat = "MM/dd HH:mm"
           return formatter.string(from: date)
       }

    private func messageForNextEventLabel(_ label: String) -> String {
        switch label {
        case "start":
            return "開始まで"
        case "end":
            return "終了まで"
        default:
            return "予定がありません"
        }
    }

    var body: some View {
        NavigationStack{
            Form {
                Text(messageForNextEventLabel(diaryTaskManager.nextEventLabel))
                Text("残り時間: \(diaryTaskManager.interval, specifier: "%.0f") 秒")
                
//                Text("interval: \(interval), startTime: \(diaryTaskManager.diaryTask.startTime), timeIntervalSinceNow: \(diaryTaskManager.diaryTask.startTime.timeIntervalSinceNow)")
                // アカウント設定セクション
                Section(/*header: Text("アカウント設定")*/footer: Text("開始時間の1時間前に編集不可になります")
                    ) {
                    NavigationLink(destination: ページ_タスク作成_ver2(/*diaryTaskManager: diaryTaskManager*/)) {
                        Text("📖 日記の設定")
                    }
                    //開始1時間前、開始中の時は設定をブロック
//                    .disabled((diaryTaskManager.interval <= 3600 && diaryTaskManager.nextEventLabel == "start") || diaryTaskManager.nextEventLabel == "end")

                }

//                // アプリ設定セクション
//                Section(header: Text("アプリ設定")) {
//                    HStack {
//                        Text("通知設定")
//                        Spacer()
//                        Toggle("", isOn: $isNotificationEnabled)
//                            .labelsHidden() // Toggleのラベルを非表示
//                    }
//                    NavigationLink(destination: テーマ設定ページ()) {
//                        Text("テーマ設定")
//                    }
//                }

                // その他セクション
                Section(/*header: Text("その他")*/) {
                    Button("💭 気軽に意見を送ってください！") {

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

                    NavigationLink(destination: プライバシーポリシーページ()) {
                        Text("プライバシーポリシー")
                    }
//                    NavigationLink(destination: 利用規約ページ()) {
//                        Text("利用規約")
//                    }

                }
            }
            .sheet(isPresented: $isShowingMailView) {
                MailView(isShowing: $isShowingMailView)
            }
            .onAppear {
        
                        // 設定画面に戻ったときに interval を更新
//                        interval = max(0, diaryTaskManager.diaryTask.startTime.timeIntervalSinceNow)
//                print("interval: \(interval)")
                    }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)//            .navigationBarTitleDisplayMode(.inline)
//            .listStyle(GroupedListStyle())
        }
    }
}

// 各設定項目の詳細ページ（例）
struct プロフィール編集ページ: View {
    var body: some View {
        Text("プロフィール編集ページ")
            .navigationTitle("プロフィール編集")
    }
}

struct パスワード変更ページ: View {
    var body: some View {
        Text("パスワード変更ページ")
            .navigationTitle("パスワード変更")
    }
}

struct テーマ設定ページ: View {
    var body: some View {
        Text("テーマ設定ページ")
            .navigationTitle("テーマ設定")
    }
}

struct プライバシーポリシーページ: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionView(title: "1. 収集する情報", content: """
本アプリは、ユーザーのアカウント登録を必要とせず、日記データはすべて端末内に保存されます。
開発者を含む第三者がデータへアクセスすることはありません。
""")

                SectionView(title: "2. データの管理・削除", content: """
ユーザーはアプリを削除することで、すべてのデータを消去できます。
本アプリは、クラウド同期やバックアップ機能を提供していません。
""")

                SectionView(title: "3. サードパーティサービス", content: """
本アプリは、サードパーティの広告・解析ツールを使用していません。
""")

//                SectionView(title: "4. 問い合わせ", content: """
//本プライバシーポリシーに関するお問い合わせは、以下のメールアドレスまでご連絡ください。
//
//**contact@example.com**
//""")
            }
            .padding()
        }
        .navigationTitle("プライバシーポリシー")
//        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SectionView: View {
    var title: String
    var content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .bold()

            Text(content)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
}
struct 利用規約ページ: View {
    var body: some View {
        Text("利用規約")
            .navigationTitle("利用規約")
    }
}

struct お問い合わせページ: View {
    var body: some View {
        Text("お問い合わせ")
            .navigationTitle("お問い合わせ")
        //        .navigationBarTitleDisplayMode(.inline)

    }
}

//struct 設定ページ_Previews: PreviewProvider {
//    static var previews: some View {
//        ページ_設定()
//    }
//}
