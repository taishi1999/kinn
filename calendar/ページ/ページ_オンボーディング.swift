import SwiftUI
import Combine
import SwiftSVG
import FamilyControls

//enum OnboardingStep {
//    case blockAppPicker, timeSetting, characterCountSetting
//}
import SwiftUI
import UserNotifications

struct オンボ_通知許可: View {
//    @State private var isLoading = false
    @Binding var isLoading: Bool
    @Binding var path: NavigationPath
    @Environment(\.dismiss) private var dismiss
    @State private var isNotificationAuthorized = false
    @Environment(\.scenePhase) private var scenePhase // 🔹 scenePhase を追加
    var onComplete: () -> Void
    @State private var showAlert = false
    @State private var alertMessage = ""
    @ObservedObject var diaryTaskManager: DiaryTaskManager

    var body: some View {
        VStack(spacing: 0) {
//            Spacer()
//                .frame(height: 16)

            VStack(spacing:16) {
                Text("🔔")
                    .font(.system(size: 64))

                Text("通知を許可してください")
                    .font(.title2)
                    .fontWeight(.bold)
//                    .multilineTextAlignment(.center)
//                    .frame(maxWidth: .infinity)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            Spacer()
//                .frame(height: 16)



//            Spacer().frame(height: 24) // 🔹 16 → 24 に変更

            // 通知許可の状態に応じてボタンの挙動を変更
//            パーツ_ボタン_ローディング(isLoading: $isLoading,ボタンテキスト: "完了", action: {
                パーツ_共通ボタン(
                    ボタンテキスト: isNotificationAuthorized ? "完了" : "許可する", // 🔹 「設定を開く」→「許可する」に変更
                    isLoading: isLoading,
                    action: {
                        if isNotificationAuthorized {

                            isLoading=true
                            diaryTaskManager.updateTask() { result in
                                DispatchQueue.main.async {
                                    isLoading = false // 🔹 どのケースでも共通で解除

                                    switch result {
                                    case .success:
                                        print("✅ タスクの更新が成功しました！")
                                        onComplete()
                                    case .failure(let error):
                                        print("❌ タスクの更新に失敗: \(error.localizedDescription)")
                                        alertMessage = "エラーが発生しました: \(error.localizedDescription)"
                                        showAlert = true
                                    }
                                }
                            }

                        } else {
                        openSettings() // 拒否されたら設定を開く
                    }
                }
            )

            Spacer().frame(height: 16)
        }
        .padding(.horizontal, 20)
        .onAppear {
            requestNotificationPermission()
            print("count: \(path.count)")
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                isLoading = true
                checkNotificationAuthorization()
            }
        }
    }

    /// **通知のリクエストを行い、許可状態を取得**
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ 通知の許可リクエスト中にエラーが発生: \(error.localizedDescription)")
                    self.isNotificationAuthorized = false
                } else {
                    self.isNotificationAuthorized = granted
                    if granted {
                        print("✅ 通知が許可されました")
                    } else {
                        print("⚠️ 通知の許可が拒否されました")
                    }
                }
            }
        }
    }

    /// **現在の通知の許可状態を確認**
    private func checkNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                let isAuthorized = settings.authorizationStatus == .authorized
                self.isNotificationAuthorized = isAuthorized // 🔹 許可済みなら true、拒否なら false
                print("🔍 通知の許可状態: \(isAuthorized ? "✅ 許可済み" : "❌ 拒否")")
                isLoading = false
            }
        }
    }

    /// **設定アプリを開く**
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

//#Preview {
//    NavigationStack {
//        オンボ_通知許可(path: .constant(NavigationPath()))
//    }
//}



struct OnboardingView: View {
    @ObservedObject var diaryTaskManager: DiaryTaskManager
    @ObservedObject var viewModel: TaskViewModel
    //    @State private var path = NavigationPath()
    @Binding var path: NavigationPath
//    @State private var currentStep: OnboardingStep = .blockAppPicker

    //    @State private var activitySelection = FamilyActivitySelection()
    @State private var navigateToNext = false // 次の画面への遷移フラグ
    var onComplete: () -> Void
    @StateObject private var taskData = TaskData() // データを保持する
    @State private var isLoading = false // ナビゲーションを有効/無効にするフラグ
    @State private var showAlert = false // アラート表示フラグ

