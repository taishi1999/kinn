import SwiftUI
import FamilyControls
import ManagedSettings
import CoreData

//texteditorにplaceholderを表示するコンポーネント
//struct TextEditorWithPlaceholder: View {
//
//    @FocusState private var focusedField: Field?
//
//    enum Field {
//        case textEditor
//    }
//
//    @Binding var text: String
//    private let placeholderText: String
//
//    // パディングの変数を定義
//    private let editorPadding: CGFloat = 4
//    private var placeholderLeadingPadding: CGFloat {
//            editorPadding + 5 // editorPadding + 5 で設定
//        }
//    private var placeholderTopPadding: CGFloat {
//        editorPadding + 8 // editorPadding + 5 で設定
//    }
//
//    init(_ placeholder: String, text: Binding<String>) {
//        self._text = text
//        self.placeholderText = placeholder
//    }
//
//    var body: some View {
//        ZStack(alignment: .topLeading) {
//            // TextEditor
//            TextEditor(text: $text)
//                .focused($focusedField, equals: .textEditor)
//                .onAppear {
//                    focusedField = .textEditor // 初期状態でTextEditorにフォーカスを当てる
//                }
//                .padding(editorPadding) // パディング値を変数で管理
//
//            // プレースホルダー表示
//            if text.isEmpty {
//                Text(placeholderText)
//                    .foregroundColor(.gray)
//                    .padding(.leading, placeholderLeadingPadding) // 左側のパディング
//                    .padding(.top, placeholderTopPadding) // 上側のパディング
//            }
//        }
////        .border(Color.gray, width: 1)
//    }
//}

//struct 日記作成画面: View {
//    @State private var diaryText: String = ""  // @Stateでテキストを管理
//
//    var body: some View {
//        VStack(spacing: 16) {
//            Text("日記を書く")
//                .font(.title)
//                .fontWeight(.bold)
//
//            // TextEditorWithPlaceholderの表示
//            TextEditorWithPlaceholder("ここに日記を入力してください", text: $diaryText)  // $を使ってBindingを渡す
//                .frame(height: 200)
//                .border(Color.gray, width: 1) // 枠線を追加
//
//            Button(action: {
//                print("保存されたテキスト: \(diaryText)")
//            }) {
//                Text("保存")
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//        }
//        .padding()
//    }
//}
//
//struct 日記作成画面_Previews: PreviewProvider {
//    static var previews: some View {
//        日記作成画面()
//    }
//}
//struct 日記エディタ2: View {
//    @Environment(\.managedObjectContext) private var viewContext  // Core Dataのコンテキスト
//    @State private var bodyText: String = ""
//
//    var body: some View {
//        VStack {
//            TextEditor(text: $bodyText)
//                .frame(height: 300)
//                .padding()
//                .background(Color.gray.opacity(0.2))
//                .cornerRadius(10)
//
//            Button(action: saveDiary) {
//                Text("Save Diary")
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//        }
//        .padding()
//    }
//
//    private func saveDiary() {
//        let newDiary = calendar.DiaryEntry(context: viewContext)
//        newDiary.body = bodyText
//        newDiary.createdAt = Date()
//
//        do {
//            try viewContext.save()  // Core Dataに保存
//            bodyText = ""  // 保存後に本文をクリア
//        } catch {
//            print("Failed to save diary: \(error.localizedDescription)")
//        }
//    }
//}
//
//struct 日記エディタ2_Previews: PreviewProvider {
//    static var previews: some View {
//        // In-Memory Core Dataコンテキストを使用してプレビュー
//        let dataController = DataController(inMemory: true)
//        let viewContext = dataController.container.viewContext
//
//        // ダミーデータの作成
//        for _ in 0..<5 {
//            let newDiary = DiaryEntry(context: viewContext)
//            newDiary.body = "This is a sample diary entry."
//            newDiary.createdAt = Date()
//        }
//
//        do {
//            try viewContext.save()  // プレビュー用にデータを保存
//        } catch {
//            print("Failed to save preview data: \(error.localizedDescription)")
//        }
//
//        return 日記エディタ2()
//            .environment(\.managedObjectContext, viewContext)  // Core Dataのコンテキストを設定
//    }
//}

