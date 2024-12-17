import SwiftUI

struct パーツ_共通ボタン: View {
    var ボタンテキスト: String
    var isLoading: Bool = false
    var action: (() -> Void)?
    var generator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        Button(action: {
            generator.impactOccurred()
            action?()
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2) // サイズを拡大
                } else {
                    Text(ボタンテキスト)
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(Color.buttonOrange)
            .foregroundColor(.white)
            .fontWeight(.bold)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.6), radius: 12, x: 0, y: 4)
        }
        .disabled(isLoading)
//        .padding()
        .onAppear {
            generator.prepare()
        }
    }
}
struct パーツ_ボタン_ローディング: View {
    @Binding var isLoading: Bool
    var ボタンテキスト: String
    var action: (() -> Void)?

    var body: some View {
        パーツ_共通ボタン(
            ボタンテキスト: ボタンテキスト,
            isLoading: isLoading,
            action: {
                isLoading = true
                action?()
            }
        )
    }
}


//struct パーツ_ボタン_ローディング: View {
//    @Binding var isLoading: Bool // 外部からバインディングで受け取る
//    var ボタンテキスト: String
//    var action: (() -> Void)?    // ボタンが押された時に実行するクロージャ（nil許容）
//
//    var body: some View {
//        Button(action: {
//            print("Before updating isLoading: \(isLoading)") // デバッグ用
//            isLoading = true // ローディング状態を開始
//            print("After updating isLoading: \(isLoading)") // デバッグ用
//            action?() // クロージャが存在する場合のみ実行
//        }) {
//            HStack {
//                if isLoading {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle())
//                        .scaleEffect(1.2) // サイズを拡大
//                } else {
//                    Text(ボタンテキスト)
//                        .fontWeight(.bold)
//                }
//            }
//            .padding(.vertical, 14)
//            .frame(maxWidth: .infinity)
//            .background(Color.buttonOrange) // ボタンの背景色
//            .foregroundColor(.white)
//            .fontWeight(.bold)
//            .cornerRadius(12)
//            .shadow(color: Color.black.opacity(0.6), radius: 12, x: 0, y: 4)
//        }
//        .disabled(isLoading) // ローディング中は無効化
//        .padding()
//    }
//}

struct LoadingButton_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var isLoading = false // プレビュー専用の @State プロパティ

        var body: some View {
            VStack {


                パーツ_ボタン_ローディング(isLoading: $isLoading,ボタンテキスト: "完了", action: nil) // actionを指定しない場合
            }
            .onAppear {
                print("Preview started with isLoading: \(isLoading)")
            }
        }

        /// ボタンの処理を実行
        func performTask() {
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                DispatchQueue.main.async {
                    print("Task completed.")
                    isLoading = false
                }
            }
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}



//struct パーツ_ボタン_メイン: View {
//    var action: () -> Void
//    var ボタンテキスト: String // Bindingでテキストを受け取る
//    var generator = UIImpactFeedbackGenerator(style: .medium)
//
//    var body: some View {
//        Button(action: {
//            generator.impactOccurred()
//            action()
//        }) {
//            Text(ボタンテキスト) // 受け取った文字列を表示
//                .padding(.vertical, 14)
//                .frame(maxWidth: .infinity)
//                .background(Color.buttonOrange)
//                .foregroundColor(.white)
//                .fontWeight(.bold)
//                .cornerRadius(12)
//                .shadow(color: Color.black.opacity(0.6), radius: 12, x: 0, y: 4)
//        }
//        .onAppear {
//            generator.prepare()
//        }
//    }
//}