    //    @ObservedObject var diaryTaskManager = DiaryTaskManager.shared

    @ObservedObject var center = AuthorizationCenter.shared

    //    init(viewModel: TaskViewModel, onComplete: @escaping () -> Void) {
    //        self.viewModel = viewModel
    //        self.onComplete = onComplete
    //        self.path = NavigationPath(["A"])
    //
    //        let status = center.authorizationStatus
    //            print("Authorization Status: \(status)")
    //
    //            if status == .approved {
    //                print("approveです")
    //                _path = State(initialValue: NavigationPath(["A"]))
    //            } else {
    //                print("elseです")
    //                _path = State(initialValue: NavigationPath())
    //            }
    //    }

    var body: some View {
        NavigationStack(path: $path) {
            //            オンボ_認証(path: .constant(path), center: center)
            オンボ_認証(
                path: Binding<NavigationPath?>(
                    get: { path },
                    set: { newValue in
                        if let newValue = newValue {
                            path = newValue
                        } else {
                            path = NavigationPath() // 初期化
                        }
                    }
                ),
                center: center,onComplete: {path.append("A")})
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "A":
                    オンボ_アプリピッカー(/*activitySelection: $activitySelection,*/ /*taskData: taskData,*/ onComplete: onComplete, path: $path,diaryTaskManager: diaryTaskManager)
                        .navigationBarBackButtonHidden(true)//上記バー非表示
                case "B":
                    オンボ_時間設定(path: $path,diaryTaskManager: diaryTaskManager)
//                        .navigationBarBackButtonHidden(true)
                case "C":
                    オンボ_文字数設定(path: $path, /*updateTask: updateTask,saveTask: saveTask,*/onComplete: onComplete,diaryTaskManager: diaryTaskManager /*, isNavigationEnabled: $isNavigationEnabled*/)
//                        .navigationBarBackButtonHidden(true)
                case "D":オンボ_通知許可(isLoading: $isLoading,path: $path,onComplete: onComplete,diaryTaskManager: diaryTaskManager)

                default:
                    EmptyView()
                }
            }
        }
        .disabled(isLoading)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("エラー"),
                message: Text("alertMessage"),
                dismissButton: .default(Text("OK"))
            )
        }
        //        .onAppear {
        //            print("Initial Path: \(path)")
        //            path.append("A")
        //            print("Updated Path: \(path)")
        //        }
    }

    // 保存処理と完了処理をまとめた関数
//    private func saveTask() {
//        diaryTaskManager.diaryTask.selectionID = "selection_1"
//
//        diaryTaskManager.saveDiaryTask(
//            diaryTaskManager.diaryTask,
//            selection: diaryTaskManager.selection,
//            taskKey: "diary",
//            selectionKey: "selection_1"
//        )
//
////        onComplete() // 完了後に画面を閉じる
//    }

    // タスク更新メソッド
//    private func updateTask(completion: @escaping (Bool) -> Void) {
//        isLoading = true
//        viewModel.updateTask(
//            taskType: taskData.taskType,
//            startTime: taskData.startTime,
//            endTime: taskData.endTime,
//            repeatDays: taskData.repeatDays,
//            characterCount: taskData.characterCount,
//            context: viewModel.coredata_MyTask.managedObjectContext!
//        ) { success in
//            DispatchQueue.main.async {
//                isLoading = false
//                if success {
//                    print("Task updated successfully in OnboardingView")
//                    onComplete() // Onboarding完了処理
//                } else {
//                    print("Failed to update task in OnboardingView")
//                    showAlert = true
//                }
//                completion(success)
//            }
//        }
//    }
}

struct オンボ_認証: View {
    @State private var isLoading = false
    //    let center = AuthorizationCenter.shared
    //    @Binding var path: NavigationPath
    @Binding var path: NavigationPath?

    @State private var navigateToNext = false
    @State private var cancellable: AnyCancellable? // Combineのキャンセラ
    @ObservedObject var center: AuthorizationCenter
    @Environment(\.dismiss) private var dismiss
    var onComplete: () -> Void