//struct 日記エディタ: View {
//    @State private var diaryText = "" // TextEditor用の状態変数
//
//    var body: some View {
//        GeometryReader { geometry in
//            VStack(spacing: 0) {
//                日付タイトル() // 日付と曜日を表示するコンポーネント
//Divider()
//                // 残りのスペースを全てTextEditorで埋める
//                TextEditorWithPlaceholder("今日はどんな一日？", text: $diaryText)
//                    .frame(maxHeight: .infinity) // 残りの空間を全て埋める
//                    .padding(.horizontal)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity) // 画面全体にフィットさせる
//        }
////        .edgesIgnoringSafeArea(.bottom) // 下部の余白も含めてフィット
//    }
//}
//
//struct 日付タイトル: View {
//    var body: some View {
//        VStack {
//            Text(getDayOfWeek()) // 曜日を表示
//                .font(.headline)
//                .padding(.bottom, 2)
//
//            Text(getTodayDay()) // 今日の日付 (日) を表示
//                .font(.largeTitle)
//        }
//        .padding()
//    }
//
//    // 今日の曜日を取得
//    func getDayOfWeek() -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "EEEE" // 曜日を表示
//        return dateFormatter.string(from: Date())
//    }
//
//    // 今日の日付の「日」だけを取得
//    func getTodayDay() -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "d" // 日のみ表示
//        return dateFormatter.string(from: Date())
//    }
//}

//いったんコメントアウト(screentime apiのために)
//@main
struct MyApp: App {
    //    let center = AuthorizationCenter.shared
    @StateObject private var dataController = DataController()  // Core Dataのコントローラ

    @State private var linktext = "Here is a link: https://www.apple.com"  // 静的でなく通常の@Stateプロパティに変更

    @State private var diaryText: String = ""

//    @State private var isSheetPresented = false // プレビュー用に@Stateでシート表示状態を定義

    @State private var showSettingsOnFirstLaunch = false  // 初回起動時のシート表示フラグ

    var body: some Scene {
        WindowGroup {
            let taskViewModel = TaskViewModel(context: dataController.container.viewContext)
//本丸
//            ページ_日記リスト(viewModel: taskViewModel)
//            MainTabView()
//            MainTextEditorView()
//            MainView()
            // ダークモード
//            UserDefaultsExampleView()
//スクリーンタイムAPIでのブロックのテスト
            
//            let model = ScreenTimeSelectAppsModel() // インスタンスをここで作成
//            ScreenTimeSelectAppsView(model: model)

//            let model = ScreenTimeSelectAppsModel_test()
//            ScreenTimeSelectAppsContentView(model: model)
            //ローカル通知
//            AlarmView()
//            AudioPlayerView()
            //64コマ出遅れた
//            AlarmNotificationView()
//            NotificationView()
            通知スケジュールビュー()
            //http://pedroesli.com/2023-11-13-screen-time-api/のやり方
//            ShieldView()
            //DAMectensionのテスト
//            ActivitySelectionView()
//            LocalNotificationView()
//            アプリルート(viewModel: taskViewModel)
                            .preferredColorScheme(.dark)
                            .environment(\.managedObjectContext, dataController.container.viewContext)

//                .onAppear {
//                                    checkFirstLaunch()
//                                }
            //開発のため一時コメントアウト
//                .sheet(isPresented: $showSettingsOnFirstLaunch) {
//                    初回設定View()
//                        .presentationDetents([.large])
//                        .interactiveDismissDisabled(true) // スワイプでの閉じる操作を無効化
//                }


            //                .onAppear {
            //                    Task {
            //                        do {
            //                            try await center.requestAuthorization(for: .individual)
            //                        } catch {
            //                            // Handle the error here.
            //                        }
            //                    }
            //                }
        }
    }

    private func checkFirstLaunch() {
            // UserDefaultsで初回起動かどうかを判別
            let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
            if !hasLaunchedBefore {
                showSettingsOnFirstLaunch = true
                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            }
        //debug用にtrueを入れています
        showSettingsOnFirstLaunch = true
        }
}

struct 初回設定View: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("初回設定の説明")
                    .font(.title)
                    .padding()
                Text("このアプリの機能や設定方法の説明を表示します。")
                Spacer()
            }
        }
    }
}

