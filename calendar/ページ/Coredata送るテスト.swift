import SwiftUI
import Combine
import SwiftSVG
import FamilyControls

enum OnboardingStep {
    case blockAppPicker, timeSetting, characterCountSetting
}

struct OnboardingView: View {
    @ObservedObject var diaryTaskManager: DiaryTaskManager
    @ObservedObject var viewModel: TaskViewModel
//    @State private var path = NavigationPath()
    @Binding var path: NavigationPath
    @State private var currentStep: OnboardingStep = .blockAppPicker

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
                center: center)

//            Group {
//                if center.authorizationStatus == .approved {
//                    // 認証済みの場合
//                    オンボ_アプリピッカー(/*activitySelection: $activitySelection,*/ onComplete: onComplete, path: $path, diaryTaskManager: diaryTaskManager)
//                } else {
//                    // 認証が必要な場合
//                    オンボ_認証(path: .constant(path), center: center)
//
//                }
//            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "A":
                    オンボ_アプリピッカー(/*activitySelection: $activitySelection,*/ /*taskData: taskData,*/ onComplete: onComplete, path: $path,diaryTaskManager: diaryTaskManager)
                        .navigationBarBackButtonHidden(true)//上記バー非表示
//                        .onAppear {
//                                        Task {
//                                            try await center.requestAuthorization(for: .individual)
//                                        }
//                                    }
                case "B":
                    オンボ_時間設定(taskData: taskData, path: $path,diaryTaskManager: diaryTaskManager)
                        .navigationBarBackButtonHidden(true)
                case "C":
                    オンボ_文字数設定(taskData: taskData, isLoading: $isLoading, path: $path, updateTask: updateTask,diaryTaskManager: diaryTaskManager/*, isNavigationEnabled: $isNavigationEnabled*/)
                        .navigationBarBackButtonHidden(true)
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

    // タスク更新メソッド
    private func updateTask(completion: @escaping (Bool) -> Void) {
        isLoading = true
        viewModel.updateTask(
            taskType: taskData.taskType,
            startTime: taskData.startTime,
            endTime: taskData.endTime,
            repeatDays: taskData.repeatDays,
            characterCount: taskData.characterCount,
            context: viewModel.coredata_MyTask.managedObjectContext!
        ) { success in
            DispatchQueue.main.async {
                isLoading = false
                if success {
                    print("Task updated successfully in OnboardingView")
                    onComplete() // Onboarding完了処理
                } else {
                    print("Failed to update task in OnboardingView")
                    showAlert = true
                }
                completion(success)
            }
        }
    }
}

struct オンボ_認証: View {
    @State private var isLoading = false
    //    let center = AuthorizationCenter.shared
//    @Binding var path: NavigationPath
    @Binding var path: NavigationPath?


    /*var path: Binding<NavigationPath?>*/ // nil 許容のナビゲーションパス
    //    @ObservedObject var diaryTaskManager: DiaryTaskManager

    @State private var navigateToNext = false
    @State private var cancellable: AnyCancellable? // Combineのキャンセラ
    @ObservedObject var center: AuthorizationCenter
    @Environment(\.dismiss) private var dismiss
    //nil許容のために必要
    init(path: Binding<NavigationPath?> = .constant(nil), center: AuthorizationCenter) {
            self._path = path
            self.center = center
        }