    //nil許容のために必要
    init(path: Binding<NavigationPath?> = .constant(nil), center: AuthorizationCenter, onComplete: @escaping () -> Void) {
        self._path = path
        self.center = center
        self.onComplete = onComplete // 🔹 `onComplete` を受け取る
    }

    var body: some View {
        VStack(spacing: 0) {
            //
            Spacer()
                .frame(height: 16)
            Image("screentime_simple")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
            Spacer()
                .frame(height: 16)
            VStack() {
                Text("スクリーンタイムへのアクセスを\n許可してください")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }

            ZStack {
                VStack {
                    Spacer().frame(height: 16)
                    if path != nil {
                        Button("Go to A") {
                            print("Navigating to A")
                            path!.append("A")
                            print("Current path: \(String(describing: path))") // デバッグ用
                        }
                    }
                    //                    Button("Go to A") {
                    //                        print("Navigating to A")
                    //                        path.append("A")
                    //                        print("Current path: \(path)") // デバッグ用
                    //                    }

                    //                    if path.wrappedValue != nil {
                    //                        Button("Go to A") {
                    //                            if var unwrappedPath = path.wrappedValue {
                    //                                unwrappedPath.append("A")
                    //                                path.wrappedValue = unwrappedPath // 再代入
                    //                            }
                    //                        }
                    //                    }
                    Text("アプリをブロックするには\nスクリーンタイムへの許可が必要です")
                        .font(.callout)
                    //                            .fontWeight(.bold)
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    Spacer().frame(height: 16)
                    パーツ_共通ボタン(ボタンテキスト: "許可する",isLoading: isLoading, action: {
                        Task {
                            do {
                                isLoading = true
                                try await center.requestAuthorization(for: .individual)

                                onComplete()
                            } catch {
                                print("Failed to get authorization: \(error)")
                                isLoading = false
                            }
                        }
                    })
                    Spacer().frame(height: 16)
                }
                .background(Color(.systemBackground))
            }

            //            Spacer()
            //                .frame(height: 20)
        }
        .padding(.horizontal, 20)
        //        .task {
        //            await checkAuthorizationAndNavigate()
        //        }
    }

//    private func checkAuthorizationAndNavigate() async {
//        // 非同期で認証状態を確認
//        do {
//            try await center.requestAuthorization(for: .individual)
//
//            //                DispatchQueue.main.async {
//            //                    if center.authorizationStatus == .approved {
//            //                        print("approveです")
//            //                        path?.append("A")
//            //                    }
//            //                    else{
//            //                        print("elseです")
//            //                    }
//            //                }
//        } catch {
//            print("認証リクエスト中にエラーが発生しました: \(error)")
//        }
//    }

    //    private func startMonitoringAuthorizationStatus() {
    //            cancellable = center.$authorizationStatus
    //                .sink { status in
    //                    print("認証状態が変更されました: \(status)")
    //                    // 認証状態が確定したら isLoading を終了
    //                    isLoading = false
    //                }
    //        }
}

struct オンボ_アプリピッカー: View {
    @State private var isPresented = false
    //    @Binding var activitySelection: FamilyActivitySelection
    //    @ObservedObject var taskData: TaskData
    var onComplete: () -> Void
    //    var onNext: () -> Void
    @Binding var path: NavigationPath
    @ObservedObject var diaryTaskManager: DiaryTaskManager

    @State private var navigateToNext = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 16)
            FamilyActivityPicker(selection: $diaryTaskManager.selection)
