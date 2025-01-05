import SwiftUI
//import CoreData

// coredataのViewModelの作成
//class TaskViewModel: ObservableObject {
//    @Published var coredata_MyTask: MyTask  // 非オプショナルに変更
//
//    init(context: NSManagedObjectContext) {
//        // 既存のタスクがあるか確認
//        let fetchRequest: NSFetchRequest<MyTask> = MyTask.fetchRequest()
//        fetchRequest.fetchLimit = 1  // 1件のみ取得
//        if let existingTask = try? context.fetch(fetchRequest).first {
//            // 既存のタスクがある場合はそれを使用
//            self.coredata_MyTask = existingTask
//        } else {
//            // 新しいタスクを作成し、初期値を設定
//            let newTask = MyTask(context: context)
//            newTask.taskType = "diary"
//            newTask.startTime = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
//            newTask.endTime = newTask.startTime.addingTimeInterval(3600)
//            newTask.repeatDays = "0,1,2,3,4,5,6"
//            newTask.characterCount = 78
//            self.coredata_MyTask = newTask
//
//            // 非同期で保存
//            DispatchQueue.main.async {
//                do {
//                    try context.save()
//                    print("Task saved successfully!")
//                } catch {
//                    print("Failed to save task: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//}

struct ページ_日記リスト: View {
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.managedObjectContext) var viewContext  // ここでviewContextを定義

    @FetchRequest(
        entity: DiaryEntry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \DiaryEntry.createdAt, ascending: false)]
    ) var diaryEntries: FetchedResults<DiaryEntry>

    @FetchRequest(entity: MyTask.entity(), sortDescriptors: [])
    var diarytask: FetchedResults<MyTask>

    @State private var timer: Timer?
    // タスクのプロパティを一時的に保存する変数
//    @State private var taskType: TaskType = .diary
//    @State private var startTime: Date = Date()
//    @State private var endTime: Date = Date().addingTimeInterval(3600)
//    @State private var repeatDays: Set<Int> = []
//    @State private var characterCount: Int = 0
//    @State private var selectedTask: MyTask?  // 一時的なState変数
    //    let titleLineLimit: Int  // 変数で行数を指定
    @State private var フラグ_日記エディタ表示 = false  // シートの表示状態を管理
    @State private var フラグ_ブロック画面表示 = false
    @State private var フラグ_セッティング画面表示 = false
    @State private var countdownTime: Int = 3600  // カウントダウンの初期値 (秒数)
//    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    let generator = UIImpactFeedbackGenerator(style: .medium)

    @State private var listPositionX: CGFloat = 0.0

//    init(viewModel: TaskViewModel) {
//            self.viewModel = viewModel
//        }

    private var safeAreaInsets: UIEdgeInsets {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first?.safeAreaInsets ?? .zero
    }
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP") // 日本語に設定
        formatter.dateFormat = "MM/dd" // 日付のフォーマット

        // 曜日を1文字で取得
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale(identifier: "ja_JP")
        weekdayFormatter.dateFormat = "E" // 曜日フォーマット

        // 今日の日付から曜日を取得して1文字で表記
        let date = Date()
        let dayString = formatter.string(from: date)
        let weekdayString = weekdayFormatter.string(from: date).prefix(1) // 1文字にする

        return "\(dayString)(\(weekdayString))"
    }

    @State private var showPopover = true // ポップオーバー表示フラグ
    //    @State var characterCount = 270

//    func deleteAllTasks(context: NSManagedObjectContext) {
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MyTask.fetchRequest()
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//
//        do {
//            try context.execute(deleteRequest)
//            try context.save()
//            print("All tasks have been deleted.")
//
//            // キャッシュをリフレッシュ
//            context.refreshAllObjects()
//        } catch let error as NSError {
//            print("Could not delete all tasks. \(error), \(error.userInfo)")
//        }
//    }



    //最初にcoredataをfetchするために必要
    //実行するたびにTaskViewModelがcoredataにデータを追加しちゃう

//    init(context: NSManagedObjectContext) {
//            // 既存のタスクをフェッチ
//            let fetchRequest: NSFetchRequest<MyTask> = MyTask.fetchRequest()
//            fetchRequest.fetchLimit = 1  // 1件だけ取得
//            let existingTask = try? context.fetch(fetchRequest).first  // 最初のタスクを取得
//            self.viewModel = TaskViewModel(context: context, task: existingTask)
//        }

