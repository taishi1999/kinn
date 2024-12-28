import SwiftUI
import FamilyControls

@main
struct ScreenTimeApp: App {

    let center = AuthorizationCenter.shared
    @StateObject private var manager = ShieldManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ShieldView(manager: manager)
                .preferredColorScheme(.dark)
                .task {
                    do {
                        try await center.requestAuthorization(for: .individual)
                    } catch {
                        print("Failed to get authorization: \(error)")
                    }

                }
//                .onChange(of: scenePhase) { newPhase in
//                    switch newPhase {
//                    case .active:
//                        print("アプリがアクティブになりました")
//                        manager.startMonitoringBlockedState()
//                    case .inactive, .background:
//                        print("アプリが非アクティブまたはバックグラウンドに移動しました")
//                        manager.stopMonitoringBlockedState()
//                    @unknown default:
//                        break
//                    }
//                }
        }
    }
}
