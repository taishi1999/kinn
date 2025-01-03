import SwiftUI
import FamilyControls
import DeviceActivity // 必須のフレームワーク

extension DeviceActivityName {
    static let daily = DeviceActivityName("daily") // 静的プロパティを定義
}
struct ShieldView: View {
    @ObservedObject var manager: ShieldManager
    //    @StateObject private var manager = ShieldManager()
    @State private var showActivityPicker = false
    private let center = DeviceActivityCenter()


    //    @State private var startTime: Date = Date() // 初期値として現在時刻を設定
    //    @State private var endTime: Date = Date().addingTimeInterval(60 * 60) // 初期値として1時間後を設定
    //    private let userDefaultsKey = "ScreenTimeSelection_DAMExtension"
    //    private let appGroupDefaults = UserDefaults(suiteName: "group.com.karasaki.kinn.date")

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("開始時間")
                    .font(.subheadline)
                DatePicker("開始時間", selection: $manager.startTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()

            }
            .padding()
            // 終了時間の設定
            VStack(alignment: .leading, spacing: 10) {
                Text("終了時間")
                    .font(.subheadline)
                DatePicker("終了時間", selection: $manager.endTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }
            .padding()

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
                manager.saveSelection(selection: manager.discouragedSelections,startTime: manager.startTime,endTime: manager.endTime, weekDays: manager.weekDays)
            }

            Button("get") {
                let result = manager.savedSelection()

                if let selection = result.selection {
                    print("Saved selection: \(selection)")
                    if let startTime = result.startTime {
                        print("Start time: \(startTime)")
                    }
                    if let endTime = result.endTime {
                        print("End time: \(endTime)")
                    }
                    if let weekDays = result.weekDays {
                        print("weekdays: \(weekDays)")
                    }
                } else {
                    print("No selection found")
                }
            }

            Button("unlock") {
                manager.removeAllShields()
            }

            Button("fetch_blocking") {
                //                manager.isCurrentlyBlocked()
                if manager.isCurrentlyBlocked() {
                    print("現在ブロックされています")
                } else {
                    print("現在ブロックされていません")
                }
            }

            ScrollView { // ScrollView を追加
                VStack(alignment: .leading) { // VStack を ScrollView 内に配置
                    ForEach(WeekDays.allCases) { day in
                        HStack {
                            Text(day.displayName)
                            Spacer()
                            // チェックボックス形式で選択状態を表示
                            if manager.weekDays.contains(day) {
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
                            if manager.weekDays.contains(day) {
                                manager.weekDays.removeAll { $0 == day }
                            } else {
                                manager.weekDays.append(day)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 200) // 必要に応じて高さを調整
            .border(Color.gray, width: 1)
        }
        .familyActivityPicker(isPresented: $showActivityPicker, selection: $manager.discouragedSelections)

    }

    private func startMonitoringWithEvent() {
        print("Start Monitoring with DeviceActivityEvent")
//        let weekDays: [WeekDays] = [.mon, .tue, .sat]

        let result = manager.savedSelection()
        guard let startTime = result.startTime,
                  let endTime = result.endTime,
                  let weekDays = result.weekDays else { // weekDays を取得
                print("開始時間、終了時間、または曜日が見つかりません")
                return
            }

        let startComponents = Calendar.current.dateComponents([.hour, .minute], from: startTime)
        var endComponents = Calendar.current.dateComponents([.hour, .minute], from: endTime)

        // 開始から終了までの時間を計算
        let elapsedComponents = Calendar.current.dateComponents([.hour, .minute], from: startTime, to: endTime)
//        print("hour:\(String(describing: elapsedComponents.hour)) minute:\(String(describing: elapsedComponents.minute))")
        
        // 全体の経過分数を計算
        let elapsedMinutes = (elapsedComponents.hour ?? 0) * 60 + (elapsedComponents.minute ?? 0)

        print("経過時間（分単位）: \(elapsedMinutes)")

        // warningTime を設定
        var warningTime = DateComponents(minute: 0)
        //15分未満の場合（DeviceActivityScheduleは15分間隔を空けないといけないので）
        if elapsedMinutes > 0 && elapsedMinutes < 15 {
            warningTime = DateComponents(minute: 15 - elapsedMinutes)

            // endComponents を startComponents の 15 分後に設定
            if let startDate = Calendar.current.date(from: startComponents) {
                let adjustedEndDate = Calendar.current.date(byAdding: .minute, value: 15, to: startDate)
                endComponents = Calendar.current.dateComponents([.hour, .minute], from: adjustedEndDate ?? startDate)
            }
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
        for weekDay in weekDays {
            let scheduleName = DeviceActivityName("\(weekDay)Schedule")
            // 1. 既存のスケジュールを停止
            center.stopMonitoring([scheduleName])

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