//            Image("iPhone15_Pro_app_picker")
//                .resizable()
//                .scaledToFit()
//                .frame(maxWidth: .infinity)
            Spacer()
                .frame(height: 16)
            VStack(spacing: 8) {
//                Text("ブロックしたいアプリを\n選択しましょう")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .multilineTextAlignment(.center)
//                    .frame(maxWidth: .infinity)
            }
            ZStack {
                VStack(spacing: 0) {
                    VStack {
                        Spacer().frame(height: 8)

//                        Button("Go to B") {
//                            path.append("B") // 次の画面へ遷移
//                        }
                        Text("スクリーンタイムでブロックするアプリを選択しましょう。")
                            .font(.callout)
                        //                            .fontWeight(.bold)
                            .foregroundStyle(Color.secondary)
//                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)

                        Spacer().frame(height: 16)

                        パーツ_共通ボタン(ボタンテキスト: "アプリを選択", action: {
//                            isPresented = true
                            path.append("B")
                        })
//                        .familyActivityPicker(
//                            isPresented: $isPresented,
//                            selection: $diaryTaskManager.selection
//                        )
//                        .onChange(of: diaryTaskManager.selection) { newSelection in
//                            //                                print("選択されたアプリ: \(newSelection.applications)")
//                            //                                print("選択されたカテゴリ: \(newSelection.categories)")
//                            //                                print("選択されたウェブドメイン: \(newSelection.webDomains)")
//                            if isSelectionExist(initialSelection: newSelection){
//                                path.append("B")
//                            }
//                            //                                if !newSelection.applications.isEmpty ||
//                            //                                            !newSelection.categories.isEmpty ||
//                            //                                            !newSelection.webDomains.isEmpty {
//                            //                                            path.append("B")
//                            //                                        }
//                        }
                        Spacer().frame(height: 16)

                        //                        Text("a")
                        //                            .foregroundStyle(.primary)
                        //                            .opacity(0)
                        //                            .padding(.vertical, 20)
                    }
                    .background(Color(.systemBackground))
                }
            }

            //            Spacer()
            //                .frame(height: 20)
        }
        .padding(.horizontal, 20)
    }
}

func isSelectionExist(initialSelection: FamilyActivitySelection) -> Bool {
    return !initialSelection.applications.isEmpty ||
    !initialSelection.categories.isEmpty ||
    !initialSelection.webDomains.isEmpty
}

struct オンボ_時間設定: View {
    //    @ObservedObject var taskData: TaskData
    @Binding var path: NavigationPath
    @ObservedObject var diaryTaskManager: DiaryTaskManager

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height:20)

            VStack(alignment: .leading, spacing: 8) {
                Text("日記を書く時間を設定しましょう")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading) // 左揃えにする
                    .frame(maxWidth: .infinity, alignment: .leading) // 左寄せのフレーム設定

                Text("この時間帯でスクリーンブロックが作動します。")
                //                    .fontWeight(.bold)
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading) // 左寄せのフレーム設定
            }.padding(.horizontal, 20)

            Form {
                //                Spacer()
                //                    .frame(height:40)
                パーツ_時刻選択(開始時刻: $diaryTaskManager.diaryTask.startTime, 終了時刻: $diaryTaskManager.diaryTask.endTime)
                //                .background(Color.darkButton_normal)
                //                .cornerRadius(12)
                //            Spacer()
                //                .frame(height:32)
                パーツ_曜日選択ビュー(繰り返し曜日: $diaryTaskManager.diaryTask.weekDays)
            }


            //                .background(Color.darkButton_normal)
            //                .cornerRadius(12)
            Spacer()
            //            Spacer()
            //                .frame(height: 40)

            ZStack {
                VStack{
                    パーツ_共通ボタン(ボタンテキスト: "つぎへ", action: {path.append("C")})
                    Spacer().frame(height: 16)
                }
                .background(Color(.systemBackground))
            }
            //            Spacer()
            //                .frame(height: 20)

        }
        //        .padding(.horizontal, 20)
    }
}

