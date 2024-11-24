import SwiftUI

class モデル_タイマー管理: ObservableObject {
    @Published var currentMessage: String = ""
    @Published var timeRemaining: String = ""

    private var timer: Timer?

    func startChecking(targetDate: Date, onTimerComplete: @escaping () -> Void) {
        stopChecking() // 既存のタイマーをクリア
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let now = Date()

            // カウントダウン更新
            self.timeRemaining = self.calculateTimeRemaining(from: now, to: targetDate)

            // 時間が一致した場合の処理
            if self.isDate(now, equalTo: targetDate, toGranularity: .second) {
                self.currentMessage = "指定された日時になりました！"
                self.stopChecking()
                onTimerComplete() // タイマー終了時のコールバックを呼び出し
            }
        }
    }

    func stopChecking() {
        timer?.invalidate()
        timer = nil
    }

    private func calculateTimeRemaining(from now: Date, to targetDate: Date) -> String {
        let difference = Calendar.current.dateComponents([.hour, .minute, .second], from: now, to: targetDate)
        if let hour = difference.hour, let minute = difference.minute, let second = difference.second {
            return "\(hour)時間 \(minute)分 \(second)秒"
        } else {
            return "計算できません"
        }
    }

    private func isDate(_ now: Date, equalTo targetDate: Date, toGranularity granularity: Calendar.Component) -> Bool {
        return Calendar.current.compare(now, to: targetDate, toGranularity: granularity) == .orderedSame
    }
}

struct DateFormatterUtility {
    static func formattedDate(_ date: Date, locale: Locale = Locale(identifier: "ja_JP")) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        formatter.locale = locale
        return formatter.string(from: date)
    }
}

struct DateCheckerView: View {
    @ObservedObject var viewModel: モデル_スケジュール管理
    @StateObject private var timerManager = モデル_タイマー管理()
    @State private var isFullScreenPresented = false

    init(startTime_date: Date, endTime_date: Date, repeatDays: [Int]) {
        let viewModel = モデル_スケジュール管理(
            startTime_date: startTime_date,
            endTime_date: endTime_date,
            repeatDays: repeatDays
        )

        self.viewModel = viewModel
//        initializeState()
    }

    /// 初期化と onAppear で共通する処理
        private func initializeState() {
            viewModel.findNextEvent()
            updateFullScreenState()
        }

        /// フルスクリーンの状態を更新する
        private func updateFullScreenState() {
            if viewModel.nextEvent?.type == .end {
                print("次はendなのでブロック中です\(String(describing: viewModel.nextEvent?.date))")
                isFullScreenPresented = true
            } else {
                print("次はstartなので待機中です\(String(describing: viewModel.nextEvent?.date))")
                isFullScreenPresented = false
            }
        }

    /// 再帰的にタイマーを実行するメソッド
    private func startCheckingLoop() {
        if viewModel.nextEvent == nil {
            print("nilなのよー")
                initializeState()
            }

        timerManager.startChecking(targetDate: viewModel.nextEvent?.date ?? Date()) {
            // 次のイベントを再計算して再度タイマーを開始
            initializeState()
            startCheckingLoop() // 再帰的に次のタイマーを開始
        }
    }

    var body: some View {
        VStack {
            Text("現在の時刻: \(DateFormatterUtility.formattedDate(Date()))")
                .font(.headline)
                .padding()

            Text("指定された日時: \(DateFormatterUtility.formattedDate(viewModel.nextEvent?.date ?? Date()))")
                .font(.headline)
                .padding()

            if !timerManager.timeRemaining.isEmpty {
                Text("残り時間: \(timerManager.timeRemaining)")
                    .font(.title)
                    .foregroundColor(.blue)
            }

            if !timerManager.currentMessage.isEmpty {
                Text(timerManager.currentMessage)
                    .font(.largeTitle)
                    .foregroundColor(.red)
                    .bold()
            }
        }
        .onAppear {
            startCheckingLoop()
//            initializeState()
//
//            timerManager.startChecking(targetDate: viewModel.nextEvent?.date ?? Date()) {
//                initializeState()
//            }
        }
        .fullScreenCover(isPresented: $isFullScreenPresented) {
            FullScreenView()
        }
    }
}

