import SwiftUI
import FamilyControls

struct アプリルート: View {
    @StateObject var viewModel: TaskViewModel
    @AppStorage("isOnboardingCompleted") private var isOnboardingCompleted: Bool = false
    @AppStorage("task_disabled") private var taskDisabled: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss
    let center = AuthorizationCenter.shared
    @State private var path = NavigationPath()
    @State private var showSheet = false

//    @ObservedObject var diaryTaskManager = DiaryTaskManager.shared
    @StateObject var diaryTaskManager = DiaryTaskManager.shared
    var body: some View {
        Group {
//            if !isOnboardingCompleted {
//                OnboardingView(diaryTaskManager: diaryTaskManager, viewModel: viewModel, path: $path, onComplete: {
//                    isOnboardingCompleted = true
//                    print("isOnboardingCompleted = true")
//                })
//            } else {
//                ページ_日記リスト(diaryTaskManager: diaryTaskManager,viewModel: viewModel)
//            }
            ページ_日記リスト(diaryTaskManager: diaryTaskManager,viewModel: viewModel)
                .sheet(isPresented: $showSheet) {
                    オンボ_認証(center: center,onComplete: {
                        Task {
                            await requestAuthorizationIfNeeded() // 🔹 シートが閉じた後に認証処理を実行
                            showSheet=false
                        }
                    })
                        .interactiveDismissDisabled(true)
                }
                .allowsHitTesting(isOnboardingCompleted)

            // デバッグ用のリセットボタン
            Button("Reset Onboarding (Debug)") {
                isOnboardingCompleted = false // AppStorageをリセット
                print("isOnboardingCompleted = false")
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .fullScreenCover(isPresented: .constant(!isOnboardingCompleted)) {
                    OnboardingView(
                        diaryTaskManager: diaryTaskManager,
                        viewModel: viewModel,
                        path: $path,
                        onComplete: {
                            // onCompleteが呼ばれたらシートを閉じる
                            isOnboardingCompleted = true
                            print("Onboarding completed!")
                        }
                    )
//                    .presentationDetents([.large])
//                    .presentationDragIndicator(.hidden)
//                    .interactiveDismissDisabled()

                }


        //        .onChange(of: path) { newPath in
        //                        if newPath.count > 0 {
        //                            print("次の画面に遷移しました: \(newPath)")
        //                        }
        //                    }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                print("アプリがアクティブになりました")

                //オンボードが完了、またはオンボーディングのオンボ_認証以外の時、showSheetでオンボ_認証を表示してない場合に実行
//                if (isOnboardingCompleted || path.count > 0) && !showSheet{
//                    Task {
//                        await requestAuthorizationIfNeeded()
//                    }
//                }
                
                //タスクが有効なら
//                if !taskDisabled {
//                    let scheduledActivities = getAllScheduledActivities()
//                    if scheduledActivities.isEmpty {
//                        // 🔹 `diaryTaskManager.diaryTask.weekDays` が空でなければ
//                        if !diaryTaskManager.diaryTask.weekDays.isEmpty {
//                            diaryTaskManager.updateTask { result in
//                                switch result {
//                                case .success:
//                                    print("[scenePhase:active]✅ タスクの更新が成功しました！")
//                                case .failure(let error):
//                                    print("[scenePhase:active]❌ タスクの更新に失敗: \(error.localizedDescription)")
//                                }
//                            }
//                        } else {
//                            print("[scenePhase:active] ⚠️ `diaryTaskManager.diaryTask.weekDays` が空のため `updateTask()` は実行されません。")
//                        }
//                    }
//                    else{
//                        print("[scenePhase:active] スケジュールがあります")
//                    }
//                }

                if(isOnboardingCompleted && !showSheet){
                    Task {
                        await requestAuthorizationIfNeeded()
                    }
                }

            case .inactive, .background:
                print("アプリが非アクティブまたはバックグラウンドに移動しました")
            @unknown default:
                break
            }
        }
    }