//class ContentViewModel: ObservableObject {
//    @Published var selection = FamilyActivitySelection()
//
//    func startBlocking() {
//        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("karasaki.kinn"))
//        store.application.denyAppRemoval = true
//        store.shield.applicationCategories = .specific(selection.categoryTokens)
//        store.shield.applications = selection.applicationTokens
//    }
//
//    func stopBlocking() {
//        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("karasaki.kinn"))
//        store.shield.applications = nil
//        store.shield.applicationCategories = nil
//        store.clearAllSettings()
//    }
//}

struct MainView: View {
    let center = AuthorizationCenter.shared
    @StateObject var viewModel = ContentViewModel()
    @State private var isPresented = false
    @Environment(\.managedObjectContext) var viewContext  // Core Dataのコンテキストを参照
    @State private var date = Date()

    // Fetch all MyTask data
    @FetchRequest(entity: MyTask.entity(), sortDescriptors: [])
    var tasks: FetchedResults<MyTask>

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    NavigationLink(destination: TaskListView()) {
                        Text("View Saved Tasks")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        deleteAllTasks()
                    }) {
                        Text("Delete All Tasks")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    ビュー_予定(tasks: tasks)
                }
                VStack(spacing:0){
                    Spacer()
                    パーツ_FABボタン_タスク作成()
                    パーツ_セグメントピッカー()

                }

                VStack {
                    Spacer()
                        .frame(height: 200)

                    // Authorization buttons (省略)

                    Button {
                        isPresented = true
                    } label: {
                        Text("選択する")
                    }
                    .familyActivityPicker(isPresented: $isPresented, selection: $viewModel.selection)

                    // Block control buttons (省略)
                }
            }
            .background(Color.darkBackground)
        }
    }

    private func deleteAllTasks() {
        for task in tasks {
            viewContext.delete(task)  // 各タスクを削除
        }

        do {
            try viewContext.save()  // 削除を保存して確定
            print("All tasks deleted successfully!")
        } catch {
            print("Failed to delete tasks: \(error.localizedDescription)")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        // In-Memory Core Dataコンテキストを使用してプレビュー
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext

        // ダミーデータの作成
        for _ in 0..<5 {
            let newTask = MyTask(context: viewContext)
            newTask.taskType = "Sample Task"
            newTask.isCompleted = false
            newTask.startTime = Date()
            newTask.endTime = Date().addingTimeInterval(3600)
            newTask.repeatDays = "1,2,3"
        }

        do {
            try viewContext.save()  // プレビュー用にデータを保存
        } catch {
            print("Failed to save preview data: \(error.localizedDescription)")
        }

        return MainView()
            .environment(\.managedObjectContext, viewContext)
    }
}
struct TutorialSheetView: View {
    var body: some View {
        VStack {
            Text("初回起動時の説明")
                .font(.title)
                .padding()
            Text("アプリの使い方や説明をここに記載します。")
        }
    }
}

//-----------------------
// Stateの管理
class WeeklyCalendarViewModel: ObservableObject {
    @Published var currentDate: Date
    @Published var selectedWeekIndex: Int
    @Published var displayDate: Date
    @Published var selectedDayOffset: Int
    @Published var calendarItemHeight: CGFloat = 44.0
    let weeksToShow: Int
    let daysOfWeek = ["日", "月", "火", "水", "木", "金", "土"]
    let fullDaysOfWeek = ["日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"]

    init(currentDate: Date = Date(), selectedWeekIndex: Int = 12, selectedDayOffset: Int = Calendar.current.component(.weekday, from: Date()) - 1, weeksToShow: Int = 12) {
        self.currentDate = currentDate
        self.selectedWeekIndex = selectedWeekIndex
        self.displayDate = currentDate
        self.selectedDayOffset = selectedDayOffset
        self.weeksToShow = weeksToShow
    }