//    init(viewContext: NSManagedObjectContext) {
//        print("ページ_日記リスト.init")
//        let firstTask = try? viewContext.fetch(MyTask.fetchRequest()).first
//        _viewModel = StateObject(wrappedValue: TaskViewModel(context: viewContext, task: firstTask))
//    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack{
                    VStack{
                        Text("タイプ: \(String(describing: viewModel.coredata_MyTask.taskType))")
                        Text("開始時間: \(viewModel.coredata_MyTask.startTime)")
                        Text("終了時間: \(viewModel.coredata_MyTask.endTime)")
                        Text("文字: \(viewModel.coredata_MyTask.characterCount)")
                        Text("繰り返し: \(String(describing: viewModel.coredata_MyTask.repeatDays))")
                    }

                    ScrollView {
                        Spacer().frame(height: geometry.size.width <= 375 ? 40 : 44).listRowBackground(EmptyView())

                        VStack(spacing: geometry.size.width <= 375 ? 16 : 20) { // セクション間の間隔を設定
                            ForEach(groupedByMonthAndYear(), id: \.key) { (key, entries) in
                                VStack(spacing: 0) {
                                    // セクションヘッダー
                                    Text(headerTitle(for: key)) // 月と年を表すキーを表示
                                    //                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    //                                        .padding(.leading, geometry.size.width <= 375 ? 16 : 20)
                                        .padding(.bottom, 8)
                                        .background(Color.clear)
                                        .foregroundColor(.secondary)

                                    // セクション内のアイテム
                                    VStack(spacing: 0) {
                                        ForEach(Array(entries.enumerated()), id: \.element) { index, entry in
                                            let entryBody = entry.body ?? ""
                                            let entryCreatedAt = entry.createdAt ?? Date()

                                            NavigationLink(destination: ページ_日記(entryBody: entryBody, createdAt: entryCreatedAt)) {
                                                VStack(alignment: .leading) {
                                                    Text(entryBody.components(separatedBy: "\n").first ?? "")
                                                        .lineLimit(1)
                                                        .font(.headline)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                        .frame(maxWidth: .infinity, alignment: .leading)

                                                    Text(日付フォーマット(entryCreatedAt))
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                                .padding(.horizontal, geometry.size.width <= 375 ? 16 : 20)
                                                .padding(.vertical, geometry.size.width <= 375 ? 12 : 16)
                                                .frame(maxWidth: .infinity) // タップエリアをVStack全体に拡張
                                                .contentShape(Rectangle()) // タップ可能領域をVStack全体に設定
                                            }
                                            .buttonStyle(PlainButtonStyle())

                                            // 区切り線（最後の要素には表示しない）
                                            if index < entries.count - 1 {
                                                Divider()
                                                    .padding(.leading, geometry.size.width <= 375 ? 16 : 20)
                                            }
                                        }
                                    }

                                    .background(Color.darkButton_thin)
                                    .cornerRadius(geometry.size.width <= 375 ? 8 : 10)
                                }
                                .padding(.horizontal, geometry.size.width <= 375 ? 16 : 20)
                            }
                        }
                        Spacer().frame(height: 120).listRowBackground(EmptyView())
                    }

                    VStack {
                        HStack {
                            //                            パーツ_文字数入力欄(text: $characterCount)
                            Button(action: {
                                viewModel.deleteAllTasks(context: viewContext)
//                                deleteAllTasks(context: viewContext)
                            }) {
                                Text("Delete All Tasks")
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
//                            NavigationLink(destination: Coredata送るテスト(task: firstTask)) {
//                                Text("保存された予定")
//                                    .padding()
//                                    .background(Color.green)
//                                    .foregroundColor(.white)
//                                    .cornerRadius(8)
                            NavigationLink(destination: TaskListView()) {
                                Text("View Saved Tasks")
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            Button(action: {
                                // ボタンがタップされたときにフラグを変更
                                フラグ_ブロック画面表示 = true
                            }) {
                                Text("ブロック画面を表示")
                                    .font(.headline)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }.fullScreenCover(isPresented: $フラグ_ブロック画面表示) {
                                ページ_ブロック画面(action: {
                                    フラグ_日記エディタ表示 = true // フラグを変更
                                }) // フルスクリーンで表示するビュー
                            }
                            Spacer()
                            //設定
                            ZStack(alignment: .topTrailing) {
                                Button(action: {
//                                    if let firstTask = diarytask.first {
//                                                       selectedTask = firstTask  // 最初のタスクを選択
//
//                                                   }
                                    フラグ_セッティング画面表示 = true // ボタンタップ時にフルスクリーン表示
                                }) {
                                    Image("setting_outlined_icon")
                                        .resizable()
                                        .scaledToFit()
                                        .colorMultiply(Color.buttonOrange)
                                        .frame(width: 24, height: 24)
                                        .padding(8)
                                        .background(Color.darkButton_thin.opacity(0.7))
                                        .cornerRadius(.infinity)
                                    //                                        .shadow(color: Color.black.opacity(0.6), radius: 12, x: 0, y: 4)
                                }
                                .buttonStyle(PlainButtonStyle()) // デフォルトの青いエフェクトを消す
                                .fullScreenCover(isPresented: $フラグ_セッティング画面表示, onDismiss: {
                                    // FullScreenCoverが閉じたときに実行する関数
                                    ブロック監視タイマー()
                                }) {
//                                    Coredata送るテスト(task: firstTask)

                                    ページ_タスク作成(
                                        task: viewModel.coredata_MyTask,viewModel: viewModel
                                    )
                                }
                                // 通知アイコンの小さい円
                                //                                Circle()
                                //                                    .fill(Color.buttonOrange)
                                //                                    .frame(width: 6, height: 6)
                                //                                    .offset(x: -2, y: 2)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, geometry.size.width <= 375 ? 16 : 20)

                        //                    .background(Color.gray.opacity(0.8)) // 背景色を設定
                        .frame(maxWidth: .infinity)

                        Spacer() // リストを下に配置
                    }
                    VStack(spacing: 0) {
                        Spacer()
                        パーツ_ボタン_日記作成( action: {
                            フラグ_日記エディタ表示 = true // フラグを変更
                        },/*フラグ_日記エディタ表示: $フラグ_日記エディタ表示, */startTime: $viewModel.coredata_MyTask.startTime, endTime: $viewModel.coredata_MyTask.endTime,repeatDays: Binding<[Int]>(
                            get: {
                                // Stringを[Int]に変換
                                (viewModel.coredata_MyTask.repeatDays ?? "")
                                    .split(separator: ",")
                                    .compactMap { Int($0) }
                            },
                            set: { newRepeatDays in
                                // [Int]をStringに変換して保存
                                viewModel.coredata_MyTask.repeatDays = newRepeatDays.map { String($0) }.joined(separator: ",")
                            }
                        )) 
                            .sheet(isPresented: $フラグ_日記エディタ表示) {
                                NavigationView {
                                    ページ_日記エディタ {
                                        フラグ_日記エディタ表示 = false  // 保存完了後にシートを閉じる
                                    }
                                    .navigationBarTitleDisplayMode(.inline)
                                }
                                .presentationDetents([.large])
                            }
                    }
                    .padding(.horizontal, geometry.size.width <= 375 ? 16 : 20)
                    .padding(.bottom,/*44+*/geometry.size.width <= 375 ? 8 : 10)
                }
                //開発用なのでelseは後で消す
                .onAppear {
                    ブロック監視タイマー()

                }

            }
        }
    }


    // カウントダウンを更新する関数
//    private func updateCountdown() {
//        if countdownTime > 0 {
//            countdownTime -= 1
//        }
//    }

    // カウントダウンの残り時間を "00:00:00" の形式でフォーマット
    private func formattedCountdownTime() -> String {
        let hours = countdownTime / 3600
        let minutes = (countdownTime % 3600) / 60
        let seconds = countdownTime % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    private func ブロック監視タイマー() {
            let 開始時間までの秒数 = 開始時間までの秒数を取得(from: viewModel.coredata_MyTask.startTime)

            if 開始時間までの秒数 > 0 {
                // 指定された秒数後に処理を実行
                タイマー開始(after: 開始時間までの秒数)
            } else {
                // 開始時間を過ぎている場合、即時に監視を開始
                ブロック中か終了しているか()
            }
        }

    private func 開始時間までの秒数を取得(from targetTime: Date) -> TimeInterval {
        let calendar = Calendar.current
        let now = Date()

        // 現在時刻と目標時刻の日付を無視して時間だけに変換
        let nowComponents = calendar.dateComponents([.hour, .minute, .second], from: now)
        let targetComponents = calendar.dateComponents([.hour, .minute, .second], from: targetTime)

        // 現在の日付に目標時間を設定
        guard let todayTargetTime = calendar.date(bySettingHour: targetComponents.hour ?? 0,
                                                  minute: targetComponents.minute ?? 0,
                                                  second: targetComponents.second ?? 0, of: now) else {
            return 0 // エラーが発生した場合は0を返す
        }

        // 時間だけの差分を計算
        let interval = todayTargetTime.timeIntervalSince(now)

        // 差分が負の場合、次の日の同じ時間を目指してカウント
        return interval >= 0 ? interval : interval + 24 * 60 * 60
    }

    private func タイマー開始(after seconds: TimeInterval) {
        print("タイマー開始までの残り秒数: \(seconds) 秒")
        timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { _ in
            print("指定された開始時間になりました")
            ブロック中か終了しているか() // 終了時間までの監視を開始
        }
    }

    private func タイマー開始() {
        timer?.invalidate()
        timer = nil
    }

    private func ブロック中か終了しているか() {
        // 終了時間まで1秒ごとに監視
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let currentTime = Date()
            if currentTime <= viewModel.coredata_MyTask.endTime {
                print("ブロック範囲内です")
            } else {
                print("\(#file):\(#line) 終了時間を過ぎました")
                タイマー開始()
            }
        }
    }
    

    //    func formatDate(_ date: Date) -> String {
    //        let calendar = Calendar.current
    //        let today = calendar.startOfDay(for: Date())
    //        let entryDate = calendar.startOfDay(for: date)
    //
    //        let components = calendar.dateComponents([.day], from: entryDate, to: today)
    //        let dayDifference = components.day ?? 0
    //
    //        let weekdayFormatter = DateFormatter()
    //        weekdayFormatter.locale = Locale(identifier: "ja_JP")  // 日本語に設定
    //        weekdayFormatter.dateFormat = "EEE"  // 曜日を1文字で表示する形式
    //
    //        // 今日の場合
    //        if calendar.isDateInToday(entryDate) {
    //            let timeFormatter = DateFormatter()
    //            timeFormatter.locale = Locale(identifier: "ja_JP")
    //            timeFormatter.dateFormat = "HH:mm"
    //            return timeFormatter.string(from: date)  // 今日なら時刻を表示
    //
    //        // 昨日の場合
    //        } else if calendar.isDateInYesterday(entryDate) {
    //            return "昨日"  // 昨日
    //
    //        // 6日前まで
    //        } else if dayDifference <= 6 {
    //            return weekdayFormatter.string(from: date) + "曜日"  // 6日前までは曜日+曜日を表示
    //        }
    // else {
    //            let currentYear = calendar.component(.year, from: today)
    //            let entryYear = calendar.component(.year, from: entryDate)
    //
    //            let dateFormatter = DateFormatter()
    //            dateFormatter.locale = Locale(identifier: "ja_JP")  // 日本語に設定
    //
    //            // 曜日を取得してフォーマットに追加
    //            let weekday = weekdayFormatter.string(from: date)
    //
    //            // 今年の場合は "MM/dd (金)"、それ以外は "yyyy/MM/dd (金)"
    //            if currentYear == entryYear {
    //                dateFormatter.dateFormat = "MM/dd'('\(weekday)')'"
    //            } else {
    //                dateFormatter.dateFormat = "yyyy/MM/dd'('\(weekday)')'"
    //            }
    //            return dateFormatter.string(from: date)
    //        }
    //    }

    // 日記エントリを月ごとにグループ化
    func groupedByMonthAndYear() -> [(key: String, entries: [DiaryEntry])] {
        let calendar = Calendar.current
        let groupedEntries = Dictionary(grouping: diaryEntries) { entry -> String in
            let date = entry.createdAt ?? Date()
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            return String(format: "%02d-%d", month, year)  // "MM-YYYY" 形式でキーを作成
        }

        // グループ化されたエントリをタプルに変換し、リストとして返す
        return groupedEntries.map { (key, value) in
            (key: key, entries: value)
        }
        .sorted(by: { first, second in
            // キーを "MM-YYYY" から分割し、年と月を数値で比較する
            let firstComponents = first.key.split(separator: "-").map { Int($0) ?? 0 }
            let secondComponents = second.key.split(separator: "-").map { Int($0) ?? 0 }

            // 年を比較、同じ場合は月を比較
            if firstComponents[1] == secondComponents[1] {
                return firstComponents[0] > secondComponents[0]  // 月を降順で比較
            } else {
                return firstComponents[1] > secondComponents[1]  // 年を降順で比較
            }
        })
    }

    // ヘッダーのタイトルを生成
    func headerTitle(for key: String) -> String {
        let components = key.split(separator: "-")
        let month = Int(components[0]) ?? 0
        let year = Int(components[1]) ?? 0
        let currentYear = Calendar.current.component(.year, from: Date())

        // 今年の場合は月のみ、違う年なら「月 年」の形式で表示
        if year == currentYear {
            return "\(month)月"
        } else {
            return "\(month)月 \(year)年"
        }
    }
}