struct DateCheckerView_Previews: PreviewProvider {
    static var previews: some View {
        let calendar = Calendar.current
        let now = Date()

        let startTime_date = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: now)!
        let endTime_date = calendar.date(bySettingHour: 11, minute: 59, second: 0, of: calendar.date(byAdding: .day, value: 0, to: now)!)!

        return DateCheckerView(
            startTime_date: startTime_date,
            endTime_date: endTime_date,
            repeatDays: [0, 1, 2, 3, 4, 5, 6]
        )
    }
}

struct FullScreenView: View {
    var body: some View {
        VStack {
            Text("ブロック中")
                .font(.largeTitle)
                .padding()

            Button("閉じる") {
                // 閉じる処理を実装
            }
        }
    }
}

//struct DateCheckerView_Previews: PreviewProvider {
//    static var previews: some View {
//        let calendar = Calendar.current
//        let now = Date()
//
//        // DateEditorViewModel の初期化
//        let startTime_date = calendar.date(bySettingHour: 11, minute: 30, second: 0, of: now)!
//        let endTime_date = calendar.date(bySettingHour: 11, minute: 31, second: 0, of: calendar.date(byAdding: .day, value: 0, to: now)!)!
//
//        let viewModel = モデル_スケジュール管理(
//            startTime_date: startTime_date,
//            endTime_date: endTime_date,
//            repeatDays: [0, 1, 2, 3, 4, 5, 6] // 日曜, 月曜, 火曜, 水曜, 木曜, 金曜, 土曜
//        )
//
//        // 次のイベントを計算
//        viewModel.findNextEvent()
//
//        return DateCheckerView(viewModel: viewModel)
//    }
//}

class モデル_スケジュール管理: ObservableObject {
    let startTime_date: Date
    let endTime_date: Date
    let repeatDays: [Int] // 曜日の番号 (日曜: 0 ～ 土曜: 6)

    enum NextEventType {
        case start
        case end
    }

    struct NextEventdata {
        let date: Date
        let type: NextEventType
    }

    @Published var nextEvent: NextEventdata?

    init(startTime_date: Date, endTime_date: Date, repeatDays: [Int]) {
        self.startTime_date = startTime_date
        self.endTime_date = endTime_date
        self.repeatDays = repeatDays
    }

    func findNextEvent() {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let yesterdayWeekday = calendar.component(.weekday, from: yesterday) - 1 // 日曜を0とするための-1

        let daysDifference = calendar.dateComponents([.day], from: calendar.startOfDay(for: startTime_date), to: calendar.startOfDay(for: endTime_date)).day ?? 0

        //昨日から今日の来週
        for i in 0...8 {
            let targetWeekday = (yesterdayWeekday + i) % 7
            if repeatDays.contains(targetWeekday) {
                if targetWeekday == yesterdayWeekday {
                    let startTime = calendar.date(bySettingHour: calendar.component(.hour, from: startTime_date),
                                                  minute: calendar.component(.minute, from: startTime_date),
                                                  second: 0,
                                                  of: yesterday)!

                    let adjustedYesterday = calendar.date(byAdding: .day, value: daysDifference, to: yesterday)!
                    let endTime = calendar.date(bySettingHour: calendar.component(.hour, from: endTime_date),
                                                minute: calendar.component(.minute, from: endTime_date),
                                                second: 0,
                                                of: adjustedYesterday)!

                    if now < startTime {
                        nextEvent = NextEventdata(date: startTime, type: .start)
                        return
                    } else if now < endTime {
                        nextEvent = NextEventdata(date: endTime, type: .end)
                        return
                    }
                } else {
                    if let baseDate = calendar.nextDate(after: yesterday, matching: DateComponents(weekday: targetWeekday + 1), matchingPolicy: .nextTime) {
                        let startTime = calendar.date(bySettingHour: calendar.component(.hour, from: startTime_date),
                                                      minute: calendar.component(.minute, from: startTime_date),
                                                      second: 0,
                                                      of: baseDate)!

                        let adjustedBaseDate = calendar.date(byAdding: .day, value: daysDifference, to: baseDate)!
                        let endTime = calendar.date(bySettingHour: calendar.component(.hour, from: endTime_date),
                                                    minute: calendar.component(.minute, from: endTime_date),
                                                    second: 0,
                                                    of: adjustedBaseDate)!

                        if now < startTime {
                            nextEvent = NextEventdata(date: startTime, type: .start)
                            return
                        } else if now < endTime {
                            nextEvent = NextEventdata(date: endTime, type: .end)
                            return
                        }
                    }
                }
            }
        }
    }
}