    // 週の初日を取得する関数
    func firstDayOfWeek(from date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components)!
    }

    // 特定の曜日の日付を返す関数
    func dateForSpecificDayOfWeek(weekOffset: Int, dayOffset: Int) -> Date {
        // 現在の日付を取得
        let currentDate = Date()
        // 現在の日付を含む週の最初の日（例：日曜日）を取得
        let firstDayOfWeek = firstDayOfWeek(from: currentDate)
        // 指定された週の開始日を取得
        let targetWeekStartDate = Calendar.current.date(byAdding: .weekOfYear, value: weekOffset, to: firstDayOfWeek)!
        // 指定された曜日の日付を取得
        return Calendar.current.date(byAdding: .day, value: dayOffset, to: targetWeekStartDate)!
    }

    // 選択された日付の曜日を更新する関数
    func updateSelectedDayOffset(for date: Date) {
        selectedDayOffset = Calendar.current.component(.weekday, from: date) - 1
    }

    // 日付をフォーマットする関数
    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    func formattedYear(from date: Date) -> String {
        let currentYear = Calendar.current.component(.year, from: Date())
        let year = Calendar.current.component(.year, from: date)
        return year == currentYear ? "" : "\(year)"
    }
}

struct WeeklyCalendarView: View {
    @StateObject private var viewModel = WeeklyCalendarViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(" \(viewModel.fullDaysOfWeek[Calendar.current.component(.weekday, from: viewModel.displayDate) - 1])")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(Calendar.current.isDateInToday(viewModel.displayDate) ? .blue : Color(UIColor.black))
                // if Calendar.current.isDateInToday(viewModel.displayDate) {
                //                    Text("今日")
                //                        .font(.subheadline)
                //                        .fontWeight(.bold)
                //                        .foregroundColor(.blue)
                //                } else if !viewModel.formattedYear(from: viewModel.displayDate).isEmpty {
                //                    Text(viewModel.formattedYear(from: viewModel.displayDate))
                //                        .font(.subheadline)
                //                        .fontWeight(.bold)
                //                        .foregroundColor(Color(UIColor.systemGray2))
                //                }
            }
            .frame(height: 16)

            Text(viewModel.formattedDate(from: viewModel.displayDate))
                .font(.title)
                .fontWeight(.heavy)
                .padding(.bottom)

            HStack(spacing: 0) {
                ForEach(viewModel.daysOfWeek, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color(UIColor.systemGray2))
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal)

            //            .overlay(
            //                RoundedRectangle(cornerRadius: 0)
            //                    .stroke(Color.secondary, lineWidth: 1)
            //            )

            TabView(selection: $viewModel.selectedWeekIndex) {
                ForEach(-viewModel.weeksToShow...viewModel.weeksToShow, id: \.self) { weekOffset in
                    WeekView(startDate: viewModel.dateForSpecificDayOfWeek(weekOffset: weekOffset, dayOffset: 0), displayDate: viewModel.displayDate, itemHeight: viewModel.calendarItemHeight-4) { selectedDate in
                        viewModel.displayDate = selectedDate
                        viewModel.selectedWeekIndex = weekOffset + viewModel.weeksToShow
                        viewModel.updateSelectedDayOffset(for: selectedDate)
                    }
                    .tag(weekOffset + viewModel.weeksToShow)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: viewModel.calendarItemHeight)
            .onChange(of: viewModel.selectedWeekIndex) { newIndex in
                viewModel.displayDate = viewModel.dateForSpecificDayOfWeek(weekOffset: newIndex - viewModel.weeksToShow, dayOffset: viewModel.selectedDayOffset)
            }

            Spacer()
        }
    }
}

struct WeekView: View {
    let startDate: Date
    let displayDate: Date
    let itemHeight: CGFloat
    var onDateSelected: (Date) -> Void

    func weekDays(from startDate: Date) -> [Date] {
        let calendar = Calendar.current
        return (0..<7).map { calendar.date(byAdding: .day, value: $0, to: startDate)! }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDays(from: startDate), id: \.self) { date in
                let isSelectedDate = Calendar.current.isDate(date, inSameDayAs: displayDate)
                let isToday = Calendar.current.isDateInToday(date)

                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelectedDate && isToday ? Color.primary : (isSelectedDate ? Color.black : Color.clear))
                        .frame(width: itemHeight, height: itemHeight)
                        .animation(.easeInOut(duration: 0.1), value: isSelectedDate)

