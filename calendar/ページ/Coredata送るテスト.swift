import SwiftUI
import Combine
import SwiftSVG
import FamilyControls

struct CustomNavigationBar: View {
    let title: String
    let onBack: (() -> Void)?
    let onAction: (() -> Void)?

    var body: some View {
        HStack {
            if let onBack = onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
            } else {
                Spacer()
            }

            Spacer()

            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            Spacer()

            if let onAction = onAction {
                Button(action: onAction) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                }
            } else {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 16) // 上下のパディングを設定
        .background(Color.blue)
    }
}

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

enum OnboardingStep {
    case blockAppPicker, timeSetting, characterCountSetting
}

struct OnboardingView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var path = NavigationPath()

    @State private var currentStep: OnboardingStep = .blockAppPicker

    @State private var activitySelection = FamilyActivitySelection()
    @State private var navigateToNext = false // 次の画面への遷移フラグ
    var onComplete: () -> Void
    @StateObject private var taskData = TaskData() // データを保持する
    @State private var isLoading = false // ナビゲーションを有効/無効にするフラグ
    @State private var showAlert = false // アラート表示フラグ

    var body: some View {
        NavigationStack(path: $path) {
            オンボ_スクリーンタイム(path: $path) // 1番目に表示したいビューをここに設定
                .navigationDestination(for: String.self) { destination in
                    switch destination {
                    case "A":
                        オンボ_アプリピッカー(activitySelection: $activitySelection, /*taskData: taskData,*/ onComplete: onComplete, path: $path)
                    case "B":
                        オンボ_時間設定(taskData: taskData, path: $path)
                    case "C":
                        オンボ_文字数設定(taskData: taskData, isLoading: $isLoading, path: $path, updateTask: updateTask/*, isNavigationEnabled: $isNavigationEnabled*/)
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

        

        //        NavigationStack {
        //            switch currentStep {
        //            case .blockAppPicker:
        //                オンボ_アプリピッカー(
        //                    activitySelection: $activitySelection,
        //                    taskData: taskData,
        //                    onComplete: onComplete,
        //                    onNext: {
        //                        currentStep = .timeSetting
        //                    }
        //                )
        //            case .timeSetting:
        //                オンボ_時間設定(taskData: taskData) {
        //                    currentStep = .characterCountSetting
        //                }
        //            case .characterCountSetting:
        //                オンボ_文字数設定 {
        //                    print("Onboarding Completed")
        //                }
        //            }
        //            //            VStack(spacing: 0) {
        //            //                Button("Complete Onboarding") {
        //            //                    onComplete()
        //            //                }
        //            //                .padding()
        //            //                .background(Color.blue)
        //            //                .foregroundColor(.white)
        //            //                .cornerRadius(8)
        //            //
        //            //
        //            //                Spacer()
        //            //                    .frame(height:20)
        //            //                VStack(spacing: 8) {
        //            //                    Text("ブロックしたいアプリを\n選択しましょう")
        //            //                        .font(.title2)
        //            //                        .fontWeight(.bold)
        //            //                        .multilineTextAlignment(.center)
        //            //                        .frame(maxWidth: .infinity)
        //            //                    Text("あとから変更できます")
        //            //                        .fontWeight(.bold)
        //            //                        .foregroundStyle(Color.secondary)
        //            //                }
        //            //                Spacer()
        //            //                    .frame(height: 40)
        //            //                ZStack {
        //            //                    Image("iPhone15_Pro_app_picker_png") // 画像ファイル名（拡張子不要）
        //            //                        .resizable()
        //            //                        .scaledToFit()
        //            //                        .frame(maxWidth: .infinity)
        //            //                    VStack(spacing:0) {
        //            //                        Spacer()
        //            //                        パーツ_ライナーグラデーション(height: 100)
        //            //                        VStack{
        //            //                            Spacer().frame(height:24)
        //            //                            Button("Select Activities") {
        //            //                                isPresented = true // ピッカーを表示
        //            //                            }
        //            //                            .familyActivityPicker(
        //            //                                isPresented: $isPresented,
        //            //                                selection: $activitySelection // 選択結果を一時保存
        //            //                            ).onChange(of: isPresented) { newValue in
        //            //                                if !newValue {
        //            //                                    // FamilyActivityPickerが閉じられたときに実行
        //            //                                    print("Selected Activities: \(activitySelection)")
        //            //                                    navigateToNext = true
        //            //                                }
        //            //                            }
        //            //                            NavigationLink(destination: オンボ_時間設定(taskData: taskData)) {
        //            //                                Text("アプリを選択する") // ボタンの内容
        //            //                                    .padding(.vertical, 16)
        //            //                                    .frame(maxWidth: .infinity)
        //            //                                    .background(Color.buttonOrange)
        //            //                                    .foregroundColor(.white)
        //            //                                    .fontWeight(.bold)
        //            //                                    .cornerRadius(12)
        //            //
        //            //                            }
        //            //                            .padding(.bottom, 20)
        //            //
        //            //
        //            //                            Text("a")
        //            //                                .foregroundStyle(.primary)
        //            //                                .opacity(00)
        //            //                        }
        //            //                        .background(Color(.systemBackground))
        //            //
        //            //                    }
        //            //                }
        //            //                Spacer()
        //            //                    .frame(height: 20)
        //            //            }
        //            //            .toolbar {
        //            //                ToolbarItem(placement: .principal) {
        //            //                    Text("")
        //            //                }
        //            //            }
        //            //            .navigationBarTitleDisplayMode(.inline)
        //            //            .padding(.horizontal, 20)
        //
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

struct オンボ_スクリーンタイム: View {
    @State private var isPresented = false

//    var onComplete: () -> Void
    //    var onNext: () -> Void
    @Binding var path: NavigationPath

    @State private var navigateToNext = false

    var body: some View {
        VStack(spacing: 0) {
//            Button("Complete Onboarding") {
//                onComplete()
//            }
//            .padding()
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(8)

            Spacer()
                .frame(height: 20)

            VStack(spacing: 8) {
                Text("スクリーンタイムへのアクセスを\n許可してください")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

            }

            Spacer()
                .frame(height: 24)
            Image("iPhone15_Pro_ScreenTime_Cutted")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
            ZStack {
                    VStack {

//                        Button("Go to A") {
//                            path.append("A") // 次の画面へ遷移
//                        }
                        Text("アプリやサイトをブロックするためには\nスクリーンタイムへの許可が必要です")
                            .font(.callout)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        Spacer().frame(height: 16)
                        パーツ_共通ボタン(ボタンテキスト: "アプリを選択する", action: {isPresented = true})
//                            .familyActivityPicker(
//                                isPresented: $isPresented,
//                                selection: $activitySelection
//                            )
//                            .onChange(of: isPresented) { newValue in
//                                if !newValue {
//                                    print("Selected Activities: \(activitySelection)")
//                                    navigateToNext = true
//                                }
//                            }
//                        NavigationLink(destination: オンボ_時間設定(taskData: taskData), isActive: $navigateToNext) {
//                            Text("アプリを選択する")
//                                .padding(.vertical, 16)
//                                .frame(maxWidth: .infinity)
//                                .background(Color.buttonOrange)
//                                .foregroundColor(.white)
//                                .fontWeight(.bold)
//                                .cornerRadius(12)
//                        }
//                        .padding(.bottom, 20)

//                        Text("a")
//                            .foregroundStyle(.primary)
//                            .opacity(0)
//                            .padding(.vertical, 20)
                        Spacer().frame(height: 16)

                    }
                    .background(Color(.systemBackground))

            }

//            Spacer()
//                .frame(height: 20)
        }
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text("")
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 20)
    }
}


struct オンボ_アプリピッカー: View {
    @State private var isPresented = false
    @Binding var activitySelection: FamilyActivitySelection
//    @ObservedObject var taskData: TaskData
    var onComplete: () -> Void
    //    var onNext: () -> Void
    @Binding var path: NavigationPath

    @State private var navigateToNext = false

    var body: some View {
        VStack(spacing: 0) {
//            Button("Complete Onboarding") {
//                onComplete()
//            }
//            .padding()
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(8)

            Spacer()
                .frame(height: 20)

            VStack(spacing: 8) {
                Text("ブロックしたいアプリを\n選択しましょう")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                Text("あとから変更できます")
                    .fontWeight(.bold)
                    .foregroundStyle(Color.secondary)
            }

            Spacer()
                .frame(height: 32)
            Image("iPhone15_Pro_ScreenTime_Access")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
            ZStack {
                VStack(spacing: 0) {
//                    Spacer()
//                    パーツ_ライナーグラデーション(height: 40)

                    VStack {
                        Spacer().frame(height: 16)

                        Button("Go to B") {
                            path.append("B") // 次の画面へ遷移
                        }
                        パーツ_共通ボタン(ボタンテキスト: "アプリを選択する", action: {isPresented = true})
                            .familyActivityPicker(
                                isPresented: $isPresented,
                                selection: $activitySelection
                            )
                            .onChange(of: isPresented) { newValue in
                                if !newValue {
                                    print("Selected Activities: \(activitySelection)")
                                    navigateToNext = true
                                }
                            }
//                        NavigationLink(destination: オンボ_時間設定(taskData: taskData), isActive: $navigateToNext) {
//                            Text("アプリを選択する")
//                                .padding(.vertical, 16)
//                                .frame(maxWidth: .infinity)
//                                .background(Color.buttonOrange)
//                                .foregroundColor(.white)
//                                .fontWeight(.bold)
//                                .cornerRadius(12)
//                        }
//                        .padding(.bottom, 20)

                        Text("a")
                            .foregroundStyle(.primary)
                            .opacity(0)
                            .padding(.vertical, 20)
                    }
                    .background(Color(.systemBackground))
                }
            }

//            Spacer()
//                .frame(height: 20)
        }
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text("")
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 20)
    }
}

struct オンボ_時間設定: View {
    @ObservedObject var taskData: TaskData
    @Binding var path: NavigationPath

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
                    .fontWeight(.bold)
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading) // 左寄せのフレーム設定
            }

            Spacer()
                .frame(height:40)
            パーツ_時刻選択(開始時刻: $taskData.startTime, 終了時刻: $taskData.endTime)
                .background(Color.darkButton_normal)
                .cornerRadius(12)
            Spacer()
                .frame(height:32)
            パーツ_曜日選択ビュー(繰り返し曜日: $taskData.repeatDays)
                .background(Color.darkButton_normal)
                .cornerRadius(12)
            Spacer()
            //            Spacer()
            //                .frame(height: 40)

            ZStack {
                VStack{
                    パーツ_共通ボタン(ボタンテキスト: "つぎへ", action: {path.append("C")})

//                    NavigationLink(destination: オンボ_文字数設定(taskData: taskData)) {
//                        Text("次へ") // ボタンの内容
//                            .padding(.vertical, 16)
//                            .frame(maxWidth: .infinity)
//                            .background(Color.buttonOrange)
//                            .foregroundColor(.white)
//                            .fontWeight(.bold)
//                            .cornerRadius(12)
//
//                    }
//                    .padding(.vertical, 20)


                    Text("a")
                        .foregroundStyle(.primary)
                        .opacity(0)
                        .padding(.vertical, 20)
                }
                .background(Color(.systemBackground))


            }
//            Spacer()
//                .frame(height: 20)

        }
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text("")
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
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
                    .fontWeight(.bold)
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading) // 左寄せのフレーム設定
            }

            VStack {
                Spacer()

                HStack(alignment: .bottom, spacing: 4) {
                    TextField(
                        "10",
                        text: Binding(
                            get: { String(taskData.characterCount) }, // Int -> String
                            set: { newValue in
                                if let intValue = Int(newValue), intValue >= 0 {
                                    taskData.characterCount = intValue // String -> Int
                                }
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
                    .onReceive(Just(taskData.characterCount.description)) { _ in
                        // 最大文字数の制限を適用
                        if taskData.characterCount.description.count > maxLength {
                            let limitedValue = Int(taskData.characterCount.description.prefix(maxLength)) ?? taskData.characterCount
                            taskData.characterCount = limitedValue
                        }
                    }

                    // 右側に「文字」を表示
                    Text("文字")
                        .font(.callout) // Callout サイズ
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 6)
                }

                Spacer() // 下のスペース
            }
            ZStack {
                VStack {
                    パーツ_ボタン_ローディング(isLoading: $isLoading,ボタンテキスト: "完了", action: {updateTask { success in
                        if success {
                            print("success:::\(success)")
                            path.append("D")
                        }
                    }})
                }
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
