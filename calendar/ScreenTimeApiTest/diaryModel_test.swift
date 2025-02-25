import SwiftUI
import FamilyControls
import DeviceActivity

class DiaryTaskManager: ObservableObject {
    static let shared = DiaryTaskManager()
    /// DiaryTask
    @Published var diaryTask: DiaryTask
    @Published var selection = FamilyActivitySelection()
    private var timer: Timer?
    @Published private(set) var interval: TimeInterval = 0
    @Published var nextEventLabel: String = "none"
    @Published var isBlocked: Bool = false
    private static let diaryTaskKey = "diary"
    private static let selectionsKey = "selection_1"

    private static func defaultStartTime() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 12
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    private static func defaultEndTime() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 13
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    private init() {
        // UserDefaultsから値を読み取る
        if let loadedTask = DiaryTaskManager.loadDiaryTask(forKey: DiaryTaskManager.diaryTaskKey) {
            diaryTask = loadedTask
        } else {
            // 初期値
            diaryTask = DiaryTask(
                type: "diary",
                selectionID: "selection_1",
//                selection: FamilyActivitySelection(),
                startTime: DiaryTaskManager.defaultStartTime(), // 初期値を12:00
                endTime: DiaryTaskManager.defaultEndTime(),
                weekDays: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
                characterCount: 10
            )
        }

        // UserDefaultsからFamilyActivitySelectionを読み取る
        if let loadedSelection = DiaryTaskManager.loadFamilyActivitySelection(forKey: diaryTask.selectionID) {
            selection = loadedSelection
        } else {
            // 初期値
            selection = FamilyActivitySelection()
        }

        initializeNextEvent()
        startCountdown()
    }

    /// `findNextEvent()` の結果を初期化時に取得
    private func initializeNextEvent() {
        print("nextEventLavel_initializeNextEvent: \(self.nextEventLabel)")

        if let (eventDate, eventLabel) = findNextEvent() {
            print("eventLabel: \(eventLabel)")
            self.nextEventLabel = eventLabel
            self.interval = eventDate.timeIntervalSince(Date()) // 🔹 開始までの時間をセット
            print("nextEventLavel: \(self.nextEventLabel)")
            self.isBlocked = (eventLabel == "end") // 🔹 `end` ならブロック状態
        } else {
            self.nextEventLabel = "none"
            self.interval = 0
            self.isBlocked = false
        }
    }

    /// `DiaryTask` を UserDefaults に保存し、結果を `completion` で返す
    func saveDiaryTask(
        _ diaryTask: DiaryTask,
        selection: FamilyActivitySelection,
        taskKey: String,
        selectionKey: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // 日付フォーマットを指定

        do {
            let appGroupDefaults = UserDefaults(suiteName: "group.com.karasaki.kinn.date")

            // DiaryTask の保存
            let taskData = try encoder.encode(diaryTask)
            appGroupDefaults?.set(taskData, forKey: taskKey)
            print("✅ DiaryTask を保存しました (キー: \(taskKey))")

            // FamilyActivitySelection の保存
            let selectionData = try encoder.encode(selection)
            appGroupDefaults?.set(selectionData, forKey: selectionKey)
            print("✅ FamilyActivitySelection を保存しました (キー: \(selectionKey))")

            // 成功した場合
            completion(.success(()))
        } catch {
            print("❌ 保存に失敗しました: \(error)")
            completion(.failure(error))
        }
    }



    /// UserDefaultsからDiaryTaskを読み込む
    static func loadDiaryTask(forKey key: String) -> DiaryTask? {
        let appGroupDefaults = UserDefaults(suiteName: "group.com.karasaki.kinn.date")
        guard let data = appGroupDefaults?.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // 日付フォーマットを指定
        do {
            return try decoder.decode(DiaryTask.self, from: data)
        } catch {
            print("Failed to load DiaryTask: \(error)")
            return nil
        }
    }