//struct DateEditorView: View {
//    @StateObject var viewModel: DateEditorViewModel
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("starttime: \(viewModel.startTime_date)")
//            Text("endtime: \(viewModel.endTime_date)")
//            Text("指定された繰り返し日: \(viewModel.repeatDays.map { "\($0)" }.joined(separator: ", "))")
//                .font(.headline)
//
//            if let nextEvent = viewModel.nextEvent {
//                Text("次のイベント: \(formattedDate(nextEvent.date)) (\(nextEvent.type == .start ? "開始" : "終了"))")
//                    .font(.headline)
//                    .foregroundColor(.blue)
//            }
//        }
//        .padding()
//        .onAppear {
//            viewModel.findNextEvent()
//        }
//    }
//
//    private func formattedDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .full
//        formatter.timeStyle = .short
//        formatter.locale = Locale(identifier: "ja_JP") // 日本語表記
//        return formatter.string(from: date)
//    }
//}
//
//struct DateEditorView_Previews: PreviewProvider {
//    static var previews: some View {
//        let calendar = Calendar.current
//        let today = Date()
//
//        let startTime_date = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: today)!
//        let endTime_date = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: today)!)!
//
//        let viewModel = DateEditorViewModel(
//            startTime_date: startTime_date,
//            endTime_date: endTime_date,
//            repeatDays: [0, 1, 2, 3, 4, 5, 6] // 日曜, 月曜, 火曜, 水曜, 木曜, 金曜, 土曜
//        )
//
//        return DateEditorView(viewModel: viewModel)
//    }
//}


//--- ↓昨日から六日間のdatesを取得後にcheckNextEvent()次の予定を取得するパターン
//    (onappearでcheckNextEvent()を実行) datesをforeachで表示可能

//            ForEach(updatedDates, id: \.startTime) { datePair in
//                VStack(alignment: .leading) {
//                    Text("開始日: \(formattedDate(datePair.startTime))")
//                    Text("終了日: \(formattedDate(datePair.endTime))")
//                }
//                .padding(.bottom)
//            }

//    private func checkNextEvent() {
//        let now = Date()
//        for datePair in updatedDates {
//            if now < datePair.startTime {
//                nextEvent = NextEventdata(date: datePair.startTime, type: .start)
//                break
//            } else if now < datePair.endTime {
//                nextEvent = NextEventdata(date: datePair.endTime, type: .end)
//                break
//            }
//        }
//    }

