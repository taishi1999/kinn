import SwiftUI

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


struct アプリルート: View {
    @StateObject var viewModel: TaskViewModel
    @AppStorage("isOnboardingCompleted") private var isOnboardingCompleted: Bool = false // AppStorageを使用
    

    var body: some View {
        VStack {
            if !isOnboardingCompleted {
                OnboardingView(viewModel: viewModel, onComplete: {
                    isOnboardingCompleted = true // AppStorageで状態を更新
                    print("isOnboardingCompleted = true")
                })
            } else {
                ページ_日記リスト(viewModel: viewModel)
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
    }
}