                    Text("\(Calendar.current.component(.day, from: date))")
                        .fontWeight(isSelectedDate ? .bold : .regular)
                        .foregroundColor(isSelectedDate ? Color(.systemBackground) : (isToday ? Color.blue : Color.black))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    onDateSelected(date)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        //        .overlay(
        //            RoundedRectangle(cornerRadius: 0)
        //                .stroke(Color.gray, lineWidth: 1)
        //        )
    }
}

struct SelectAppView: View {
    @Binding var selectedApp: String

    var body: some View {
        Text("Select an App")
    }
}


//struct モーダル_タスク作成: View {
//    @State private var selectedApp: String = ""
//    @State private var startTime: Date = Date()
//    @State private var endTime: Date = Date().addingTimeInterval(3600) // 1 hour later
//    @State private var selectedDays: Set<String> = ["火"]
//
//    let days = ["日", "月", "火", "水", "木", "金", "土"]
//
//    var body: some View {
//        ZStack {
//
//            ScrollView {
//
//                VStack(spacing: 16) {
//
//                    HStack {
//                        Text("⏰")
//                            .font(.system(size: 32))
//                        Text("時間経過")
//                            .font(.headline)
//                        Spacer()
//                        Image(systemName: "chevron.down")
//                            .rotationEffect(.degrees(0))
//                    }
//                    .padding()
//                    .background(Color(.systemBackground))
//                    .cornerRadius(16)
//
//                    VStack(spacing: 0) {
//                        HStack {
//                            Text("開始")
//                            Spacer()
//                            DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
//                                .labelsHidden()
//                        }
//                        .padding()
//                        .background(Color(.systemBackground))
//
//                        Divider().padding(.leading)
//
//                        HStack {
//                            Text("終了")
//                            Spacer()
//                            DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
//                                .labelsHidden()
//                        }
//                        .padding()
//                        .background(Color(.systemBackground))
//
//                        Divider()
//
//                        HStack {
//                            ForEach(days, id: \.self) { day in
//                                Text(day)
//                                    .frame(width: 40, height: 40)
//                                    .background(self.selectedDays.contains(day) ? Color.black : Color(.systemGray6))
//                                    .foregroundColor(self.selectedDays.contains(day) ? Color.white : Color(.systemGray2))
//                                    .fontWeight(self.selectedDays.contains(day) ? .bold : .regular)
//                                    .cornerRadius(20)
//                                    .onTapGesture {
//                                        if self.selectedDays.contains(day) {
//                                            self.selectedDays.remove(day)
//                                        } else {
//                                            self.selectedDays.insert(day)
//                                        }
//                                    }
//                                if day != days.last {
//                                    Spacer()
//                                }
//                            }
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color(.systemBackground))
//                    }
//                    .cornerRadius(16)
//                    .background(Color(.systemGray6))
//
//                    NavigationLink(destination: SelectAppView(selectedApp: $selectedApp)) {
//                        HStack {
//                            Text("ブロックするアプリ")
//                                .foregroundColor(.black)
//                            Spacer()
//                            Text(selectedApp.isEmpty ? "選択" : selectedApp)
//                                .foregroundColor(.gray)
//                            Image(systemName: "chevron.right")
//                        }
//                        .padding()
//                        .background(Color(.systemBackground))
//                        .cornerRadius(16)
//                        .background(Color(.systemGray6))
//                    }
//
//                    // Extra space to make sure the content can be scrolled above the button
////                    Spacer().frame(height: 100)
//                }
//            }
//
//            VStack {
//                Spacer()
//
//                Button(action: {
//                    // パーツ_FABボタン_タスク作成が押された時のアクションをここに書きます
//                }) {
//                    Text("作成")
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .fontWeight(.bold)
//                        .padding()
//                        .background(Color.black)
//                        .cornerRadius(25)
//                }
//                .padding()
//                .background(Color.clear)
//            }
//        }
//        .padding(16)
//        .background(Color(.systemGray6))
//    }
//}

