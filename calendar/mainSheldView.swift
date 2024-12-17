//import SwiftUI
//
//@main
//struct MainShieldViewApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ShieldView() // ShieldView() を実行
//        }
//    }
//}

import SwiftUI
import FamilyControls

@main
struct ScreenTimeApp: App {

    let center = AuthorizationCenter.shared

    var body: some Scene {
        WindowGroup {
            ShieldView()                
                .task {
                do {
                    try await center.requestAuthorization(for: .individual)
                } catch {
                    print("Failed to get authorization: \(error)")
                }
            }
        }
    }
}
