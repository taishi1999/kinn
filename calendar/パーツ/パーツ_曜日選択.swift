//import SwiftUI
//
//struct パーツ_曜日選択ビュー: View {
//    @Binding var 繰り返し曜日: [Int]
//
//    // 日曜日から始まる曜日のリストを生成
//    private var 曜日: [String] {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "ja_JP") // 日本語ロケール
//        formatter.dateFormat = "EEE"
//        let calendar = Calendar.current
//
//        // 日曜日を起点とする曜日リスト
//        let 日曜日 = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
//        return (0..<7).map { offset in
//            guard let 日付 = calendar.date(byAdding: .day, value: offset, to: 日曜日) else { return "" }
//            return formatter.string(from: 日付) // 曜日を文字列で取得
//        }
//    }
//
//    var body: some View {
//        Section {
//            HStack {
//                ForEach(Array(曜日.enumerated()), id: \.offset) { index, 曜日 in
//                    Text(曜日)
//                        .frame(width: 40, height: 40)
//                        .background(self.繰り返し曜日.contains(index) ? Color.primary : Color.clear)
//                        .foregroundColor(self.繰り返し曜日.contains(index) ? Color(.systemBackground) : Color(.systemGray))
//                        .fontWeight(self.繰り返し曜日.contains(index) ? .bold : .regular)
//                        .cornerRadius(20)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 20)
//                                .stroke(Color(.tertiarySystemFill), lineWidth: 2)
//                        )
//                        .onTapGesture {
//                            if let existIndex = self.繰り返し曜日.firstIndex(of: index) {
//                                self.繰り返し曜日.remove(at: existIndex)  // インデックスを配列から削除
//                            } else {
//                                self.繰り返し曜日.append(index)  // インデックスを配列に追加
//                            }
//                        }
//                }
//            }
//            .padding(.vertical)
//            .frame(maxWidth: .infinity)
//        }
//    }
//}

import SwiftUI

struct パーツ_曜日選択ビュー: View {
    @Binding var 繰り返し曜日: [String]

    // 英語表記の曜日リストを生成
    private var 曜日英語: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US") // 英語ロケール
        formatter.dateFormat = "EEE"
        let calendar = Calendar.current

        // 日曜日を起点とする曜日リスト
        let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return (0..<7).map { offset in
            guard let 日付 = calendar.date(byAdding: .day, value: offset, to: sunday) else { return "" }
            return formatter.string(from: 日付) // 英語の曜日を文字列で取得
        }
    }

    // 日本語表記の曜日リスト
    private var 曜日日本語: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP") // 日本語ロケール
        formatter.dateFormat = "EEE"
        let calendar = Calendar.current

        // 日曜日を起点とする曜日リスト
        let 日曜日 = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return (0..<7).map { offset in
            guard let 日付 = calendar.date(byAdding: .day, value: offset, to: 日曜日) else { return "" }
            return formatter.string(from: 日付) // 日本語の曜日を文字列で取得
        }
    }

    var body: some View {
        Section {
            HStack {
                ForEach(Array(zip(曜日英語, 曜日日本語)), id: \.0) { (eng, jpn) in
                    Text(jpn)
                        .frame(width: 40, height: 40)
                        .background(self.繰り返し曜日.contains(eng) ? Color.primary : Color.clear)
                        .foregroundColor(self.繰り返し曜日.contains(eng) ? Color(.systemBackground) : Color(.systemGray))
                        .fontWeight(self.繰り返し曜日.contains(eng) ? .bold : .regular)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(.tertiarySystemFill), lineWidth: 2)
                        )
                        .onTapGesture {
                            if let existIndex = self.繰り返し曜日.firstIndex(of: eng) {
                                self.繰り返し曜日.remove(at: existIndex)  // 英語表記の曜日を配列から削除
                            } else {
                                self.繰り返し曜日.append(eng)
                                self.繰り返し曜日.sort { 曜日英語.firstIndex(of: $0)! < 曜日英語.firstIndex(of: $1)! }
                            }
                        }
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
        }
    }
}
