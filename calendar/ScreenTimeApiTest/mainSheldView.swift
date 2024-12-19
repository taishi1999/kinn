import SwiftUI
import FamilyControls

//@main
struct ScreenTimeApp: App {

    let center = AuthorizationCenter.shared

    var body: some Scene {
        WindowGroup {
            ShieldView()
                .preferredColorScheme(.dark)
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