struct オンボ_文字数設定: View {
    @FocusState private var isFocused: Bool
    private let maxLength: Int = 4
//    @Binding var isLoading: Bool
    @Binding var path: NavigationPath
//    var updateTask: (@escaping (Bool) -> Void) -> Void
//    var saveTask: () -> Void
    var onComplete: () -> Void
    @State private var showAlert = false
    @State private var alertMessage = ""
    @ObservedObject var diaryTaskManager: DiaryTaskManager
    

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 20)

            VStack(alignment: .leading, spacing: 8) {
                Text("日記の文字数を指定しましょう")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("まずは気軽に、短い日記から始めてみましょう。")
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading) // 左寄せのフレーム設定
            }

            VStack {
                Spacer()
                HStack(alignment: .bottom, spacing: 4) {
                    TextField(
                        "1",
                        text: Binding<String>(
                            get: { String(diaryTaskManager.diaryTask.characterCount) },
                            set: {
                                diaryTaskManager.diaryTask.characterCount = Int($0.prefix(maxLength)) ?? 0
                            }
                        )
                    )
                    .keyboardType(.numberPad)
                    .fixedSize()
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }
                    Text("文字")
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 6)
                }
                Spacer()
            }
            VStack {
                パーツ_共通ボタン(ボタンテキスト: "完了", action: {
                    path.append("D")
//                    diaryTaskManager.updateTask(){ result in
//                        switch result {
//                        case .success:
//                            print("✅ タスクの更新が成功しました！")
//                            onComplete()
//                        case .failure(let error):
//                            print("❌ タスクの更新に失敗: \(error.localizedDescription)")
//                            alertMessage = "エラーが発生しました: \(error.localizedDescription)"
//                            showAlert = true
//                        }
//                    }


//                    saveTask()
//                    diaryTaskManager.startMonitoring()
////                    NotificationScheduler.shared.scheduleNotificationInFiveSeconds()
//                    
//                    let weekDays: [WeekDays] = convertToWeekDays(from: diaryTaskManager.diaryTask.weekDays)
//                    let rawValues = weekDays.map { $0.rawValue }
//                    NotificationScheduler.shared.scheduleNotification(startTime: diaryTaskManager.diaryTask.startTime, weekdays: rawValues)


                }
                )
                Spacer().frame(height: 16)
            }
        }
        .padding(.horizontal, 20)
    }
}

import UserNotifications

func printAllPendingNotifications() {
    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
        if requests.isEmpty {
            print("🚫 No pending notifications")
        } else {
            for request in requests {
                print("----------------------")
                print("Identifier: \(request.identifier)")
                print("Content:")
                print("  Title: \(request.content.title)")
                print("  Body: \(request.content.body)")
                print("  Sound: \(String(describing: request.content.sound))")
                if let trigger = request.trigger {
                    print("Trigger: \(trigger)")
                } else {
                    print("Trigger: none")
                }
            }
        }
    }
}

import DeviceActivity

func cancelAllScreenTimeBlocks() {
    let center = DeviceActivityCenter()
    let allScheduledActivities = center.activities

    // すべてのアクティビティの監視を停止
    center.stopMonitoring(allScheduledActivities)

    print("🛑 スクリーンタイムのブロックを無効にしました")
}

/// すべてのスケジュールされたアクティビティを取得して出力
func getAllScheduledActivities() -> [DeviceActivityName] {
    let center = DeviceActivityCenter()
    let allScheduledActivities = center.activities

    if allScheduledActivities.isEmpty {
        print("[getAllScheduledActivities]スケジュールされたアクティビティはありません")
    } else {
        print("--[getAllScheduledActivities]--")
        allScheduledActivities.forEach { activity in
            print("全てのActivityの名前: \(activity.rawValue)")

            // スケジュールを取得
            if let schedule = center.schedule(for: activity) {
                if let startWeekday = schedule.intervalStart.weekday,
                   let endWeekday = schedule.intervalEnd.weekday {
                    print("開始曜日: \(startWeekday), 終了曜日: \(endWeekday)")
                } else {
                    print("曜日情報が取得できませんでした")
                }
            } else {
                print("スケジュールが見つかりません")
            }
        }
        print("--[getAllScheduledActivities]--")
    }

    return allScheduledActivities
}


func handleScreenTimeAuthorization() -> Bool {
    let status = AuthorizationCenter.shared.authorizationStatus // `await` は不要

    if status == .approved {
        print("✅ Screen Time 認証済み - スケジュールを確認")
        return true
    } else {
        print("⚠️ Screen Time 未認証 - 認証リクエストを実行")
        return false
    }
}



//import DeviceActivity