struct ページ_日記: View {
    var entryBody: String?
    var createdAt: Date

    var body: some View {
        ScrollView {
            Text(entryBody ?? "内容がありません")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(年付き日付フォーマット(createdAt,詳しいフォーマット: true))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // 日付スタイルを指定
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct ページ_日記リスト_Previews: PreviewProvider {
    static var previews: some View {
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext
        let deviceSizeManager = DeviceSizeManager() // DeviceSizeManagerのインスタンスを作成

        // プレビュー用のダミーデータを用意
        let dates: [Date] = [
            Calendar.current.date(byAdding: .day, value: -1, to: Date())!,  // 昨日
            Calendar.current.date(byAdding: .day, value: -2, to: Date())!,  // 一昨日
            Calendar.current.date(byAdding: .day, value: -6, to: Date())!,  // 6日前
            Calendar.current.date(byAdding: .day, value: -8, to: Date())!,  // 8日前

            // 9月のデータを追加
            Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 15))!,  // 2024年9月15日
            Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 25))!,  // 2024年9月25日

            // 2023年のデータを追加
            Calendar.current.date(from: DateComponents(year: 2023, month: 3, day: 5))!,   // 2023年3月5日
            Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 10))!,  // 2023年12月10日

            // 2023年のデータを追加
            Calendar.current.date(from: DateComponents(year: 2023, month: 3, day: 5))!,   // 2023年3月5日
            Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 10))!  // 2023年12月10日
        ]

        // 配列の要素数に応じてループを回す
        for i in 0..<dates.count {
            let newDiary = DiaryEntry(context: viewContext)
            newDiary.body = "SampleSampleSampleSampleSampleSample Diary \(i)"
            newDiary.createdAt = dates[i]
        }

        let newTask = MyTask(context: viewContext)
        newTask.characterCount = 80
        newTask.createdAt = Date()
        newTask.endTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        newTask.isCompleted = false
        newTask.repeatDays = "0,1,2,3,4,5,6" // 月、水、金などを表す日付の配列を示す例
        newTask.startTime = Date()
        newTask.taskType = "diary"

        do {
            try viewContext.save()  // プレビュー用にデータを保存
        } catch {
            print("Failed to save preview data: \(error.localizedDescription)")
        }

        let viewModel = TaskViewModel(context: viewContext)

        return ZStack {
            // リストを下に表示
            ページ_日記リスト(viewModel: viewModel)
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(deviceSizeManager) // DeviceSizeManagerを注入
        }
    }
}

