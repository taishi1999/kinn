import SwiftUI
import FamilyControls
import CoreData


struct ページ_タスク作成_ver2: View {
    @State private var showAlert: Bool = false
    @State private var isPresented = false
    @State private var isLoading = false
    @State private var isEdited = false
    @State private var isDialogVisible = false
    @State private var errorMessage: String = ""
    @AppStorage("task_disabled") private var localIsDisabled: Bool = false // 🔹 `@AppStorage` に変更
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var diaryTaskManager = DiaryTaskManager.shared // 🔹 @ObservedObject に変更

    @State private var initialTask: DiaryTask?
    @State private var initialSelection: FamilyActivitySelection?
//    init() {
//        _localIsDisabled = State(initialValue: UserDefaults.standard.bool(forKey: "task_disabled"))
//    }

    var body: some View {
        ZStack {
            NavigationStack {
                Form {
                    Section {
                        パーツ_文字数入力欄_v2(characterCount: Binding<Int>(
                            get: { diaryTaskManager.diaryTask.characterCount },
                            set: { diaryTaskManager.diaryTask.characterCount = $0 }
                        ))
                    }
                    Section {
                        パーツ_時刻選択(
                            開始時刻: Binding<Date>(
                                get: { diaryTaskManager.diaryTask.startTime },
                                set: { diaryTaskManager.diaryTask.startTime = $0 }
                            ),
                            終了時刻: Binding<Date>(
                                get: { diaryTaskManager.diaryTask.endTime },
                                set: { diaryTaskManager.diaryTask.endTime = $0 }
                            )
                        )
                        パーツ_曜日選択ビュー(
                            繰り返し曜日: Binding<[String]>(
                                get: { diaryTaskManager.diaryTask.weekDays },
                                set: { diaryTaskManager.diaryTask.weekDays = $0 }
                            )
                        )
                    }

                    Section{
                        パーツ_アプリ選択(
                            isPresented: $isPresented,
                            selection: Binding<FamilyActivitySelection>(
                                get: { diaryTaskManager.selection },
                                set: { diaryTaskManager.selection = $0 }
                            )
                        )
                    }
                }
                .disabled(localIsDisabled)
                .opacity(localIsDisabled ? 0.5 : 1.0)
            }

            if !localIsDisabled {
                VStack {
                    Spacer()
                    パーツ_ボタン_ローディング(
                        isLoading: $isLoading,
                        isDisabled: !isEdited,
                        ボタンテキスト: "保存"
                    ) {
                        diaryTaskManager.updateTask(){ result in
                            switch result {
                            case .success:
                                print("✅ タスクの更新が成功しました！")
                            case .failure(let error):
                                print("❌ タスクの更新に失敗: \(error.localizedDescription)")
                            }
                        }


                        dismiss()
//                        diaryTaskManager.diaryTask.selectionID = "selection_1"
//
//                        diaryTaskManager.saveDiaryTask(
//                            diaryTaskManager.diaryTask,
//                            selection: diaryTaskManager.selection,
//                            taskKey: "diary",
//                            selectionKey: "selection_1"
//                        )
//
//                        print("✅ 保存後の diaryTask: \(diaryTaskManager.diaryTask)")
//
//                        startMonitoring(diaryTaskManager: diaryTaskManager)
//
//                        let weekDays: [WeekDays] = convertToWeekDays(from: diaryTaskManager.diaryTask.weekDays)
//                        let rawValues = weekDays.map { $0.rawValue }
//                        NotificationScheduler.shared.scheduleNotification(
//                            startTime: diaryTaskManager.diaryTask.startTime,
//                            weekdays: rawValues
//                        )
//
//                        NotificationScheduler.shared.scheduleNotification(startTime: diaryTaskManager.diaryTask.startTime, weekdays: rawValues)
//                        
//                        diaryTaskManager.startCountdown()  // ✅ 設定変更後に interval を更新
//                        dismiss()
                    }
                }
                .padding(.horizontal)
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isDialogVisible = true
                }) {
                    Image(systemName: "ellipsis")
//                        .resizable() // サイズ調整を有効にする
                        .frame(width: 24, height: 24)
                        .foregroundColor(.primary)
                        .padding()
                }
                .confirmationDialog(
                            "", // タイトルを空にする
                            isPresented: $isDialogVisible,
                            titleVisibility: .hidden // タイトルを完全に非表示
                        ) {
                            if localIsDisabled {
                                Button("設定をオン") {
                                    diaryTaskManager.updateTask(){ result in
                                        switch result {
                                        case .success:
                                            print("✅ タスクの更新が成功しました！")
                                        case .failure(let error):
                                            print("❌ タスクの更新に失敗: \(error.localizedDescription)")
                                        }
                                    }


                                    localIsDisabled = false
                                }
                            } else {
                                Button("設定をオフにする", role: .destructive) {
                                    NotificationScheduler.shared.cancelAllScheduledNotifications() // 🔹 ローカル通知を削除
                                    cancelAllScreenTimeBlocks()
                                    
                                    localIsDisabled = true
                                }
                            }
//                            Button("キャンセル", role: .cancel) { }
                        }
//                buildMenuButton()
//                MenuButtonView(isDisabled: $localIsDisabled)
            }
        }
        .navigationTitle("日記の設定")

        .onAppear {
//            print("🔄 ページ_タスク作成_ver2 が再描画されました")
            //更新
            if let loadedTask = DiaryTaskManager.loadDiaryTask(forKey: "diary") {
                    diaryTaskManager.diaryTask = loadedTask
                }
//            print("📌 onAppear 時点の diaryTask: \(diaryTaskManager.diaryTask)")
            initialTask = diaryTaskManager.diaryTask
            initialSelection = diaryTaskManager.selection
        }
        .onDisappear {
            diaryTaskManager.diaryTask = initialTask ?? diaryTaskManager.diaryTask
            diaryTaskManager.selection = initialSelection ?? diaryTaskManager.selection
        }
        .onChange(of: diaryTaskManager.diaryTask) { _ in
            print("diaryTask が変更されました")
            checkForChanges()
        }
        .onChange(of: diaryTaskManager.selection) { _ in
            print("selection が変更されました")
            checkForChanges()
        }
        .alert("エラーが発生しました", isPresented: $showAlert, actions: {
                    Button("OK", role: .cancel) { }
                }, message: {
                    Text(errorMessage)
                })