    var body: some View {
        VStack(spacing: 0) {
//           
            Spacer()
                .frame(height: 16)
            Image("iPhone15_Pro_ScreenTime_Cutted")
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
                                
                                DispatchQueue.main.async {
                                    print("完了")
                                    isLoading = false
                                    path?.append("A")
                                    dismiss()
//                                    if var path = path.wrappedValue {
//                                        path.append("A")
//                                    }
                                }
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

    private func checkAuthorizationAndNavigate() async {
            // 非同期で認証状態を確認
            do {
                try await center.requestAuthorization(for: .individual)

//                DispatchQueue.main.async {
//                    if center.authorizationStatus == .approved {
//                        print("approveです")
//                        path?.append("A")
//                    }
//                    else{
//                        print("elseです")
//                    }
//                }
            } catch {
                print("認証リクエスト中にエラーが発生しました: \(error)")
            }
        }

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
            Image("iPhone15_Pro_app_picker")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
            Spacer()
                .frame(height: 16)
            VStack(spacing: 8) {
                Text("ブロックしたいアプリを\n選択しましょう")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            ZStack {
                VStack(spacing: 0) {
                    VStack {
                        Spacer().frame(height: 16)

                        Button("Go to B") {
                            path.append("B") // 次の画面へ遷移
                        }
                        Text("あとから変更できます")
                            .font(.callout)
                        //                            .fontWeight(.bold)
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        パーツ_共通ボタン(ボタンテキスト: "アプリを選択する", action: {
                            isPresented = true
                        })
                            .familyActivityPicker(
                                isPresented: $isPresented,
                                selection: $diaryTaskManager.selection
                            )
                            .onChange(of: diaryTaskManager.selection) { newSelection in
//                                print("選択されたアプリ: \(newSelection.applications)")
//                                print("選択されたカテゴリ: \(newSelection.categories)")
//                                print("選択されたウェブドメイン: \(newSelection.webDomains)")
                                if isSelectionExist(initialSelection: newSelection){
                                    path.append("B")
                                }
//                                if !newSelection.applications.isEmpty ||
//                                            !newSelection.categories.isEmpty ||
//                                            !newSelection.webDomains.isEmpty {
//                                            path.append("B")
//                                        }
                            }
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
    @ObservedObject var taskData: TaskData
    @Binding var path: NavigationPath
    @ObservedObject var diaryTaskManager: DiaryTaskManager

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height:20)

            VStack(alignment: .leading, spacing: 8) {
                Text("ブロックしたい時間帯を\n設定しましょう")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading) // 左揃えにする
                    .frame(maxWidth: .infinity, alignment: .leading) // 左寄せのフレーム設定

                Text("あとから変更できます")
                //                    .fontWeight(.bold)
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading) // 左寄せのフレーム設定
            }

            Spacer()
                .frame(height:40)
            パーツ_時刻選択(開始時刻: $diaryTaskManager.diaryTask.startTime, 終了時刻: $diaryTaskManager.diaryTask.endTime)
            //            パーツ_時刻選択(開始時刻: $taskData.startTime, 終了時刻: $taskData.endTime)
                .background(Color.darkButton_normal)
                .cornerRadius(12)
            Spacer()
                .frame(height:32)
//            パーツ_曜日選択ビュー(繰り返し曜日: $taskData.repeatDays)
            パーツ_曜日選択ビュー(繰り返し曜日: $diaryTaskManager.diaryTask.weekDays)
                .background(Color.darkButton_normal)
                .cornerRadius(12)
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
        .padding(.horizontal, 20)
    }
}

struct オンボ_文字数設定: View {
    @FocusState private var isFocused: Bool
    private let maxLength: Int = 4
    @ObservedObject var taskData: TaskData
    //    @State private var isLoading = false
    @Binding var isLoading: Bool
    @Binding var path: NavigationPath
    //    @Binding var isNavigationEnabled: Bool
    var updateTask: (@escaping (Bool) -> Void) -> Void // クロージャを引数に追加
    @ObservedObject var diaryTaskManager: DiaryTaskManager

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 20)

            VStack(alignment: .leading, spacing: 8) {
                Text("何文字日記を書いたら\nブロックを解除しますか？")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading) // 左揃えにする
                    .frame(maxWidth: .infinity, alignment: .leading) // 左寄せのフレーム設定

                Text("あとから変更できます")
                //                    .fontWeight(.bold)
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading) // 左寄せのフレーム設定
            }

            VStack {
                Spacer()
                Button("save") {
                    diaryTaskManager.diaryTask.selectionID="selection_1"

                    diaryTaskManager.saveDiaryTask(
                        diaryTaskManager.diaryTask,
                        selection: diaryTaskManager.selection,
                        taskKey: "diary",
                        selectionKey: "selection_1"
                    )

                    //ロード
                    diaryTaskManager.loadTaskAndSelection()
                }
                Button("delete") {
                    diaryTaskManager.deleteDiaryTask(taskKey: "diary", selectionKey: "selection_1")
                }
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
                    .keyboardType(.numberPad) // 数字入力専用のキーボードを設定
                    .fixedSize()
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .focused($isFocused) // フォーカス状態をバインド
                    .onAppear {
                        isFocused = true
                    }
                    //                    .onReceive(Just(diaryTaskManager.diaryTask.characterCount.description)) { _ in
                    //                        // 最大文字数の制限を適用
                    //                        if diaryTaskManager.diaryTask.characterCount.description.count > maxLength {
                    //                            let limitedValue = Int(diaryTaskManager.diaryTask.characterCount.description.prefix(maxLength)) ?? diaryTaskManager.diaryTask.characterCount
                    //                            diaryTaskManager.diaryTask.characterCount = limitedValue
                    //                        }
                    //                    }

                    // 右側に「文字」を表示
                    Text("文字")
                        .font(.callout) // Callout サイズ
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 6)
                }

                Spacer() // 下のスペース
            }

            VStack {
                パーツ_ボタン_ローディング(isLoading: $isLoading,ボタンテキスト: "完了", action: {updateTask { success in
                    if success {
                        print("success:::\(success)")
                        path.append("D")
                    }
                }})
                Spacer().frame(height: 16)
            }



        }
        //        .toolbar {
        //            ToolbarItem(placement: .principal) {
        //                Text("")
        //            }
        //        }
        //        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 20)

        // ローディング中に画面操作を無効化
        //        .blur(radius: isLoading ? 3 : 0) // ローディング中は画面をぼかす
        //        .animation(.easeInOut, value: isLoading)
    }
}


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