class DeviceSizeManager: ObservableObject {
    @Published var isSmallScreen: Bool = false

    func update(geometry: GeometryProxy) {
        self.isSmallScreen = geometry.size.width <= 375
    }
}

//struct CustomScrollView: View {
//    var body: some View {
//        GeometryReader { geometry in
//            ScrollView {
//                VStack(spacing: 24) { // セクション間の間隔を設定
//                    ForEach(0..<5, id: \.self) { sectionIndex in
//                        VStack(spacing: 0) {
//                            // セクションヘッダー
//                            Text("\(sectionIndex + 1)月")
//                                .font(.title3)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .padding(.horizontal, geometry.size.width <= 375 ? 16 : 20)
//                                .padding(.vertical, 8)
//                                .background(Color.clear)
//
//                            // セクション内のアイテム
//                            VStack(spacing: 0) {
//                                ForEach(0..<5, id: \.self) { itemIndex in
//                                    VStack(spacing: 0) {
//                                        Text("リスト項目 \(sectionIndex * 5 + itemIndex + 1)")
//                                            .frame(maxWidth: .infinity, alignment: .leading)
//                                            .padding(.horizontal, geometry.size.width <= 375 ? 16 : 20)
//                                            .padding(.vertical, 20)
//                                            .background(Color(.systemGray6))
//
//                                        // 区切り線
//                                        if itemIndex < 4 {
//                                            Divider()
//                                                .padding(.leading, geometry.size.width <= 375 ? 16 : 20)
//                                        }
//                                    }
//                                }
//                            }
//                            .background(Color(.systemGray6))
//                            .cornerRadius(geometry.size.width <= 375 ? 8 : 10)
//                        }
//                        .padding(.horizontal, geometry.size.width <= 375 ? 16 : 20)
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct CustomScrollView_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomScrollView()
//    }
//}