//    private var updatedDates: [(startTime: Date, endTime: Date)] {
//        let calendar = Calendar.current
//        var dates: [(startTime: Date, endTime: Date)] = []
//
//        let today = calendar.startOfDay(for: Date())
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
//        let yesterdayWeekday = calendar.component(.weekday, from: yesterday) - 1 // 日曜を0とする
//
//        // `endTime_date` が `startTime_date` に比べて何日後か計算
//        let daysDifference = calendar.dateComponents([.day], from: calendar.startOfDay(for: startTime_date), to: calendar.startOfDay(for: endTime_date)).day ?? 0
//
//        for i in 0...6 {
//            let targetWeekday = (yesterdayWeekday + i) % 7
//            if repeatDays.contains(targetWeekday) {
//                if targetWeekday == yesterdayWeekday {
//                    // 昨日の日付を直接使用（startTime_dateとの差分を足す）
//                    let startTime = calendar.date(bySettingHour: calendar.component(.hour, from: startTime_date),
//                                                  minute: calendar.component(.minute, from: startTime_date),
//                                                  second: 0,
//                                                  of: yesterday)!
//
//                    let adjustedYesterday = calendar.date(byAdding: .day, value: daysDifference, to: yesterday)!
//                    let endTime = calendar.date(bySettingHour: calendar.component(.hour, from: endTime_date),
//                                                minute: calendar.component(.minute, from: endTime_date),
//                                                second: 0,
//                                                of: adjustedYesterday)!
//
//                    dates.append((startTime, endTime))
//                } else {
//                    // 次回の曜日を取得
//                    if let baseDate = calendar.nextDate(after: yesterday, matching: DateComponents(weekday: targetWeekday + 1), matchingPolicy: .nextTime) {
//                        let startTime = calendar.date(bySettingHour: calendar.component(.hour, from: startTime_date),
//                                                      minute: calendar.component(.minute, from: startTime_date),
//                                                      second: 0,
//                                                      of: baseDate)!
//
//                        let adjustedBaseDate = calendar.date(byAdding: .day, value: daysDifference, to: baseDate)!
//                        let endTime = calendar.date(bySettingHour: calendar.component(.hour, from: endTime_date),
//                                                    minute: calendar.component(.minute, from: endTime_date),
//                                                    second: 0,
//                                                    of: adjustedBaseDate)!
//
//                        dates.append((startTime, endTime))
//                    }
//                }
//            }
//        }
//        return dates
//    }


enum enum_ブロック状態 {
    case 予定
    case 開始
    case 終了
}

extension ブロック状態監視 {
    var 現在の状態Text: String {
        switch 現在の状態 {
        case .予定:
            return "予定"
        case .開始:
            return "開始"
        case .終了:
            return "終了"
        }
    }
}

class ブロック状態監視: ObservableObject {
    @Published var 現在の状態: enum_ブロック状態 = .予定
    @Published var 残り時間Text: String = ""

    private var timer: Timer?
    private let startTime: Date
    private let endTime: Date
    private let repeatDays: [Int]

    init(startTime: Date, endTime: Date, repeatDays: [Int]) {
        self.startTime = startTime
        self.endTime = endTime
        self.repeatDays = repeatDays

        let nextDate = self.getNextScheduledDate()
        self.取得_ブロック状態(nextDate: nextDate)
    }

    private func getNextScheduledDate() -> Date {
        let calendar = Calendar.current
        let todayNum = calendar.component(.weekday, from: Date()) - 1 // 日曜を0とするため調整
        print("today: \(todayNum)")

        // 現在の時刻
        let now = Date()

        // `startTime` と `endTime` の時間成分のみを取得
        let startTime_time = calendar.dateComponents([.hour, .minute, .second], from: startTime)
        let endTime_time = calendar.dateComponents([.hour, .minute, .second], from: endTime)

        // startTime_date と endTime_date を今日の日付で設定
        var startTime_date = calendar.date(bySettingHour: startTime_time.hour!, minute: startTime_time.minute!, second: 0, of: now)!
        let endTime_date = calendar.date(bySettingHour: endTime_time.hour!, minute: endTime_time.minute!, second: 0, of: now)!

        // 翌日にまたがる場合には endTime_date を翌日に設定
        if (startTime_time.hour! > endTime_time.hour! ||
            (startTime_time.hour == endTime_time.hour && startTime_time.minute! > endTime_time.minute!)) {
            startTime_date = calendar.date(byAdding: .day, value: -1, to: startTime_date)!
        }

        // 状態を判定して出力
        let state: String
        if now < startTime_date {
            state = "予定"
        } else if now >= startTime_date && now < endTime_date {
            state = "ブロック中"
        } else {
            state = "終了、そして予定"
        }

        print(state)

        // DateFormatter を使用して日時を見やすく出力
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current

        print("startTime_date: \(formatter.string(from: startTime_date))")
        print("endTime_date: \(formatter.string(from: endTime_date))")


        // startTime の時間が endTime の時間より後の場合
        if (startTime_time.hour ?? 0) > (endTime_time.hour ?? 0) ||
            ((startTime_time.hour ?? 0) == (endTime_time.hour ?? 0) && (startTime_time.minute ?? 0) > (endTime_time.minute ?? 0)),
           repeatDays.contains(todayNum) {

            print("当てはまるよtoday: \(todayNum)")

            // 今日の endTime を設定（startTime より前の場合、翌日の時刻として扱う）
            let adjustedEndTime = calendar.date(bySettingHour: endTime_time.hour ?? 0,
                                                minute: endTime_time.minute ?? 0,
                                                second: 0, of: Date())!

            print("adjustedEndTime: \(jstDateString(for: adjustedEndTime)) 現在時刻: \(jstDateString(for: Date()))")

            // 現在が今日の endTime より前であれば、その日付を返す
            if Date() < adjustedEndTime {
                print("今は adjustedEndTime より前だよ: \(adjustedEndTime)")
                return adjustedEndTime
            }
        }

        // 今日から最も近い次の曜日を探す
        var daysUntilNext: Int?
        for day in repeatDays.sorted() {
            if day >= todayNum {
                daysUntilNext = day - todayNum
                print("daysUntilNext: \(daysUntilNext ?? 0)")
                break
            }
        }

        if daysUntilNext == nil, let firstDayNum = repeatDays.min() {
            daysUntilNext = 7 - todayNum + firstDayNum // 次の週の最初の曜日までの距離
            print("daysUntilNext(次週): \(daysUntilNext ?? 0)")
        }

        // 今日の日付に次のスケジュールまでの日数を追加
        return calendar.date(byAdding: .day, value: daysUntilNext ?? 0, to: Date()) ?? Date()
    }