//        .onChange(of: localIsDisabled) { newValue in
//            print("🔄 タスクの有効状態が変更されました: \(newValue ? "無効" : "有効")")
//
//            if newValue {
//                // タスクを無効にした場合
//                NotificationScheduler.shared.cancelAllScheduledNotifications() // 🔹 ローカル通知を削除
//                cancelAllScreenTimeBlocks()
////                stopScreenTimeMonitoring() // 🔹 スクリーンタイムのブロックを停止
//            } else {
//                diaryTaskManager.updateTask()
////                // タスクを有効にした場合
////                diaryTaskManager.diaryTask.selectionID = "selection_1"
////
////                diaryTaskManager.saveDiaryTask(
////                    diaryTaskManager.diaryTask,
////                    selection: diaryTaskManager.selection,
////                    taskKey: "diary",
////                    selectionKey: "selection_1"
////                )
////
////                print("✅ 保存後の diaryTask: \(diaryTaskManager.diaryTask)")
////
//////                startMonitoring(diaryTaskManager: diaryTaskManager)
////                let result = startMonitoring(diaryTaskManager: diaryTaskManager)
////                // 結果を出力
////                switch result {
////                case .success(let success):
////                    print("✅ 成功: \(success)")
////                case .failure(let error):
////                    print("❌ エラー: \(error)")
////                }
////
////                let weekDays: [WeekDays] = convertToWeekDays(from: diaryTaskManager.diaryTask.weekDays)
////                let rawValues = weekDays.map { $0.rawValue }
////                NotificationScheduler.shared.scheduleNotification(
////                    startTime: diaryTaskManager.diaryTask.startTime,
////                    weekdays: rawValues
////                )
////
////                diaryTaskManager.startCountdown()
//            }
//        }


    }
    // ✅ `@ViewBuilder` で `Menu` を切り離す
    @ViewBuilder
    private func buildMenuButton() -> some View {
        MenuButtonView()
    }


    private func checkForChanges() {
        guard let initialTask = initialTask, let initialSelection = initialSelection else { return }

        isEdited = (
            DiaryTaskManager.shared.diaryTask.characterCount != initialTask.characterCount ||
            DiaryTaskManager.shared.diaryTask.startTime != initialTask.startTime ||
            DiaryTaskManager.shared.diaryTask.endTime != initialTask.endTime ||
            Set(DiaryTaskManager.shared.diaryTask.weekDays) != Set(initialTask.weekDays) ||
            DiaryTaskManager.shared.selection != initialSelection
        )
    }
}