//screentimeのスケジュールを予約
//func startMonitoring(diaryTaskManager: DiaryTaskManager) -> Result<Bool, ScheduleError> {
//    let center = DeviceActivityCenter()
//
//    //曜日配列を数字配列に変換
////    let weekDays: [WeekDays] = diaryTaskManager.diaryTask.weekDays.compactMap { weekDayString in
////        WeekDays.allCases.first { $0.shortName == weekDayString }
////    }
//    let weekDays: [WeekDays] = convertToWeekDays(from: diaryTaskManager.diaryTask.weekDays)
//    let rawValues = weekDays.map { $0.rawValue }
//    print("Raw values: \(rawValues)")
//    print("diaryTaskManager.diaryTask.weekDays:\(diaryTaskManager.diaryTask.weekDays)")
//
//    //指定した曜日以外のモニタリングをストップ------------------------------
//    // 現在のスケジュールを取得
//    let allScheduledActivities = center.activities
//    allScheduledActivities.forEach { activity in
//        print("全てのActivityの名前: \(activity.rawValue)")
//    }
//    //あとでこれで代替できるかテスト
////    let allScheduledActivities = getAllScheduledActivities()
//
//    // 選択された曜日に関連しないスケジュールを取得
//    let selectedScheduleNames = weekDays.map { DeviceActivityName("diary_\($0)") }
//    let schedulesToRemove = allScheduledActivities.filter { !selectedScheduleNames.contains($0) }
//    print("スケジュールを削除する必要がある項目: \(schedulesToRemove)")
//
//    // 各スケジュール名を詳細に出力（配列内の要素を個別に表示）
//    for schedule in schedulesToRemove {
//        print("削除対象のスケジュール: \(schedule)")
//    }
//
//    center.stopMonitoring(schedulesToRemove)
//    //--------------------------------------------------------------
//
//
//    // 開始時刻と終了時刻の DateComponents を取得
//    let startComponents = Calendar.current.dateComponents([.hour, .minute], from: diaryTaskManager.diaryTask.startTime)
//    var endComponents = Calendar.current.dateComponents([.hour, .minute], from: diaryTaskManager.diaryTask.endTime)
//
//    // 経過時間を計算
//    let elapsedComponents = calculateElapsedTime(from: diaryTaskManager.diaryTask.startTime, to: diaryTaskManager.diaryTask.endTime)
//    let elapsedMinutes = (elapsedComponents.hour ?? 0) * 60 + (elapsedComponents.minute ?? 0)
//
//    // 警告時間の初期値
//    var warningTime = DateComponents(minute: 0)
//
//    // 経過時間をログに出力
//    print("経過時間（分単位）: \(elapsedMinutes)")
//
//    // 経過時間が0より大きく15分未満の場合の処理
//    if elapsedMinutes > 0 && elapsedMinutes < 15 {
//        // 警告時間を設定
//        warningTime = DateComponents(minute: 15 - elapsedMinutes)
//
//        // 終了時刻を開始時刻の15分後に調整
//        if let startDate = Calendar.current.date(from: startComponents) {
//            let adjustedEndDate = Calendar.current.date(byAdding: .minute, value: 15, to: startDate)
//            endComponents = Calendar.current.dateComponents([.hour, .minute], from: adjustedEndDate ?? startDate)
//        }
//    }
//
//    // endComponents をログに出力
////    print("Start Components: \(startComponents)")
////    print("warningTime: \(warningTime)")
////    print("Adjusted End Components: \(endComponents)")
//
//    var hasSucceeded = false
//    for weekDay in weekDays {
//        let scheduleName = DeviceActivityName("diary_\(weekDay)")
//        print("Schedule Name: \(scheduleName.rawValue)")
//
//
//        var startWithWeekday = startComponents
//        var endWithWeekday = endComponents
//        //開始曜日数字を設定
//        startWithWeekday.weekday = weekDay.rawValue
//        //終了曜日数字を設定
//        //翌日になった場合、次の曜日数字を設定
//        if elapsedMinutes <= 0 {
//            // 次の曜日を計算
//            let nextWeekdayRawValue = (weekDay.rawValue % 7) + 1
//            endWithWeekday.weekday = nextWeekdayRawValue
//            print("次の曜日: \(nextWeekdayRawValue)")
//        } else {
//            // 同じ曜日のまま
//            endWithWeekday.weekday = weekDay.rawValue
//        }
//
//        let schedule = DeviceActivitySchedule(
//            intervalStart: startWithWeekday,
//            intervalEnd: endWithWeekday,
//            repeats: true, // 毎週繰り返し
//            warningTime: warningTime
//        )
//
//        do {
//            try center.startMonitoring(scheduleName, during: schedule)
//            print("\(weekDay) のスケジュールが登録されました")
//            hasSucceeded=true
////            return .success(true)
//        } catch let error as DeviceActivityCenter.MonitoringError {
//                    print("⚠️ DeviceActivityCenter のエラー: \(error)")
//                    switch error {
//                    case .excessiveActivities:
//                        return .failure(.excessiveActivities)
//                    case .intervalTooLong:
//                        return .failure(.intervalTooLong)
//                    case .intervalTooShort:
//                        return .failure(.intervalTooShort)
//                    case .invalidDateComponents:
//                        return .failure(.invalidDateComponents)
//                    case .unauthorized:
//                        return .failure(.unauthorized)
//                    @unknown default:
//                        return .failure(.unknownError("未知のエラー: \(error)"))
//                    }
//                } catch {
//                    print("⚠️ 不明なエラー: \(error.localizedDescription)")
//                    return .failure(.unknownError(error.localizedDescription))
//                }
//    }
//
//    // 成功した場合は .success(true) を返す
//        if hasSucceeded {
//            return .success(true)
//        }
//
//        // weekDays が空だった場合や、例外処理がないエラーが発生した場合のフォールバック
//        return .failure(.unknownError("Unexpected error"))
//}