    func 取得_ブロック状態(nextDate: Date) {
        print("Next Scheduled Date: \(nextDate)")

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let now = Date()
            let 新しい状態: enum_ブロック状態

            // nextDate を基準にして startTime と endTime に日付を追加
            let calendar = Calendar.current
            let startComponents = calendar.dateComponents([.hour, .minute, .second], from: self.startTime)
            let endComponents = calendar.dateComponents([.hour, .minute, .second], from: self.endTime)

            // startTime時間をnexDataの時間に設定
            guard let todayStartTime = calendar.date(bySettingHour: startComponents.hour ?? 0, minute: startComponents.minute ?? 0, second: 0, of: nextDate) else {
                return
            }


            // endTime の日付設定（startTimeよりも前の場合は翌日に設定）
            let todayEndTime: Date
            if let tempEndTime = calendar.date(bySettingHour: endComponents.hour ?? 0,
                                               minute: endComponents.minute ?? 0,
                                               second: 0, of: nextDate),
               tempEndTime < todayStartTime {
                todayEndTime = calendar.date(byAdding: .day, value: 1, to: tempEndTime) ?? tempEndTime
            } else {
                todayEndTime = calendar.date(bySettingHour: endComponents.hour ?? 0,
                                             minute: endComponents.minute ?? 0,
                                             second: 0, of: nextDate) ?? Date()
            }

            // 状態判定
            if now < todayStartTime {
                新しい状態 = .予定
                self.update残り時間(targetTime: todayStartTime)
            } else if now >= todayStartTime && now <= todayEndTime {
                新しい状態 = .開始
                self.update残り時間(targetTime: todayEndTime)
            } else {
                新しい状態 = .終了
                self.残り時間Text = "タイマーが終了しました"
                self.timer?.invalidate()
            }

            // 状態が変わった場合のみ更新
            if 新しい状態 != self.現在の状態 {
                self.現在の状態 = 新しい状態
                self.表示_ブロック状態(状態: 新しい状態)
            }
        }
    }

    private func update残り時間(targetTime: Date) {
        let now = Date()
        let remainingSeconds = Int(targetTime.timeIntervalSince(now))
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60
        self.残り時間Text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func 表示_ブロック状態(状態: enum_ブロック状態) {
        switch 状態 {
        case .予定:
            print("タイマーはまだ開始されていません")
        case .開始:
            print("タイマーが開始されました")
        case .終了:
            print("タイマーが終了しました")
        }
    }
}

func jstDateString(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
    return "JST: \(formatter.string(from: date))"
}