struct MenuButtonView: View {
    @AppStorage("task_disabled") private var isDisabled: Bool = false

    var body: some View {
        
        Menu {
            Button(role: isDisabled ? nil : .destructive) {
                withAnimation(nil) { // ✅ アニメーションを無効化
                    isDisabled.toggle()
                }
            } label: {
                Text(isDisabled ? "再開する" : "一時停止")
            }
            
        } label: {
            Image(systemName: "ellipsis")
                .foregroundColor(.white)
        }
    }
}





//struct ページ_タスク作成_ver2: View {
//    @State private var showAlert: Bool = false
//    @ObservedObject var diaryTaskManager: DiaryTaskManager
//    @State private var isPresented = false
//    @State private var isLoading = false
//    @State private var isEdited = false // 変更があったかを判定
//    @State private var isDisabled = false // 🔹 無効化フラグ
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var initialTask: DiaryTask?
//    @State private var initialSelection: FamilyActivitySelection?
//
//    var body: some View {
//        ZStack{
//            NavigationStack {
//                Form {
//                    Section{
//                        パーツ_文字数入力欄_v2(characterCount: Binding<Int>(
//                            get: { diaryTaskManager.diaryTask.characterCount },
//                            set: { diaryTaskManager.diaryTask.characterCount = $0 }
//                        ))
//                    }
//                    Section{
//                        パーツ_時刻選択(開始時刻: $diaryTaskManager.diaryTask.startTime, 終了時刻: $diaryTaskManager.diaryTask.endTime)
//                        パーツ_曜日選択ビュー(繰り返し曜日: $diaryTaskManager.diaryTask.weekDays)
//                    }
//
//                    パーツ_アプリ選択(
//                        isPresented: $isPresented,
//                        selection: Binding<FamilyActivitySelection>(
//                            get: { diaryTaskManager.selection },
//                            set: { diaryTaskManager.selection = $0 }
//                        )
//                    )
//                    //                Section(header: Text("期日")) {
//                    //                    DatePicker("期限を選択", selection: $dueDate, displayedComponents: .date)
//                    //                        .datePickerStyle(GraphicalDatePickerStyle())
//                    //                }
//
//                    //                Section(header: Text("優先度")) {
//                    //                    Toggle(isOn: $isHighPriority) {
//                    //                        Text("高優先度")
//                    //                    }
//                    //                }
//                }
//                .disabled(isDisabled)
//                .opacity(isDisabled ? 0.5 : 1.0)
//                //            .navigationTitle("タスク作成")
////                .alert(isPresented: $showAlert) {
////                    Alert(
////                        title: Text("エラー"),
////                        message: Text("タスクのタイトルを入力してください。"),
////                        dismissButton: .default(Text("OK"))
////                    )
////                }
//            }
//
//            VStack {
//                Spacer() // 上部スペースを確保
//                パーツ_ボタン_ローディング(isLoading: $isLoading,isDisabled: !isEdited,ボタンテキスト: "保存", action: {
//                    diaryTaskManager.diaryTask.selectionID="selection_1"
//
//                    diaryTaskManager.saveDiaryTask(
//                        diaryTaskManager.diaryTask,
//                        selection: diaryTaskManager.selection,
//                        taskKey: "diary",
//                        selectionKey: "selection_1"
//                    )
//                    startMonitoring(diaryTaskManager: diaryTaskManager)
//
//                    let weekDays: [WeekDays] = convertToWeekDays(from: diaryTaskManager.diaryTask.weekDays)
//                    let rawValues = weekDays.map { $0.rawValue }
//                    NotificationScheduler.shared.scheduleNotification(startTime: diaryTaskManager.diaryTask.startTime, weekdays: rawValues)
//
//                    diaryTaskManager.startCountdown()  // ✅ 設定変更後に interval を更新
//                    dismiss()
//                    }
//                )
//            }
//            .padding(.horizontal)
//            .ignoresSafeArea(.keyboard, edges: .bottom)
//
//        }
//        .navigationTitle("日記の設定")
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Menu {
//                    Button(role: isDisabled ? nil : .destructive) {
//                        isDisabled.toggle()
//                    } label: {
//                        Text(isDisabled ? "有効にする" : "無効にする")
//                    }
//
//                } label: {
//                    Image(systemName: "ellipsis")
//                        .foregroundColor(.white)
//                }
//            }
//        }
//        .onAppear {// `initialTask` に初期値をセット
//            initialTask = diaryTaskManager.diaryTask
//            initialSelection = diaryTaskManager.selection
//        }
//        .onReceive(diaryTaskManager.objectWillChange) { _ in
//            print("onReceive")
//            checkForChanges()
//        }
//        .onDisappear {//キャンセルした時に初期の値に戻す
//                diaryTaskManager.diaryTask = initialTask ?? diaryTaskManager.diaryTask
//                diaryTaskManager.selection = initialSelection ?? diaryTaskManager.selection
//
//        }
//
//    }
//
//    // 変更があるかを判定
//    private func checkForChanges() {
//        guard let initialTask = initialTask, let initialSelection = initialSelection else { return }
//
//
//        isEdited = (
//            diaryTaskManager.diaryTask.characterCount != initialTask.characterCount ||
//            diaryTaskManager.diaryTask.startTime != initialTask.startTime ||
//            diaryTaskManager.diaryTask.endTime != initialTask.endTime ||
//            Set(diaryTaskManager.diaryTask.weekDays) != Set(initialTask.weekDays) ||
//            diaryTaskManager.selection != initialSelection
//            //                diaryTaskManager.diaryTask.selection != diaryTaskManager.diaryTask.selectionID
//        )
//    }
//
////    private func saveTask() {
////        print("タスクを保存: \(taskTitle), \(taskDescription), \(dueDate), 高優先度: \(isHighPriority)")
////        // 保存処理をここに実装
////    }
//}


//struct ページ_タスク作成: View {
//    @State private var taskType: TaskType
//    @State private var startTime: Date
//    @State private var endTime: Date
//    @State private var repeatDays: [Int]
//    @State private var characterCount: Int
//    @State private var value: Int = 80  // 初期値
//
//    @State private var showAlert = false // アラート表示フラグ
//    @State private var alertMessage = "" // アラートメッセージ
//
//
//    @State private var selectedApp: String = ""
//    @State private var selectedPickerIndex: Int? = nil
//    @State private var selectedDays: Set<String> = []
//    @State private var isStartTimePickerVisible: Bool = false
//    @State private var isEndTimePickerVisible: Bool = false
//    @State private var textColor: Color = Color.black.opacity(0.3)
//    @State private var isShowPopover = false
//    @State private var isShowStartTimePopover = false
//    @State private var isShowEndTimePopover = false
//    @State private var daySpacing: CGFloat = 0
//    @State private var isPresented = false
//    @State private var isButtonAbled: Bool = true
//    @State private var isTextFieldVisible = false
//    @State private var isDisabled_保存ボタン = false // ボタンの有効/無効を管理
//
//    //    @StateObject private var viewModel = TimeSelectionViewModel()
//    @StateObject var contentViewModel = ContentViewModel()
//
//    @FocusState private var pinFocusState: Bool
//    @Environment(\.dismiss) var dismiss
//    @Environment(\.managedObjectContext) var viewContext
//    @ObservedObject var viewModel: TaskViewModel
//
//    var task: MyTask
//
//    init(task: MyTask, viewModel: TaskViewModel) {
//        print("ページ_タスク.init - Start Time: \(task.startTime), End Time: \(task.endTime)")
//
//        self.task = task
//        self.viewModel = viewModel
//        // 初期値としてCoreDataの値をコピー
//        _taskType = State(initialValue: TaskType(rawValue: task.taskType ?? "diary") ?? .diary)
//        _startTime = State(initialValue: task.startTime)
//        _endTime = State(initialValue: task.endTime)
//        _repeatDays = State(initialValue: task.repeatDays?.split(separator: ",").compactMap { Int($0) } ?? [])
//        _characterCount = State(initialValue: Int(task.characterCount))
//    }
//
//    var body: some View {
//        ZStack {
//            VStack(spacing: 0) {
//                HStack {
//                    Button {
//                        dismiss()
//                    } label: {
//                        Text("キャンセル")
//                    }
//                    Spacer()
//                }
//                .padding()
//
//                ScrollView(.vertical, showsIndicators: false) {
//                    Spacer().frame(height: 24)
//                    VStack(spacing: 16) {
//                        ビュー_タスク作成(
//                            taskType: $taskType,
//                            startTime: $startTime,
//                            endTime: $endTime,
//                            repeatDays: $repeatDays,
//                            characterCount: $characterCount,
//
//                            pinFocusState: $pinFocusState,
//                            isButtonAbled: $isButtonAbled,
//                            isTextFieldVisible: $isTextFieldVisible
//                        )
//                        Spacer().frame(height: 100)
//                    }
//                }
//            }
//
//            VStack {
//                Spacer()
//                Button(action: {
//                    isDisabled_保存ボタン = true //処理中に押せないように
//                    //todo
//                    //                    updateTask(context: viewContext)
//                    viewModel.updateTask(
//                        taskType: taskType,
//                        startTime: startTime,
//                        endTime: endTime,
//                        repeatDays: repeatDays,
//                        characterCount: characterCount,
//                        context: viewContext
//                    )
//                    { success in
//                        if success {
//                            print("保存成功")
//                            dismiss()
//                        } else {
//                            print("保存失敗")
//                            alertMessage = "タスクの保存に失敗しました。" // 失敗メッセージを設定
//                            showAlert = true // アラートを表示
//                            isDisabled_保存ボタン=false
//                        }
//                    }
//                }) {
//                    Text("保存")
//                        .foregroundColor(isDisabled_保存ボタン ? .secondary : .primary)
//                        .fontWeight(.bold)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                }
//                .background(Color.buttonOrange)
//                .cornerRadius(24)
//                .padding(.vertical, 16)
//                .padding(.horizontal, 16)
//                .disabled(isDisabled_保存ボタン)
//            }
//            .ignoresSafeArea(.keyboard, edges: .bottom)
//
//        }
//        .alert(isPresented: $showAlert) {
//            Alert(
//                title: Text("保存失敗"),
//                message: Text(alertMessage),
//                dismissButton: .default(Text("閉じる"))
//            )
//        }
//        .onReceive(keyboardPublisher) { isVisible in
//            print("キーボードが表示されました: \(isVisible ? "はい" : "いいえ")")
//        }
//        .background(Color.darkBackground)
//        .onTapGesture {
//            pinFocusState = false
//            isButtonAbled = true
//            isTextFieldVisible = false
//        }
//    }
//
//    //    func getCurrentDayOfWeek() -> String {
//    //        let today = Date()
//    //        let calendar = Calendar.current
//    //        let dayNumber = calendar.component(.weekday, from: today)
//    //        return days[dayNumber - 1]
//    //    }
//
//    private func AddTask(context: NSManagedObjectContext) {
//        let newTask = MyTask(context: context)
//        newTask.startTime = startTime
//        newTask.endTime = endTime
//        newTask.createdAt = Date()
//        newTask.repeatDays = repeatDays.sorted().map { String($0) }.joined(separator: ",")
//
//        if taskType == .diary {
//            newTask.taskType = "Diary"
//            newTask.characterCount = Int16(characterCount)
//        } else if taskType == .timer {
//            newTask.taskType = "Timer"
//        }
//
//        do {
//            try context.save()
//            print("New task added successfully!")
//            dismiss()
//        } catch {
//            print("Failed to add task: \(error.localizedDescription)")
//        }
//    }
//
////    private func updateTask(context: NSManagedObjectContext) {
////        print("updateTask startTime:\(startTime) endTime:\(endTime)")
////        let calendar = Calendar.current
////        // 時間と分を抽出して比較
////        let startHour = calendar.component(.hour, from: startTime)
////        let startMinute = calendar.component(.minute, from: startTime)
////        let endHour = calendar.component(.hour, from: endTime)
////        let endMinute = calendar.component(.minute, from: endTime)
////
////        // 時間と分だけを比較
////        if startHour < endHour || (startHour == endHour && startMinute < endMinute) {
////            // startTime < endTime の場合、日付を同じにする
////            let startDateComponents = calendar.dateComponents([.year, .month, .day], from: startTime)
////            endTime = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: calendar.date(from: startDateComponents)!) ?? endTime
////        } else {
////            // endTime >= startTime の場合
////            // endTime を startTime の 1 日後に設定
////            let startDatePlusOneDay = calendar.date(byAdding: .day, value: 1, to: startTime) ?? startTime
////            endTime = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: startDatePlusOneDay) ?? endTime
////
////            // 時間と分が同じ場合、-5 分調整
////            if startHour == endHour && startMinute == endMinute {
////                endTime = calendar.date(byAdding: .minute, value: -5, to: endTime) ?? endTime
////            }
////        }
////
////
////        task.startTime = startTime
////        task.endTime = endTime
////        task.repeatDays = repeatDays.sorted().map { String($0) }.joined(separator: ",")
////
////        if taskType == .diary {
////            task.taskType = "Diary"
////            task.characterCount = Int16(characterCount)
////        } else if taskType == .timer {
////            task.taskType = "Timer"
////        }
////
////        DispatchQueue.global(qos: .background).async {
////            do {
////                try context.save()
////                DispatchQueue.main.async {
////                    print("Task updated successfully!")
////                    self.viewModel.objectWillChange.send()  // 値変更を通知
////                    //                    self.viewModel.coredata_MyTask = task // 変更を通知するために再代入
////                    dismiss()  // 保存完了後にメインスレッドで画面を閉じる
////                    isDisabled_保存ボタン=false
////                }
////            } catch {
////                DispatchQueue.main.async {
////                    print("Failed to update task: \(error.localizedDescription)")
////                    isDisabled_保存ボタン=false
////                }
////            }
////        }
////
////
////    }
//
//
//}


//struct ページ_タスク作成_ver2_Previews: PreviewProvider {
//    static var previews: some View {
//        @ObservedObject var diaryTaskManager = DiaryTaskManager.shared
//
//        ページ_タスク作成_ver2(diaryTaskManager: diaryTaskManager)
//    }
//}


//struct ページ_タスク作成_Previews: PreviewProvider {
//    @State static var taskType: TaskType = .diary  // ダミーのタスクタイプ
//    @State static var startTime: Date = Date()  // ダミーの開始時間
//    @State static var endTime: Date = Date().addingTimeInterval(3600)  // ダミーの終了時間
//    @State static var repeatDays: Set<Int> = [1, 3, 5]  // ダミーの繰り返し曜日
//    @State static var characterCount: Int = 100  // ダミーの文字数
//    @State static var existingTask = MyTask()  // ダミーの既存タスク
//
//    static var previews: some View {
//        ページ_タスク作成(
//            taskType: $taskType,
//            startTime: $startTime,
//            endTime: $endTime,
//            repeatDays: $repeatDays,
//            characterCount: $characterCount,
//            existingTask: $existingTask
//        )
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
