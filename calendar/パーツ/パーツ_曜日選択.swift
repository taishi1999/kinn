import SwiftUI

struct パーツ_曜日選択ビュー: View {
    @Binding var 繰り返し曜日: [Int]

    private var 曜日: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP") // 日本語ロケール
        formatter.dateFormat = "EEE"
        let calendar = Calendar.current
        let 今日 = calendar.startOfDay(for: Date()) // 今日の日付の開始時間
        return (0..<7).map { offset in
            guard let 日付 = calendar.date(byAdding: .day, value: offset, to: 今日) else { return "" }
            return formatter.string(from: 日付) // 曜日を文字列で取得
        }
    }

    var body: some View {
        Section {
            HStack {
                ForEach(Array(曜日.enumerated()), id: \.offset) { インデックス, 曜日 in
                    Text(曜日)
                        .frame(width: 40, height: 40)
                        .background(self.繰り返し曜日.contains(インデックス) ? Color.primary : Color.clear)
                        .foregroundColor(self.繰り返し曜日.contains(インデックス) ? Color(.systemBackground) : Color(.systemGray))
                        .fontWeight(self.繰り返し曜日.contains(インデックス) ? .bold : .regular)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(.tertiarySystemFill), lineWidth: 2)
                        )
                        .onTapGesture {
                            if let 既存のインデックス = self.繰り返し曜日.firstIndex(of: インデックス) {
                                self.繰り返し曜日.remove(at: 既存のインデックス)  // インデックスを配列から削除
                            } else {
                                self.繰り返し曜日.append(インデックス)  // インデックスを配列に追加
                            }
                        }
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
        }
    }
}