//struct OnboardingView_Previews: PreviewProvider {
//    static var previews: some View {
//        @StateObject var taskData = TaskData() // データを保持する
//
//        OnboardingView(onComplete: {})
//
//        オンボ_時間設定(taskData: taskData)
//
//        オンボ_文字数設定(taskData: taskData)
//    }
//}


struct ビュー_ブロック状態監視: View {
    @StateObject private var 状態監視: ブロック状態監視

    init(startTime: Date, endTime: Date, repeatDaysString: String) {
        let repeatDays = repeatDaysString
            .split(separator: ",")
            .compactMap { Int($0) }

        _状態監視 = StateObject(wrappedValue: ブロック状態監視(
            startTime: startTime,
            endTime: endTime,
            repeatDays: repeatDays
        ))
    }

    var body: some View {
        VStack {
            Text("現在のブロック状態:")
                .font(.headline)

            Text(状態監視.現在の状態Text)
                .font(.largeTitle)
                .padding()

            Text("次の状態変化までの残り時間: \(状態監視.残り時間Text)")
                .font(.title2)
                .padding()

            Spacer()
        }
        .padding()
    }
}

// プレビュー用コード
struct ビュー_ブロック状態監視_Previews: PreviewProvider {
    static var previews: some View {
        ビュー_ブロック状態監視(
            startTime: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!,
            endTime: Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Date())!,
            repeatDaysString: "0,1,2,3,4,5,6"
        )
    }
}

//struct CustomNavigationBar: View {
//    let title: String
//    let onBack: (() -> Void)?
//    let onAction: (() -> Void)?
//
//    var body: some View {
//        HStack {
//            if let onBack = onBack {
//                Button(action: onBack) {
//                    Image(systemName: "chevron.left")
//                        .foregroundColor(.white)
//                }
//            } else {
//                Spacer()
//            }
//
//            Spacer()
//
//            Text(title)
//                .font(.headline)
//                .foregroundColor(.white)
//
//            Spacer()
//
//            if let onAction = onAction {
//                Button(action: onAction) {
//                    Image(systemName: "ellipsis")
//                        .foregroundColor(.white)
//                }
//            } else {
//                Spacer()
//            }
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 16) // 上下のパディングを設定
//        .background(Color.blue)
//    }
//}

//struct CustomNavigationBar_Previews: PreviewProvider {
//    static var previews: some View {
//
//        オンボ_時間設定()
//
//        //            CustomNavigationBar(
//        //                title: "プレビュー",
//        //                onBack: nil,
//        //                onAction: nil
//        //            )
//        //            .previewDisplayName("Without Buttons")
//
//            .previewLayout(.sizeThatFits) // サイズを内容に合わせる
//    }
//}