    private func requestAuthorizationIfNeeded() async {
        do {
            try await center.requestAuthorization(for: .individual)
            print("[requestAuthorizationIfNeeded]✅認証リクエスト成功")
            //認証済みかつタスクが有効なら
            if !taskDisabled {
                let scheduledActivities = getAllScheduledActivities()
                if scheduledActivities.isEmpty {
                    // 🔹 `diaryTaskManager.diaryTask.weekDays` が空でなければ
                    if !diaryTaskManager.diaryTask.weekDays.isEmpty {
                        diaryTaskManager.updateTask { result in
                            switch result {
                            case .success:
                                print("[scenePhase:active]✅ タスクの更新が成功しました！")
                            case .failure(let error):
                                print("[scenePhase:active]❌ タスクの更新に失敗: \(error.localizedDescription)")
                            }
                        }
                    } else {
                        print("[scenePhase:active] ⚠️ `diaryTaskManager.diaryTask.weekDays` が空のため `updateTask()` は実行されません。")
                    }
                }
                else{
                    print("[scenePhase:active] スケジュールがあります")
                }
            }
        } catch let error as FamilyControlsError {
            switch error {
            case .authorizationCanceled:
                print("[requestAuthorizationIfNeeded]認証がキャンセルされました")
                DispatchQueue.main.async {
                    showSheet = true // シートを表示
                }
            case .restricted:
                print("[requestAuthorizationIfNeeded]使用が制限されています")
            case .unavailable:
                print("[requestAuthorizationIfNeeded]Family Controls が利用できません")
            case .invalidAccountType:
                print("[requestAuthorizationIfNeeded]無効なアカウントタイプです")
            case .networkError:
                print("[requestAuthorizationIfNeeded]ネットワークエラーが発生しました")
            case .authorizationConflict:
                print("[requestAuthorizationIfNeeded]既に他のアプリが管理を行っています")
            default:
                print("[requestAuthorizationIfNeeded]その他のエラー: \(error.localizedDescription)")
            }
        } catch {
            print("[requestAuthorizationIfNeeded]予期しないエラー: \(error.localizedDescription)")
        }
    }
}




//struct UserDefaultsExampleView: View {
//    @State private var savedValue: Bool = UserDefaults.standard.bool(forKey: "Boolean") // 初期値読み込み
//    @State private var newValue: Bool = false // トグルで切り替える新しい値
//
//    var body: some View {
//        VStack(spacing: 20) {
//            // 現在の保存された値を表示
//            Text("Saved Value: \(savedValue ? "true" : "false")")
//                .font(.headline)
//
//            // 新しい値を設定するトグル
//            Toggle("New Value to Save:", isOn: $newValue)
//                .padding()
//
//            // 保存ボタン
//            Button("Save to UserDefaults") {
//                saveValueToUserDefaults()
//            }
//            .padding()
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(8)
//
//            // 読み込みボタン
//            Button("Reload Saved Value") {
//                reloadValueFromUserDefaults()
//            }
//            .padding()
//            .background(Color.green)
//            .foregroundColor(.white)
//            .cornerRadius(8)
//
//            // デフォルト値を取得する例
//            Button("Load with Default Value") {
//                let defaultValue = UserDefaults.standard.object(forKey: "Boolean3") as? Bool ?? true
//                print("Default Value for 'Boolean3': \(defaultValue)")
//            }
//            .padding()
//            .background(Color.orange)
//            .foregroundColor(.white)
//            .cornerRadius(8)
//        }
//        .padding()
//    }
//
//    /// 値を UserDefaults に保存
//    private func saveValueToUserDefaults() {
//        UserDefaults.standard.set(newValue, forKey: "Boolean")
//        print("Value '\(newValue)' saved to UserDefaults for key 'Boolean'.")
//    }
//
//    /// 保存された値を読み込み
//    private func reloadValueFromUserDefaults() {
//        let value = UserDefaults.standard.bool(forKey: "Boolean")
//        savedValue = value
//        print("Reloaded Value from UserDefaults: \(value)")
//    }
//}
//
//struct UserDefaultsExampleView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDefaultsExampleView()
//    }
//}




import SwiftUI

struct MainDiaryView: View { // ContentView を MainDiaryView に変更
    @State private var isSheetPresented: Bool
    @State private var isInteractionDisabled: Bool = false
    init() {
        _isSheetPresented = State(initialValue: true)
    }

    var body: some View {
        VStack {
                    Text("メイン画面")
                        .font(.largeTitle)
                        .padding()

                    Button("操作を無効化") {
                        isInteractionDisabled = true
                    }

                    Button("操作を有効化") {
                        isInteractionDisabled = false
                    }
                }
                .allowsHitTesting(!isInteractionDisabled) // Bool に基づいて操作を有効化／無効化
            }
//        Text("メイン画面")
//            .sheet(isPresented: $isSheetPresented) {
//                OnboardingView2(isSheetPresented: $isSheetPresented)
//            }
    }


struct OnboardingView2: View {
    @Binding var isSheetPresented: Bool

    var body: some View {
        VStack {
            Text("オンボーディング画面")
                .font(.largeTitle)
                .padding()

            Button("閉じる") {
                isSheetPresented = false
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue.opacity(0.2))
    }
}
