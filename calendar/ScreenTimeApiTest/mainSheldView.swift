import SwiftUI
import FamilyControls

//@main
struct ScreenTimeApp: App {

    let center = AuthorizationCenter.shared
    @StateObject private var manager = ShieldManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ShieldView(manager: manager)
                .preferredColorScheme(.dark)
//                .task {
//                    await requestAuthorizationIfNeeded()
////                    do {
////                        try await center.requestAuthorization(for: .individual)
////                    } catch {
////                        //todo スクリーンタイムへの認証
////                        print("Failed to get authorization: \(error)")
////                    }
//
//                }
                .onChange(of: scenePhase) { newPhase in
                    switch newPhase {
                    case .active:
                        print("アプリがアクティブになりました")
                        Task {
                            await requestAuthorizationIfNeeded()
                        }
                        //                        manager.startMonitoringBlockedState()
                    case .inactive, .background:
                        print("アプリが非アクティブまたはバックグラウンドに移動しました")
                        //                        manager.stopMonitoringBlockedState()
                    @unknown default:
                        break
                    }
                }
        }
    }
    private func requestAuthorizationIfNeeded() async {
            do {
                try await center.requestAuthorization(for: .individual)
                print("認証リクエスト成功")
            } catch {
                print("認証リクエスト失敗: \(error)")
                // 認証エラー時の処理を追加
            }
        }

//    private func checkAuthorizationStatus() {
//            switch center.authorizationStatus {
//            case .notDetermined:
//                print("認証状態: 未決定")
//            case .denied:
//                print("認証状態: 拒否されました")
//            case .approved:
//                print("認証状態: 承認されました")
//            @unknown default:
//                print("認証状態: 不明な状態")
//            }
//        }
}
