import SwiftUI
import FamilyControls

struct アプリルート: View {
    @StateObject var viewModel: TaskViewModel
    @AppStorage("isOnboardingCompleted") private var isOnboardingCompleted: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    let center = AuthorizationCenter.shared
    @State private var path = NavigationPath()
    @State private var showSheet = false

    @ObservedObject var diaryTaskManager = DiaryTaskManager.shared
    var body: some View {
        Group {
            if !isOnboardingCompleted {
                OnboardingView(diaryTaskManager: diaryTaskManager, viewModel: viewModel, path: $path, onComplete: {
                    isOnboardingCompleted = true
                    print("isOnboardingCompleted = true")
                })
            } else {
                ページ_日記リスト(diaryTaskManager: diaryTaskManager,viewModel: viewModel)
            }

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
        .sheet(isPresented: $showSheet) {
            オンボ_認証(center: center)
                .interactiveDismissDisabled(true)
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

                //オンボードが完了、またはオンボ_認証以外の時、showSheetでオンボ_認証を表示してない場合に実行

                if (isOnboardingCompleted || path.count > 0) && !showSheet{
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
            print("認証リクエスト成功")
        } catch let error as FamilyControlsError {
            switch error {
            case .authorizationCanceled:
                print("認証がキャンセルされました")
                DispatchQueue.main.async {
                    showSheet = true // シートを表示
                }
            case .restricted:
                print("使用が制限されています")
            case .unavailable:
                print("Family Controls が利用できません")
            case .invalidAccountType:
                print("無効なアカウントタイプです")
            case .networkError:
                print("ネットワークエラーが発生しました")
            case .authorizationConflict:
                print("既に他のアプリが管理を行っています")
            default:
                print("その他のエラー: \(error.localizedDescription)")
            }
        } catch {
            print("予期しないエラー: \(error.localizedDescription)")
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




