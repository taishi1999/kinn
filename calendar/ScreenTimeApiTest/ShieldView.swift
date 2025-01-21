import SwiftUI
import FamilyControls
import DeviceActivity // 必須のフレームワーク

//extension DeviceActivityName {
//    static let daily = DeviceActivityName("daily") // 静的プロパティを定義
//}
struct ShieldView: View {
    @ObservedObject var manager: ShieldManager
    //    @StateObject private var manager = ShieldManager()
    @State private var showActivityPicker = false
    private let center = DeviceActivityCenter()
    @ObservedObject var diaryTaskManager = DiaryTaskManager.shared
//    let weekDays: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let weekDays: [String] = WeekDays.allCases.map { $0.shortName }

    //    @State private var startTime: Date = Date() // 初期値として現在時刻を設定
    //    @State private var endTime: Date = Date().addingTimeInterval(60 * 60) // 初期値として1時間後を設定
    //    private let userDefaultsKey = "ScreenTimeSelection_DAMExtension"
    //    private let appGroupDefaults = UserDefaults(suiteName: "group.com.karasaki.kinn.date")

    var body: some View {
//            if manager.diaryTask == nil {
//                // ローディングビュー
//                VStack {
//                    ProgressView("Loading...")
//                        .progressViewStyle(CircularProgressViewStyle())
//                        .padding()
//                    Text("データを読み込んでいます...")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            } else {
                // 通常のUI
                VStack {
                    HStack{
                        VStack() {
                            Text("開始時間")
                                .font(.subheadline)

                            DatePicker("開始時間", selection: Binding(
                                get: { diaryTaskManager.diaryTask.startTime },
                                set: { diaryTaskManager.diaryTask.startTime = $0 }
                            ), displayedComponents: .hourAndMinute)
                            .labelsHidden()
                        }
                        // 終了時間の設定
                        VStack() {
                            Text("終了時間")
                                .font(.subheadline)
                            DatePicker("終了時間", selection: Binding(
                                get: { diaryTaskManager.diaryTask.endTime },
                                set: { diaryTaskManager.diaryTask.endTime = $0 }
                            ), displayedComponents: .hourAndMinute)
                            .labelsHidden()

                        }

                        VStack {
                            Text("文字数")
                                .font(.subheadline)
                            TextField("数値を入力", text: Binding(
                                get: { String(diaryTaskManager.diaryTask.characterCount) }, // Int → String
                                set: { newValue in
                                    if let intValue = Int(newValue) { // String → Int
                                        diaryTaskManager.diaryTask.characterCount = intValue
                                    }
                                }
                            ))
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("完了") {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                }
                            }

                        }
                    }

                    Button {
                        showActivityPicker = true
                    } label: {
                        Label("アプリ選択", systemImage: "gearshape")
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Apply Shielding") {
                        //                startMonitoring()
                        startMonitoringWithEvent()
                        //                manager.shieldActivities()
                    }
                    .buttonStyle(.bordered)

                    Button("save") {
                        //                let diaryTask = DiaryTask(
                        //                    startTime: Date(),
                        //                    endTime: Date().addingTimeInterval(3600), // 1時間後
                        //                    weekDays: [1, 2, 3], // 月, 火, 水
                        //                    characterCount: 100
                        //                )
//                        manager.saveTask(manager.diaryTask, withKey: "diary")
//                        if let loadedDiaryTask: DiaryTask = manager.loadTask(withKey: "diary", as: DiaryTask.self) {
//                            print("Loaded DiaryTask: \(loadedDiaryTask)")
//                        }
//                        manager.saveSelection(selection: manager.discouragedSelections,startTime: manager.startTime,endTime: manager.endTime, weekDays: manager.weekDays)
                        diaryTaskManager.diaryTask.selectionID="selection_1"

                        diaryTaskManager.saveDiaryTask(
                            diaryTaskManager.diaryTask,
                            selection: diaryTaskManager.selection,
                            taskKey: "diary",
                            selectionKey: "selection_1"
                        )


                    }

                    Button("get") {
                        diaryTaskManager.loadTaskAndSelection()
//                        if let loadedTask = DiaryTaskManager.loadDiaryTask(forKey: "diary") {
//                            diaryTaskManager.diaryTask = loadedTask
////                            loadedTask.selectionID
//                            print("DiaryTask loaded: \(loadedTask)")
//                            // selectionID を使って FamilyActivitySelection をロード
//                                    if let loadedSelection = DiaryTaskManager.loadFamilyActivitySelection(forKey: loadedTask.selectionID) {
//                                        print("FamilyActivitySelection loaded: \(loadedSelection)")
//                                    } else {
//                                        print("No FamilyActivitySelection found for key: \(loadedTask.selectionID)")
//                                    }
//                        } else {
//                            print("No DiaryTask found.")
//                        }

//                        let result = manager.savedSelection()

//                        if let selection = result.selection {
//                            print("Saved selection: \(selection)")
//                            if let startTime = result.startTime {
//                                print("Start time: \(startTime)")
//                            }
//                            if let endTime = result.endTime {
//                                print("End time: \(endTime)")
//                            }
//                            if let weekDays = result.weekDays {
//                                print("weekdays: \(weekDays)")
//                            }
//                        } else {
//                            print("No selection found")
//                        }
                    }

                    Button("unlock") {
                        manager.removeAllShields()
                    }

                    Button("is_ブロック作動中") {
                        //                manager.isCurrentlyBlocked()
                        if manager.isCurrentlyBlocked() {
                            print("現在ブロックされています")
                        } else {
                            print("現在ブロックされていません")
                        }
                    }
                    Button("取得_全てのブロックスケジュール") {
                        fetchAllMonitoringActivities()
                    }

                    ScrollView { // ScrollView を追加
                        VStack(alignment: .leading) { // VStack を ScrollView 内に配置
                            ForEach(weekDays, id: \.self) { day in
                                HStack {
                                    Text(day)
                                    Spacer()
                                    // チェックボックス形式で選択状態を表示
                                    if diaryTaskManager.diaryTask.weekDays.contains(day) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .onTapGesture {
                                    // 選択状態をトグル
                                    if diaryTaskManager.diaryTask.weekDays.contains(day) {
                                        diaryTaskManager.diaryTask.weekDays.removeAll { $0 == day }
                                    } else {
                                        diaryTaskManager.diaryTask.weekDays.append(day)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 200) // 必要に応じて高さを調整
                    .border(Color.gray, width: 1)
                }
                .familyActivityPicker(isPresented: $showActivityPicker, selection: $diaryTaskManager.selection)


//        .onAppear {
//            // 初回ロードのアクション（必要に応じて）
//            if manager.diaryTask == nil {
//                manager.loadInitialData()
//            }
//        }


    }

    private func fetchAllMonitoringActivities() {
        let activities = center.activities

            for activityName in activities {
                if let schedule = center.schedule(for: activityName) {
                    print("アクティビティ名: \(activityName.rawValue)")
                    print("スケジュール開始: \(schedule.intervalStart)")
                    print("スケジュール終了: \(schedule.intervalEnd)")
                    print("繰り返し: \(schedule.repeats)")
                    // イベントを取得
                                let events = center.events(for: activityName)
                                if events.isEmpty {
                                    print("関連イベントなし")
                                } else {
                                    print("関連イベント:")
                                    for (eventName, event) in events {
                                        print("  イベント名: \(eventName.rawValue)")
                                        print("    閾値: \(event.threshold)")
//                                        print("    アプリケーション: \(event.applications.isEmpty ? "なし" : event.applications)")
//                                        print("    カテゴリ: \(event.categories.isEmpty ? "なし" : event.categories)")
//                                        print("    Webドメイン: \(event.webDomains.isEmpty ? "なし" : event.webDomains)")
//                                        print("    全てのアクティビティを含む: \(event.includesAllActivity)")
                                    }
                                }
                    print("-------------------------")
                } else {
                    print("スケジュールが見つかりません: \(activityName.rawValue)")
                }
            }
    }


    private func startMonitoringWithEvent() {
        print("モニタリングスタート")
//        let weekDays: [WeekDays] = [.mon, .tue, .sat]
//        let result = manager.savedSelection()
//        guard let startTime = result.startTime,
//                  let endTime = result.endTime,
//                  let weekDays = result.weekDays else { // weekDays を取得
//                print("開始時間、終了時間、または曜日が見つかりません")
//                return
//            }
        let weekDays: [WeekDays] = diaryTaskManager.diaryTask.weekDays.compactMap { weekDayString in
            WeekDays.allCases.first { $0.shortName == weekDayString }
        }
        let rawValues = weekDays.map { $0.rawValue }
        print("Raw values: \(rawValues)")
        print("weekDays: \(weekDays),  diaryTaskManager.diaryTask.weekDays:\(diaryTaskManager.diaryTask.weekDays)")


        //指定した曜日以外のモニタリングをストップ------------------------------
        // 現在のスケジュールを取得
        let allScheduledActivities = center.activities
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

//        let startComponents = Calendar.current.dateComponents([.hour, .minute], from: startTime)
        let startComponents = Calendar.current.dateComponents([.hour, .minute], from: diaryTaskManager.diaryTask.startTime)

//        var endComponents = Calendar.current.dateComponents([.hour, .minute], from: endTime)
        var endComponents = Calendar.current.dateComponents([.hour, .minute], from: diaryTaskManager.diaryTask.endTime
        )
        let elapsedComponents = calculateElapsedTime(from: diaryTaskManager.diaryTask.startTime, to: diaryTaskManager.diaryTask.endTime)
        // 開始から終了までの時間を計算
//        let elapsedComponents = Calendar.current.dateComponents([.hour, .minute], from: startTime, to: endTime)

//        print("hour:\(String(describing: elapsedComponents.hour)) minute:\(String(describing: elapsedComponents.minute))")
        // 全体の経過分数を計算
        let elapsedMinutes = (elapsedComponents.hour ?? 0) * 60 + (elapsedComponents.minute ?? 0)
        print("経過時間（分単位）: \(elapsedMinutes)")

        //15分未満の場合,warningTimeを設定してintervalWillEndWarningを
        //実行させる（DeviceActivityScheduleは15分間隔を空けないといけない仕様なので）
        var warningTime = DateComponents(minute: 0)
        if elapsedMinutes > 0 && elapsedMinutes < 15 {
            warningTime = DateComponents(minute: 15 - elapsedMinutes)

            // endComponents を startComponents の 15 分後に設定
            if let startDate = Calendar.current.date(from: startComponents) {
                let adjustedEndDate = Calendar.current.date(byAdding: .minute, value: 15, to: startDate)
                endComponents = Calendar.current.dateComponents([.hour, .minute], from: adjustedEndDate ?? startDate)
            }
        }

        for weekDay in weekDays {
            let scheduleName = DeviceActivityName("diary_\(weekDay)")
            // 1. 既存のスケジュールを停止
//            center.stopMonitoring([scheduleName])

            var startWithWeekday = startComponents
            var endWithWeekday = endComponents

            // 曜日を追加
            startWithWeekday.weekday = weekDay.rawValue
            //翌日になった場合、次の日の曜日を設定
            if elapsedMinutes <= 0 {
                    // 次の曜日を計算
                    let nextWeekdayRawValue = (weekDay.rawValue % 7) + 1
                    endWithWeekday.weekday = nextWeekdayRawValue
                print("次の曜日: \(nextWeekdayRawValue)")
                } else {
                    // 同じ曜日のまま
                    endWithWeekday.weekday = weekDay.rawValue
                }
            // スケジュールを作成
            let schedule = DeviceActivitySchedule(
                intervalStart: startWithWeekday,
                intervalEnd: endWithWeekday,
                repeats: true, // 毎週繰り返し
                warningTime: warningTime
            )

            do {
                // スケジュールとイベントを登録
//                try center.startMonitoring(
//                    .init("\(weekDay)Schedule"), // 各曜日ごとのスケジュール名
//                    during: schedule
//                )
                try center.startMonitoring(scheduleName, during: schedule)
                print("\(weekDay) のスケジュールが登録されました")
            } catch {
                print("\(weekDay) のスケジュール登録エラー: \(error.localizedDescription)")
            }
        }
    }



//    private func startMonitoring() {
//        print("startMonitoring")
//        let schedule = DeviceActivitySchedule(
//            intervalStart: DateComponents(hour: 12, minute: 03),
//            intervalEnd: DateComponents(hour: 16, minute: 30),
//            repeats: true
//        )
//
//        //        let event = DeviceActivityEvent(
//        //            name: DeviceActivityEvent.Name("shortUsageEvent"),
//        //            applications: [ApplicationToken("com.example.app")],
//        //            threshold: DateComponents(minute: 1)
//        //        )
//
//        do {
//            try center.startMonitoring(.daily, during: schedule)
//        } catch {
//            print ("Could not start monitoring \(error)")
//        }
//    }

}

//struct DiaryTask: Codable {
//    var startTime: Date
//    var endTime: Date
//    var weekDays: [Int]
//    var characterCount: Int
//}

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
//        // 単一のスケジュール
//        let schedule = DeviceActivitySchedule(
//            intervalStart: startComponents,
//            intervalEnd: endComponents,
//            repeats: true,
//            warningTime: warningTime
//        )

// イベント: 開始から5分後に発動
//        let event = DeviceActivityEvent(
//            applications: [], // 監視対象アプリケーション（空でOK）
//            categories: [],   // 監視対象カテゴリ（空でOK）
//            webDomains: [],   // 監視対象ドメイン（空でOK）
//            threshold: DateComponents(minute: 5) // 5分後にイベント発動
//        )
//
//        do {
//            // スケジュールとイベントを登録
//            try center.startMonitoring(
//                .init("testSchedule"), // スケジュール名
//                during: schedule
//                //                events: [DeviceActivityEvent.Name("fiveMinuteEvent"): event] // イベント名
//            )
//            print("スケジュールとイベントが登録されました")
//        } catch {
//            print("スケジュール登録エラー: \(error)")
//        }