//import SwiftUI
//
//  // グローバル定数として定義
//struct HeaderView: View {
//    var body: some View {
//        HStack {
//            Spacer()  // 左側のスペース
//            Text("ヘッダータイトル")  // 中央のテキスト
//                .font(.headline)  // フォントスタイル
//                .padding()  // パディングを追加
//            Spacer()  // 右側のスペースを調整するためのスペーサー
//            Button(action: {
//                // ボタンが押されたときのアクション
//                print("ボタンが押されました")
//            }) {
//                Image(systemName: "bell")  // ベルアイコン
//                    .resizable()  // サイズ変更可能
//                    .scaledToFit()  // アスペクト比を保持
//                    .frame(width: 24, height: 24)  // アイコンサイズ
//            }
//            .padding()  // ボタン周りのパディング
//        }
//        .background(Color.gray.opacity(0.2))  // 背景色
//        .cornerRadius(10)  // 角の丸み
//        .padding()  // 外側のパディング
//    }
//}
//
//struct MainTabView: View {
//    // グリッドのカラム設定: 7列、スペースなし
//    private let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 7)
//    private let elementHeight: CGFloat = 56  // 各要素の高さ
//    private var totalHeight: CGFloat {
//        let num = elementHeight
//        return num + elementHeight * 5
//    }
//    let monthCount = 12
//        let weekCount = 6
//    @State private var showWeek = false  // 週表示か月表示かの状態
//
//    var body: some View {
//        TabView {
//                        ForEach(0..<(showWeek ? monthCount * weekCount : monthCount), id: \.self) { index in
//                            if showWeek {
//                                // 週表示
//                                VStack {
//                                    LazyVGrid(columns: columns, spacing: 0) {
//                                        ForEach(Array(index * 7..<(index + 1) * 7), id: \.self) { sectionIndex in
//                                            SectionView(sectionTitle: "\(sectionIndex + 1)", color: colors[sectionIndex % colors.count], elementHeight: elementHeight)
//                                        }
//                                    }
//                                }
//                                .frame(maxWidth: .infinity, maxHeight: elementHeight)
//                            } else {
//                                // 月表示
//                                VStack {
//                                    LazyVGrid(columns: columns, spacing: 0) {
//                                        ForEach(Array(index * 42..<(index + 1) * 42), id: \.self) { sectionIndex in
//                                            SectionView(sectionTitle: "\(sectionIndex + 1)", color: colors[sectionIndex % colors.count], elementHeight: elementHeight)
//                                        }
//                                    }
//                                }
//                                .frame(maxWidth: .infinity, maxHeight: elementHeight * 6) // 月の全週の高さ
//                            }
//                        }
//                        .background(Color.gray.opacity(0.2))
//                        .cornerRadius(0)
//                        .padding(.horizontal, 16)
//                    }
//        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))  // タブのインデックスを表示しない
//        .frame(maxWidth: .infinity, maxHeight: totalHeight)  // TabViewの高さを設定
//    }
//
//    private var colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple]  // セクションごとの色
//}
//
//struct SectionView: View {
//    var sectionTitle: String
//    var color: Color
//    var elementHeight: CGFloat
//
//    var body: some View {
//        VStack {
//            Text(sectionTitle)
//                .foregroundColor(.white)
//                .font(.headline)
//        }
//        .frame(minWidth: 0, maxWidth: .infinity, minHeight: elementHeight, maxHeight: elementHeight)  // セクションの高さを56pxに固定
//        .background(color)
//        .cornerRadius(0)  // 角の丸みをなくす
//    }
//}
//
//struct CalendarView: View {
//    @Binding var firstWeekOpacity: Double
//    @State private var currentMonth: Date = Date()
//    // 選択されている月のインデックスを保持
//    @State private var selectedMonth: Int = 6
//    let paddingValue: CGFloat = 16
//    let cellSize: CGFloat = 40  // パディング用の変数
//
//
//
//
//    private var calendar: Calendar {
//        Calendar.current
//    }
//
//    private var year: Int {
//        calendar.component(.year, from: currentMonth)
//    }
//
//    private var month: Int {
//        calendar.component(.month, from: currentMonth)
//    }
//
//    var body: some View {
//        VStack {
//            Text("\(month)月 \(year)年")
//                .font(.headline)
//
//
//            TabView(selection: $selectedMonth) {
//                ForEach(0..<12, id: \.self) { monthOffset in
//                                VStack {
//                                    monthView(for: calendar.date(byAdding: .month, value: monthOffset - 6, to: currentMonth)!)
////                                    Spacer()  // VStack 内で Spacer を使用して内容を上部に押し上げる
//                                }
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                .padding(.horizontal, 8)
//                                .tag(monthOffset)
//                            }
//            }
//            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // ページインジケーターを非表示にする
//
//            .frame(height: ((cellSize+paddingValue)*2))
//            .overlay(
//                        RoundedRectangle(cornerRadius: 16)
//                            .stroke(Color.gray, lineWidth: 1)
//                    )
////            .onAppear {
////                            selectedMonth = 12  // 12番目の要素（現在の月）を初期選択として設定
////                        }
//        }
//    }
//
//    func monthView(for monthDate: Date) -> some View {
//        let days = daysInMonth(date: monthDate)
//        let currentWeekIndices = indicesOfCurrentWeek(date: monthDate, days: days)
//
//        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
//            ForEach(days.indices, id: \.self) { index in
//                VStack {
//                    Text(days[index] == 0 ? "" : "\(days[index])")
//                        .frame(width: cellSize, height: cellSize)  // Textの幅と高さを指定
//                        .foregroundColor(days[index] == calendar.component(.day, from: monthDate) ? Color.white : Color.black)
//                        .background(days[index] == calendar.component(.day, from: monthDate) ? Color.black : Color.clear)
//                        .cornerRadius(8)
//                        .overlay(
//                                        RoundedRectangle(cornerRadius: 0)  // 角丸の四角形をオーバーレイ
//                                            .stroke(Color.red, lineWidth: 1)  // 青色のボーダーを設定
//                                    )
//
//                    Spacer()
//                        .frame(height: 16)  // Spacerの高さを16pxに指定
//                }
//                .frame(height: (!currentWeekIndices.contains(index) ? (firstWeekOpacity > 0 ? (cellSize+paddingValue) : 0) : (cellSize+paddingValue)))  // VStackの高さを動的に設定
//                .opacity(!currentWeekIndices.contains(index) ? firstWeekOpacity : 1.0)
//                .overlay(
//                                RoundedRectangle(cornerRadius: 0)  // 角丸の四角形をオーバーレイ
//                                    .stroke(Color.blue, lineWidth: 1)  // 青色のボーダーを設定
//                            )
//            }
//
//        }.overlay(
//            RoundedRectangle(cornerRadius: 0)  // 角丸の四角形をオーバーレイ
//                .stroke(Color.green, lineWidth: 1)  // 青色のボーダーを設定
//        )
//    }
//
//    func daysInMonth(date: Date) -> [Int] {
//        var days = [Int]()
//        let range = calendar.range(of: .day, in: .month, for: date)!
//        let components = calendar.dateComponents([.year, .month], from: date)
//        let startOfMonth = calendar.date(from: components)!
//        let weekday = calendar.component(.weekday, from: startOfMonth)
//
//        for _ in 1..<weekday {
//            days.append(0) // 空の日を追加
//        }
//
//        for day in 1...range.count {
//            days.append(day)
//        }
//        return days
//    }
//
//    func indicesOfCurrentWeek(date: Date, days: [Int]) -> Range<Int> {
//        let dayOfMonth = calendar.component(.day, from: date)
//        if let dayIndex = days.firstIndex(of: dayOfMonth) {
//            let currentWeekday = calendar.component(.weekday, from: date)
//            let startOfWeekIndex = dayIndex - (currentWeekday - 1)
//            let endOfWeekIndex = startOfWeekIndex + 6
//            return startOfWeekIndex..<endOfWeekIndex + 1
//        } else {
//            return 0..<0
//        }
//    }
//}
//
//
//struct MainView: View {
//    @State private var firstWeekOpacity: Double = 1.0
//
//    var body: some View {
//        VStack {
//            CalendarView(firstWeekOpacity: $firstWeekOpacity)
//            Spacer()
//            Button("最初の週を隠す/表示") {
//                withAnimation(.easeInOut(duration: 0.2)) {
//                    firstWeekOpacity = firstWeekOpacity == 0 ? 1.0 : 0
//                }
//            }
//            .padding()
//        }
//    }
//}
//
//@main
//struct MyApp: App {
//    var body: some Scene {
//        WindowGroup {
//            HeaderView()
//            MainTabView()
//            MainView()
//        }
//    }
//}
