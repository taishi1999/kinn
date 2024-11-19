import SwiftUI

struct ページ_日記エディタ: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var bodyText: String = ""

    // 改行や空白を除いた文字数をカウント
    private var nonWhitespaceCharacterCount: Int {
        let trimmedText = bodyText.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
        return trimmedText.count
    }

    var saveAction: (() -> Void)?  // 保存処理を外部で管理するためのクロージャ

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // TextEditor
                TextViewWrapper(text: $bodyText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .border(Color.gray)
            }
            .padding(.horizontal)
            .navigationTitle(年付き日付フォーマット(Date(),詳しいフォーマット: true)) // 現在の日付をタイトルに設定
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("00000") {
                        saveDiary()
                        saveAction?()
                    }
                    //0文字の時に完了ボタン無効化する
                    //.disabled(nonWhitespaceCharacterCount == 0)
                }
            }

            // 右下に文字を表示
            VStack {
                Spacer()  // 上部をスペースで埋める
                HStack {
                    Spacer()  // 左側をスペースで埋める
                    Text("\(nonWhitespaceCharacterCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                }
            }
        }
    }

    private func saveDiary() {
        let newDiary = DiaryEntry(context: viewContext)
        newDiary.body = bodyText
        newDiary.createdAt = Date()

        do {
            try viewContext.save()
        } catch {
            print("Failed to save diary: \(error.localizedDescription)")
        }
    }
}