// 使用例
struct パーツ_ボタン_日記作成: View {
//    @Binding var フラグ_日記エディタ表示: Bool
    var action: () -> Void
    @Binding var startTime: Date
    @Binding var endTime: Date
    @Binding var repeatDays: [Int]


//    init(startTime: Binding<Date>, endTime: Binding<Date>, repeatDays: Binding<[Int]>/*, action: @escaping () -> Void*/) {
////        self._フラグ_日記エディタ表示 = フラグ_日記エディタ表示
//        self._startTime = startTime
//        self._endTime = endTime
//        self._repeatDays = repeatDays
////        self.action = action
//
//        // 初期値の出力
//        print("初期値 startTime: \(startTime.wrappedValue)")
//        print("初期値 endTime: \(endTime.wrappedValue)")
//        print("repeatDaysの初期値: \(repeatDays.wrappedValue)")
//    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "MM/dd"
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale(identifier: "ja_JP")
        weekdayFormatter.dateFormat = "E"
        let date = Date()
        let dayString = formatter.string(from: date)
        let weekdayString = weekdayFormatter.string(from: date).prefix(1)
        return "\(dayString)(\(weekdayString))"
    }

    private var startTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startTime)
    }

    private var endTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: endTime)
    }

    // 今日の曜日を含むか確認し、含まれない場合は次の曜日までの日数を計算
    private var nextAvailableDayMessage: String? {
        let calendar = Calendar.current
        let todayIndex = calendar.component(.weekday, from: Date()) - 1  // 日曜を0とする
        if repeatDays.contains(todayIndex) {
            return nil
        } else {
            // 次の曜日までの日数を計算
            let sortedDays = repeatDays.sorted()
            if let nextDay = sortedDays.first(where: { $0 > todayIndex }) ?? sortedDays.first {
                let daysUntilNext = (nextDay >= todayIndex) ? nextDay - todayIndex : (7 - todayIndex + nextDay)

                if daysUntilNext == 1 {
                    return "明日"
                } else {
                    return "\(daysUntilNext)日後"
                }
            }
            return nil
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(daysUntilNextAvailableDay >= 1 ? .gray/*.secondary*/ : .primary)
                if let message = nextAvailableDayMessage {
                    Text(message)
                }

                HStack(spacing: 1) {
                    Text(startTimeFormatted)
                    Text("-")
                    Text(endTimeFormatted)
                }
            }
            .font(.caption)
            .foregroundColor(daysUntilNextAvailableDay >= 1 ? /*.lightGray200*/.gray : .primary)
            .fontWeight(/*daysUntilNextAvailableDay >= 1 ? .regular :*/ .bold)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Color.darkButton_thin.opacity(0.8))
            //            .background(Color.black.opacity(0.8))
            .cornerRadius(.infinity)
            .padding(.bottom, 8)

            パーツ_共通ボタン(ボタンテキスト: "今日の日記を書く", action:action)
        }
    }

    // 次の曜日までの日数を計算するプロパティ
    private var daysUntilNextAvailableDay: Int {
        // `nextAvailableDayMessage`の内容から日数を取り出し、2日以上かどうかを確認
        if let message = nextAvailableDayMessage {
            if message == "明日" {
                return 1
            } else if let days = Int(message.replacingOccurrences(of: "日後", with: "")) {
                return days
            }
        }
        return 0 // 初期値として0を返す
    }
}

//struct パーツ_ボタン_日記作成_Previews: PreviewProvider {
//    static var previews: some View {
//        // プレビュー用の変数を設定
//        StatefulPreviewWrapper(false) { フラグ_日記エディタ表示 in
//            StatefulPreviewWrapper(Date()) { startTime in
//                StatefulPreviewWrapper(Calendar.current.date(byAdding: .hour, value: 1, to: Date())!) { endTime in
//                    StatefulPreviewWrapper([0, 1, 2]) { repeatDays in // repeatDaysも追加
//                        パーツ_ボタン_日記作成(
////                            フラグ_日記エディタ表示: フラグ_日記エディタ表示,
//                            startTime: startTime,
//                            endTime: endTime,
//                            repeatDays: repeatDays
//                        ) {
//                            print("アクションが実行されました")
//                        }
//                        .previewLayout(.sizeThatFits) // プレビューのレイアウトを指定
//                        .padding() // 見やすいようにパディングを追加
//                        .background(Color.gray) // 背景色を設定
//                    }
//                }
//            }
//        }
//    }
//}


// プレビュー用のStatefulラッパー
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    let content: (Binding<Value>) -> Content

    init(_ value: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
