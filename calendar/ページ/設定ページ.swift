import SwiftUI

struct 設定ページ: View {
    @State private var isNotificationEnabled = false // 通知設定の状態を保持

    var body: some View {
        NavigationView {
            List {
                // アカウント設定セクション
                Section(header: Text("アカウント設定")) {
                    NavigationLink(destination: プロフィール編集ページ()) {
                        Text("ブロックの設定")
                    }
                    
                }

                // アプリ設定セクション
                Section(header: Text("アプリ設定")) {
                    HStack {
                        Text("通知設定")
                        Spacer()
                        Toggle("", isOn: $isNotificationEnabled)
                            .labelsHidden() // Toggleのラベルを非表示
                    }
                    NavigationLink(destination: テーマ設定ページ()) {
                        Text("テーマ設定")
                    }
                }

                // その他セクション
                Section(header: Text("その他")) {
                    NavigationLink(destination: プライバシーポリシーページ()) {
                        Text("プライバシーポリシー")
                    }
                    NavigationLink(destination: 利用規約ページ()) {
                        Text("利用規約")
                    }
                    NavigationLink(destination: お問い合わせページ()) {
                        Text("お問い合わせ")
                    }
                }
            }
            .navigationTitle("設定")
            .listStyle(GroupedListStyle())
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
        Text("プライバシーポリシー")
            .navigationTitle("プライバシーポリシー")
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
    }
}

struct 設定ページ_Previews: PreviewProvider {
    static var previews: some View {
        設定ページ()
    }
}
