import SwiftUI
import FamilyControls
import DeviceActivity // 必須のフレームワーク

extension DeviceActivityName {
    static let daily = DeviceActivityName("daily") // 静的プロパティを定義
}
struct ShieldView: View {

    @StateObject private var manager = ShieldManager()
    @State private var showActivityPicker = false
    private let center = DeviceActivityCenter()

    var body: some View {
        VStack {
            
            Button {
                showActivityPicker = true
            } label: {
                Label("Configure activities", systemImage: "gearshape")
            }
            .buttonStyle(.borderedProminent)

            Button("Apply Shielding") {
                startMonitoring()
//                manager.shieldActivities()
            }
            .buttonStyle(.bordered)
        }
        .familyActivityPicker(isPresented: $showActivityPicker, selection: $manager.discouragedSelections)
    }


    private func startMonitoring() {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 11, minute: 47),
            intervalEnd: DateComponents(hour: 20, minute: 0),
            repeats: true
        )

        do {
            try center.startMonitoring(.daily, during: schedule)
        } catch {
            print ("Could not start monitoring \(error)")
        }
    }

}