    static func loadFamilyActivitySelection(forKey key: String) -> FamilyActivitySelection? {
        let appGroupDefaults = UserDefaults(suiteName: "group.com.karasaki.kinn.date")
        guard let data = appGroupDefaults?.data(forKey: key) else {
            print("FamilyActivitySelection のデータが見つかりません (キー: \(key))")
            return nil
        }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(FamilyActivitySelection.self, from: data)
        } catch {
            print("FamilyActivitySelection の読み込みに失敗しました: \(error)")
            return nil
        }
    }

    func loadTaskAndSelection() {
            if let loadedTask = DiaryTaskManager.loadDiaryTask(forKey: "diary") {
                self.diaryTask = loadedTask
                print("DiaryTask loaded: \(loadedTask)")

                // selectionID を使って FamilyActivitySelection をロード
                if let loadedSelection = DiaryTaskManager.loadFamilyActivitySelection(forKey: loadedTask.selectionID) {
                    print("FamilyActivitySelection loaded: \(loadedSelection)")
                } else {
                    print("No FamilyActivitySelection found for key: \(loadedTask.selectionID)")
                }
            } else {
                print("No DiaryTask found.")
            }
        
        }

    func deleteDiaryTask(taskKey: String, selectionKey: String) {
        // アプリグループのUserDefaultsを使用
        let appGroupDefaults = UserDefaults(suiteName: "group.com.karasaki.kinn.date")

        // DiaryTask の削除
        appGroupDefaults?.removeObject(forKey: taskKey)
        print("DiaryTask を削除しました (キー: \(taskKey))")
        // FamilyActivitySelection の削除
        appGroupDefaults?.removeObject(forKey: selectionKey)
        print("FamilyActivitySelection を削除しました (キー: \(selectionKey))")
    }

    /// ✅ `findNextEvent` を `DiaryTaskManager` に統合
        func findNextEvent() -> (Date, String)? {
            let calendar = Calendar.current
            let now = Date()
            let today = Date()

            guard let startOfRange = calendar.date(byAdding: .day, value: -1, to: today),
                  let endOfRange = calendar.date(byAdding: .day, value: 7, to: today) else {
                return nil
            }

            let startComponents = calendar.dateComponents([.hour, .minute], from: diaryTask.startTime)
            let endComponents = calendar.dateComponents([.hour, .minute], from: diaryTask.endTime)
            var current = startOfRange

            while current <= endOfRange {
                let assignedWeekday = calendar.component(.weekday, from: current)
                if !diaryTask.weekDays.contains(WeekDays(rawValue: assignedWeekday)?.shortName ?? "") {
                    current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
                    continue
                }

                var startDC = calendar.dateComponents([.year, .month, .day], from: current)
                startDC.hour = startComponents.hour
                startDC.minute = startComponents.minute
                guard let assignedStart = calendar.date(from: startDC) else { break }

                var endDC = calendar.dateComponents([.year, .month, .day], from: current)
                endDC.hour = endComponents.hour
                endDC.minute = endComponents.minute
                guard var assignedEnd = calendar.date(from: endDC) else { break }

                if assignedStart > assignedEnd {
                    assignedEnd = calendar.date(byAdding: .day, value: 1, to: assignedEnd)!
                }

                if now < assignedStart {
                    print("now:\(now), assignedStart: \(assignedStart)")
                    return (assignedStart, "start")
                }
                if now < assignedEnd {
                    print("now:\(now), assignedEnd: \(assignedEnd)")
                    return (assignedEnd, "end")
                }
                current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
            }
            return nil
        }

    /// ✅ `interval` の更新は内部のみにする
        private func updateInterval(_ newInterval: TimeInterval) {
            DispatchQueue.main.async {
                self.interval = newInterval
            }
        }

    /// ✅ `startCountdown` を `DiaryTaskManager` に統合
        func startCountdown() {
            timer?.invalidate()

            guard let (eventDate, eventLabel) = findNextEvent() else {
                updateInterval(0)
                nextEventLabel="none"
                return
            }
//            print("[startCountdown] eventDate: \(eventDate), eventLabel: \(eventLabel)")
            nextEventLabel = eventLabel // 🔹 更新

            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                let now = Date()

                if now >= eventDate {
                    self.timer?.invalidate()
                    self.startCountdown() // 🔹 次のイベントを探す
                } else {
//                    print("[startCountdown] eventDate: \(eventDate), eventLabel: \(eventLabel)")
//                    let newInterval = eventDate.timeIntervalSince(now)
//                                DispatchQueue.main.async { // ✅ UI 更新を確実に実行
//                                    self.interval = newInterval
//                                }
                    self.updateInterval(eventDate.timeIntervalSince(now))
//                    self.isBlocked = ShieldManager.shared.isCurrentlyBlocked()
                    let newBlockedState = ShieldManager.shared.isCurrentlyBlocked()
                                if self.isBlocked != newBlockedState { // 🔹 値が変わった時のみ更新
                                    DispatchQueue.main.async {
                                        self.isBlocked = newBlockedState
                                    }
                                }

//                    print("[startCountdown] diaryModel_interval:\(self.interval), isBlocked: \(self.isBlocked)")
                }
            }
            RunLoop.current.add(timer!, forMode: .common) // ✅ `common` モードで実行することでスクロールしてもカウントダウン表示が止まらない(止まってもカウントダウンの処理自体は正常に動く)
        }

    func updateTask(completion: @escaping (Result<Void, Error>) -> Void) {
        // selectionIDを設定
        diaryTask.selectionID = "selection_1"
        // タスクを保存
        saveDiaryTask(
            diaryTask,
            selection: selection,
            taskKey: "diary",
            selectionKey: "selection_1"
        ){ result in
            switch result {
            case .success:
                print("[updateTask().saveDiaryTask]✅ タスク保存成功！\(result)")
            case .failure(let error):
                print("[updateTask().saveDiaryTask]❌ タスク保存失敗: \(error.localizedDescription)")
                return completion(.failure(error))
            }
        }
//        print("✅ 保存後の diaryTask: \(diaryTask)")

        // 監視を開始
        let result = startMonitoring()
        // 監視結果を出力
        switch result {
        case .success(let success):
            print("[updateTask().startMonitoring] ✅ 成功: \(success)")
        case .failure(let error):
            print("[updateTask().startMonitoring]❌ エラー: \(error)")
            return completion(.failure(error))
        }

        // 通知のスケジュール設定
        let weekDays: [WeekDays] = convertToWeekDays(from: diaryTask.weekDays)
        let rawValues = weekDays.map { $0.rawValue }
        NotificationScheduler.shared.scheduleNotification(startTime: diaryTask.startTime, weekdays: rawValues) { result in
            switch result {
            case .success:
                print("[updateTask().scheduleNotification] ✅ 通知が正常にスケジュールされました")
            case .failure(let error):
                print("[updateTask().scheduleNotification] ❌ 通知のスケジュールに失敗: \(error)")
                //ローカル通知が送れなくてもユーザーの意思の可能性があるので無効にする
//                completion(.failure(error))
            }
        }

//        NotificationScheduler.shared.scheduleNotification(
//            startTime: diaryTask.startTime,
//            weekdays: rawValues
//        )

        // カウントダウンを開始
        startCountdown()
        completion(.success(()))
    }

    enum ScheduleError: Error {
        case excessiveActivities
        case intervalTooLong
        case intervalTooShort
        case invalidDateComponents
        case unauthorized
        case unknownError(String)
    }

    func startMonitoring() -> Result<Bool, ScheduleError> {
        let center = DeviceActivityCenter()

        //曜日配列を数字配列に変換
    //    let weekDays: [WeekDays] = diaryTaskManager.diaryTask.weekDays.compactMap { weekDayString in
    //        WeekDays.allCases.first { $0.shortName == weekDayString }
    //    }
        let weekDays: [WeekDays] = convertToWeekDays(from: diaryTask.weekDays)
        let rawValues = weekDays.map { $0.rawValue }
        print("Raw values: \(rawValues)")
        print("diaryTaskManager.diaryTask.weekDays:\(diaryTask.weekDays)")

        //指定した曜日以外のモニタリングをストップ------------------------------
        // 現在のスケジュールを取得
        let allScheduledActivities = center.activities
        allScheduledActivities.forEach { activity in
            print("全てのActivityの名前: \(activity.rawValue)")
        }
        //あとでこれで代替できるかテスト
    //    let allScheduledActivities = getAllScheduledActivities()

        // 選択された曜日に関連しないスケジュールを取得
        let selectedScheduleNames = weekDays.map { DeviceActivityName("diary_\($0)") }
        let schedulesToRemove = allScheduledActivities.filter { !selectedScheduleNames.contains($0) }
        print("スケジュールを削除する必要がある項目: \(schedulesToRemove)")

        // 各スケジュール名を詳細に出力（配列内の要素を個別に表示）
        for schedule in schedulesToRemove {
            print("削除対象のスケジュール: \(schedule)")
        }

        center.stopMonitoring(schedulesToRemove)
        //--------------------------------------------------------------

        // 開始時刻と終了時刻の DateComponents を取得
        let startComponents = Calendar.current.dateComponents([.hour, .minute], from: diaryTask.startTime)
        var endComponents = Calendar.current.dateComponents([.hour, .minute], from: diaryTask.endTime)

        // 経過時間を計算
        let elapsedComponents = calculateElapsedTime(from: diaryTask.startTime, to: diaryTask.endTime)
        let elapsedMinutes = (elapsedComponents.hour ?? 0) * 60 + (elapsedComponents.minute ?? 0)

        // 警告時間の初期値
        var warningTime = DateComponents(minute: 0)

        // 経過時間をログに出力
        print("経過時間（分単位）: \(elapsedMinutes)")

        // 経過時間が0より大きく15分未満の場合の処理
        if elapsedMinutes > 0 && elapsedMinutes < 15 {
            // 警告時間を設定
            warningTime = DateComponents(minute: 15 - elapsedMinutes)

            // 終了時刻を開始時刻の15分後に調整
            if let startDate = Calendar.current.date(from: startComponents) {
                let adjustedEndDate = Calendar.current.date(byAdding: .minute, value: 15, to: startDate)
                endComponents = Calendar.current.dateComponents([.hour, .minute], from: adjustedEndDate ?? startDate)
            }
        }

        // endComponents をログに出力
    //    print("Start Components: \(startComponents)")
    //    print("warningTime: \(warningTime)")
    //    print("Adjusted End Components: \(endComponents)")

        var hasSucceeded = false
        for weekDay in weekDays {
            let scheduleName = DeviceActivityName("diary_\(weekDay)")
            print("Schedule Name: \(scheduleName.rawValue)")


            var startWithWeekday = startComponents
            var endWithWeekday = endComponents
            //開始曜日数字を設定
            startWithWeekday.weekday = weekDay.rawValue
            //終了曜日数字を設定
            //翌日になった場合、次の曜日数字を設定
            if elapsedMinutes <= 0 {
                // 次の曜日を計算
                let nextWeekdayRawValue = (weekDay.rawValue % 7) + 1
                endWithWeekday.weekday = nextWeekdayRawValue
                print("次の曜日: \(nextWeekdayRawValue)")
            } else {
                // 同じ曜日のまま
                endWithWeekday.weekday = weekDay.rawValue
            }

            let schedule = DeviceActivitySchedule(
                intervalStart: startWithWeekday,
                intervalEnd: endWithWeekday,
                repeats: true, // 毎週繰り返し
                warningTime: warningTime
            )

            do {
                try center.startMonitoring(scheduleName, during: schedule)
                print("[startMonitoring] \(weekDay) のスケジュールが登録されました")
                hasSucceeded=true
    //            return .success(true)
            } catch let error as DeviceActivityCenter.MonitoringError {
                        print("[startMonitoring]⚠️ DeviceActivityCenter のエラー: \(error)")
                        switch error {
                        case .excessiveActivities:
                            return .failure(.excessiveActivities)
                        case .intervalTooLong:
                            return .failure(.intervalTooLong)
                        case .intervalTooShort:
                            return .failure(.intervalTooShort)
                        case .invalidDateComponents:
                            return .failure(.invalidDateComponents)
                        case .unauthorized:
                            return .failure(.unauthorized)
                        @unknown default:
                            return .failure(.unknownError("[startMonitoring]未知のエラー: \(error)"))
                        }
                    } catch {
                        print("[startMonitoring]⚠️ 不明なエラー: \(error.localizedDescription)")
                        return .failure(.unknownError(error.localizedDescription))
                    }
        }

        // 成功した場合は .success(true) を返す
            if hasSucceeded {
                return .success(true)
            }

            // weekDays が空だった場合や、例外処理がないエラーが発生した場合のフォールバック
            return .failure(.unknownError("[startMonitoring] Unexpected error"))
    }

    func calculateElapsedTime(from startTime: Date, to endTime: Date) -> DateComponents {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date()) // 今日の日付を取得して時刻をリセット

        // startTime の時刻を今日の日付に合わせる
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let adjustedStartTime = calendar.date(bySettingHour: startComponents.hour ?? 0,
                                              minute: startComponents.minute ?? 0,
                                              second: 0,
                                              of: today) ?? today

        // endTime の時刻を今日の日付に合わせる
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        let adjustedEndTime = calendar.date(bySettingHour: endComponents.hour ?? 0,
                                            minute: endComponents.minute ?? 0,
                                            second: 0,
                                            of: today) ?? today

        // startTime と endTime を指定して時間差を計算
        return calendar.dateComponents([.hour, .minute], from: adjustedStartTime, to: adjustedEndTime)
    }


}

func convertToWeekDays(from weekDayStrings: [String]) -> [WeekDays] {
    return weekDayStrings.compactMap { weekDayString in
        WeekDays.allCases.first { $0.shortName == weekDayString }
    }
}



struct DiaryTask: Codable,Equatable {
    var type: String
    var selectionID: String
    var startTime: Date
    var endTime: Date
    var weekDays: [String]
    var characterCount: Int
}

enum WeekDays: Int, CaseIterable, Identifiable {
    case sun = 1
    case mon, tue, wed, thu, fri, sat

    var id: Int { rawValue } // Picker 用の Identifiable 準拠

    // 英語の略称を追加
    var shortName: String {
        switch self {
        case .sun: return "Sun"
        case .mon: return "Mon"
        case .tue: return "Tue"
        case .wed: return "Wed"
        case .thu: return "Thu"
        case .fri: return "Fri"
        case .sat: return "Sat"
        }
    }

    var displayName: String {
        switch self {
        case .sun: return "日曜日"
        case .mon: return "月曜日"
        case .tue: return "火曜日"
        case .wed: return "水曜日"
        case .thu: return "木曜日"
        case .fri: return "金曜日"
        case .sat: return "土曜日"
        }
    }
}
