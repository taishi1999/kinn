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

        let startTime_date = calendar.date(bySettingHour: 16, minute: 23, second: 0, of: now)!
        let endTime_date = calendar.date(bySettingHour: 16, minute: 23, second: 5, of: calendar.date(byAdding: .day, value: 0, to: now)!)!

        return DateCheckerView(
            startTime_date: startTime_date,
            endTime_date: endTime_date,
            repeatDays: [1, 2, 3, 4, 5, 6,7]
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

import SwiftUI

import SwiftUI

struct タスク時間判定: View {
    let startTime: Date
    let endTime: Date
    let weekDays: [Int] // 1(日) 〜 7(土)

    @State private var remainingTime: TimeInterval = 0
    @State private var timer: Timer?

    var isWithinTaskTime: Bool {
        return checkIfWithinTaskTime()
    }

    var body: some View {
        VStack {
            Text(isWithinTaskTime ? "✅ タスク時間内" : "❌ タスク時間外")
                .font(.title)
                .foregroundColor(isWithinTaskTime ? .green : .red)

            Text("開始時間: \(formattedTime(startTime))")
            Text("終了時間: \(formattedTime(endTime))")

            Text("次の時間まで: \(formattedTimeInterval(remainingTime))")
                .font(.headline)
                .foregroundColor(.blue)
        }
        .padding()
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    private func checkIfWithinTaskTime() -> Bool {
        let now = Date()
        let calendar = Calendar.current

        let todayWeekday = calendar.component(.weekday, from: now)
        if !weekDays.contains(todayWeekday) {
            return false
        }

        let nowTime = getMinutesSinceMidnight(from: now)
        let startTimeMinutes = getMinutesSinceMidnight(from: startTime)
        let endTimeMinutes = getMinutesSinceMidnight(from: endTime)

        if startTimeMinutes <= endTimeMinutes {
            return nowTime >= startTimeMinutes && nowTime < endTimeMinutes
        } else {
            return nowTime >= startTimeMinutes || nowTime < endTimeMinutes
        }
    }

    private func getMinutesSinceMidnight(from date: Date) -> Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return hour * 60 + minute
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func formattedTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func updateRemainingTime() {
        let now = Date()
        let calendar = Calendar.current
        let todayWeekday = calendar.component(.weekday, from: now)

        if isWithinTaskTime {
            print("タスク時間")
            // ✅ タスク時間内なら、`endTime` までの時間を計算（翌日またぎを考慮）
            let nextEndTime = getNextValidTime(baseDate: now, targetTime: endTime, canBeNextDay: true)
            remainingTime = nextEndTime.timeIntervalSince(now)
        } else {
            print("タスク時間外")
            // ✅ タスク時間外なら、次の `startTime` までの時間を計算
            if weekDays.contains(todayWeekday) {

                print("🔍 今日の曜日 (\(todayWeekday)) はタスクの有効な曜日に含まれています")
                print("🕒 現在時刻: \(formattedTime(now))")

                remainingTime = startTime.timeIntervalSince(now)
                print("✅ 開始時間までの残り時間 (after): \(formattedTimeInterval(remainingTime))")
                print("---------------")
            } else {

                print("🔍 今日の曜日 (\(todayWeekday)) はタスクの有効な曜日に含まれていません")
                print("🕒 現在時刻: \(formattedTime(now))")
                remainingTime = timeUntilNextStartDay(from: now, weekDays: weekDays)
                print("✅ 次の開始曜日までの残り時間 (after): \(formattedTimeInterval(remainingTime))")
                print("---------------")
            }

        }

        if remainingTime < 0 {
            remainingTime = 0
        }
    }

    /// ✅ **翌日またぎを考慮して `startTime` または `endTime` を計算**
    private func getNextValidTime(baseDate: Date, targetTime: Date, canBeNextDay: Bool) -> Date {
        let calendar = Calendar.current
        let targetHour = calendar.component(.hour, from: targetTime)
        let targetMinute = calendar.component(.minute, from: targetTime)

        var nextTime = calendar.date(bySettingHour: targetHour, minute: targetMinute, second: 0, of: baseDate)!

        // ✅ `targetTime` が過去なら翌日に設定
        if canBeNextDay && nextTime < baseDate {
            nextTime = calendar.date(byAdding: .day, value: 1, to: nextTime)!
        }
        return nextTime
    }

    private func timeUntilNextStartDay(from date: Date, weekDays: [Int]) -> TimeInterval {
        let calendar = Calendar.current
        let todayWeekday = calendar.component(.weekday, from: date)

        let sortedWeekDays = weekDays.sorted()
        let nextDay = sortedWeekDays.first(where: { $0 > todayWeekday }) ?? (sortedWeekDays.first! + 7)

        let daysUntilNext = (nextDay - todayWeekday + 7) % 7
        let nextStartDate = calendar.date(byAdding: .day, value: daysUntilNext, to: date)!
        let nextStartDateWithTime = getNextValidTime(baseDate: nextStartDate, targetTime: startTime, canBeNextDay: false)

        return nextStartDateWithTime.timeIntervalSince(date)
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateRemainingTime()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct タスク時間判定_Previews: PreviewProvider {
    static var previews: some View {
        let calendar = Calendar.current
        let now = Date()
        let startTime = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now)! // 今日の22:00
        let endTime = calendar.date(bySettingHour: 18, minute: 29, second: 0, of: now)! // 翌日の6:00
        let weekDays = [1, 2,3, 5] // 日・火・木に有効

        return タスク時間判定(startTime: startTime, endTime: endTime, weekDays: weekDays)
    }
}


import SwiftUI
// MARK: - メインの View

struct AssignTimeView: View {
    @State private var startDate: Date = createTime(hour: 9, minute: 0)
    @State private var endDate: Date = createTime(hour: 8, minute: 53)
    @State private var weekdays: [Int] = [2, 4, 5, 6] // 月・水・金

    @State private var nextEventText: String = "次のイベントはありません"
    @State private var remainingTimeText: String = ""
    @State private var nextEventDate: Date? = nil
    @State private var timer: Timer? = nil
    @State private var interval: TimeInterval = 0  // ← @Stateで管理

    var body: some View {
        VStack(spacing: 20) {
            Text(nextEventText)
                .font(.title2)
                .padding()

            Text(remainingTimeText)
                .font(.headline)
                .foregroundColor(.gray)

        }
        .onAppear {
            // findNextEventを実行して結果を updateUI に渡す
            if let (date, label) = findNextEvent(
                startDate: startDate,
                endDate: endDate,
                weekdays: weekdays
            ) {
//                updateUI(for: date, label: label)
                startCountdown(for: date)
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

//    /// UI を更新し、カウントダウンを開始
//    func updateUI(for eventDate: Date, label: String) {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MM/dd (E) HH:mm"
//
//        // label は "start" か "end" のみ
//        nextEventText = "\(label) \(formatter.string(from: eventDate))"
//        nextEventDate = eventDate
//    }

    /// カウントダウンタイマー
    func startCountdown(for eventDate: Date) {
        timer?.invalidate()  // 既存のタイマーを停止

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//            guard let eventDate = nextEventDate else {
//                timer?.invalidate()
//                return
//            }

            let now = Date()

            // イベント時刻を過ぎたら再検索
            if now >= eventDate {
                timer?.invalidate()
                if let (newDate, newLabel) = findNextEvent(
                    startDate: startDate,
                    endDate: endDate,
                    weekdays: weekdays
                ) {
//                    updateUI(for: newDate, label: newLabel)
                } else {
                    // 見つからないなら表示をリセット
                    nextEventText = "次のイベントはありません"
                    remainingTimeText = ""
                }
            } else {
                interval = eventDate.timeIntervalSince(now)

                // カウントダウン残り時間を表示（外部関数を呼び出し）
                remainingTimeText = "あと \(calculateTimeRemaining(interval))"
            }
        }
    }
}

// MARK: - Preview

struct AssignTimeView_Previews: PreviewProvider {
    static var previews: some View {
        AssignTimeView()
    }
}
// MARK: - 外部に切り離した関数

/// 指定した startDate, endDate, weekdays をもとに
/// 「最初に見つかった未来の開始 or 終了の (日付, ラベル)」を返す関数。
func findNextEvent(startDate: Date,
                   endDate: Date,
                   weekdays: [Int]) -> (Date, String)? {
    let calendar = Calendar.current
    let now = Date()
    let today = Date()

    // 今日の前日〜7日後を範囲に設定
    guard let startOfRange = calendar.date(byAdding: .day, value: -1, to: today),
          let endOfRange   = calendar.date(byAdding: .day, value: 7,  to: today)
    else {
        return nil
    }

    // startDate, endDate から hour/minute を取り出す
    let startComponents = calendar.dateComponents([.hour, .minute], from: startDate)
    let endComponents   = calendar.dateComponents([.hour, .minute], from: endDate)

    var current = startOfRange

    // 日付を 1日ずつ進めてチェック
    while current <= endOfRange {
        // current の曜日 (1:日, 2:月, ... 7:土)
        let assignedWeekday = calendar.component(.weekday, from: current)

        // weekdays に含まれない場合はスキップ
        if !weekdays.contains(assignedWeekday) {
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = nextDate
            continue
        }

        // current + start の時刻
        var startDC = calendar.dateComponents([.year, .month, .day], from: current)
        startDC.hour   = startComponents.hour
        startDC.minute = startComponents.minute
        guard let assignedStart = calendar.date(from: startDC) else { break }

        // current + end の時刻
        var endDC = calendar.dateComponents([.year, .month, .day], from: current)
        endDC.hour   = endComponents.hour
        endDC.minute = endComponents.minute
        guard var assignedEnd = calendar.date(from: endDC) else { break }

        // start > end の場合は end を翌日に
        if assignedStart > assignedEnd {
            assignedEnd = calendar.date(byAdding: .day, value: 1, to: assignedEnd)!
        }

        // 現在 < assignedStart なら開始が次のイベント
        if now < assignedStart {
            return (assignedStart, "start")
        }

        // 現在 < assignedEnd なら終了が次のイベント
        if now < assignedEnd {
            return (assignedEnd, "end")
        }

        // ここまで来たら次の日へ
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: current) else { break }
        current = nextDate
    }

    // 見つからなかった場合
    return nil
}

/// 残り時間を「xx時間 xx分 xx秒」の文字列で返す関数
func calculateTimeRemaining(_ interval: TimeInterval) -> String {
    // interval は「残り秒数」(浮動小数)
    // 例: interval = 3785.3 (約 1時間 03分 05秒)

    let totalSeconds = Int(interval)  // 小数点以下を切り捨て
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60

    return String(format: "%d:%02d:%02d", hours, minutes, seconds)
}

// MARK: - ヘルパー関数

/// 時刻だけ設定して返す (当日の date)
func createTime(hour: Int, minute: Int) -> Date {
    let calendar = Calendar.current
    return calendar.date(bySettingHour: hour,
                         minute: minute,
                         second: 0,
                         of: Date()) ?? Date()
}
