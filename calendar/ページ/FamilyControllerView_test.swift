import SwiftUI
import FamilyControls
import Combine
import ManagedSettings
import DeviceActivity

//--http://pedroesli.com/2023-11-13-screen-time-api/


struct DataBase {
    private let defaults = UserDefaults(suiteName: "group.com.karasaki.kinn.data")
    private let applicationProfileKey = "ApplicationProfile"

    func getApplicationProfiles() -> [UUID: ApplicationProfile] {
        guard let data = defaults?.data(forKey: applicationProfileKey) else { return [:] }
        guard let decoded = try? JSONDecoder().decode([UUID: ApplicationProfile].self, from: data) else { return [:] }
        return decoded
    }

    func getApplicationProfile(id: UUID) -> ApplicationProfile? {
        return getApplicationProfiles()[id]
    }

    func addApplicationProfile(_ application: ApplicationProfile) {
        var applications = getApplicationProfiles()
        applications.updateValue(application, forKey: application.id)
        saveApplicationProfiles(applications)
    }

    func saveApplicationProfiles(_ applications: [UUID: ApplicationProfile]) {
        guard let encoded = try? JSONEncoder().encode(applications) else { return }
        defaults?.set(encoded, forKey: applicationProfileKey)
    }

    func removeApplicationProfile(_ application: ApplicationProfile) {
        var applications = getApplicationProfiles()
        applications.removeValue(forKey: application.id)
        saveApplicationProfiles(applications)
    }
}

//import Foundation
//import ManagedSettings

struct ApplicationProfile: Codable, Hashable {
    let id: UUID
    let applicationToken: ApplicationToken

    init(id: UUID = UUID(), applicationToken: ApplicationToken) {
        self.applicationToken = applicationToken
        self.id = id
    }
}

class ShieldManager: ObservableObject {
    @Published var discouragedSelections = FamilyActivitySelection()

    private let store = ManagedSettingsStore()

    func shieldActivities() {
        // Clear to reset previous settings
        store.clearAllSettings()

        let applications = discouragedSelections.applicationTokens
        let categories = discouragedSelections.categoryTokens

        store.shield.applications = applications.isEmpty ? nil : applications
        store.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories)
        store.shield.webDomainCategories = categories.isEmpty ? nil : .specific(categories)
    }
}

struct ShieldView: View {

    @StateObject private var manager = ShieldManager()
    @State private var showActivityPicker = false

    var body: some View {
        VStack {
            Button {
                showActivityPicker = true
            } label: {
                Label("Configure activities", systemImage: "gearshape")
            }
            .buttonStyle(.borderedProminent)
            Button("Apply Shielding") {
                manager.shieldActivities()
            }
            .buttonStyle(.bordered)
        }
        .familyActivityPicker(isPresented: $showActivityPicker, selection: $manager.discouragedSelections)
    }
}
//------------------------

//extension DeviceActivityName {
//    static let daily = Self("daily") // カスタム名前空間 "daily" を定義
//}
//
//
//class ScreenTimeSelectAppsModel: ObservableObject {
//    @Published var activitySelection = FamilyActivitySelection()
//    @Published var isMonitoring = false
//
//    private var cancellables = Set<AnyCancellable>()
//    private let encoder = PropertyListEncoder()
//    private let decoder = PropertyListDecoder()
//    private let userDefaultsKey = "ScreenTimeSelection"
//
//    init() {
//        // 初期値を読み込む
//        activitySelection = loadSelection() ?? FamilyActivitySelection()
//
//        // activitySelection が変更されたら保存
//        $activitySelection.sink { [weak self] selection in
//            self?.saveSelection(selection: selection)
//        }
//        .store(in: &cancellables)
//    }
//
//    // 選択を保存するメソッド
//    private func saveSelection(selection: FamilyActivitySelection) {
//        let defaults = UserDefaults.standard
//        if let encoded = try? encoder.encode(selection) {
//            defaults.set(encoded, forKey: userDefaultsKey)
//        }
//    }
//
//    // 保存された選択を読み込むメソッド
//    private func loadSelection() -> FamilyActivitySelection? {
//        let defaults = UserDefaults.standard
//        guard let data = defaults.data(forKey: userDefaultsKey),
//              let selection = try? decoder.decode(FamilyActivitySelection.self, from: data) else {
//            return nil
//        }
//        return selection
//    }
//    
//
//    func startMonitoringWithSchedule() {
//        let intervalStart = DateComponents(hour: 19, minute: 5) // 開始時間: 午前9時
//        let intervalEnd = DateComponents(hour: 20, minute: 0)  // 終了時間: 午後5時
//
//        let schedule = DeviceActivitySchedule(intervalStart: intervalStart, intervalEnd: intervalEnd, repeats: true)
//        let center = DeviceActivityCenter()
//
//        do {
//            try center.startMonitoring(.daily, during: schedule)
//            print("Monitoring started with schedule.")
//            isMonitoring = true
//        } catch {
//            print("Failed to start monitoring: \(error.localizedDescription)")
//        }
//    }
//
//    func stopMonitoring() {
//        let center = DeviceActivityCenter()
//        center.stopMonitoring([.daily]) // 配列として渡す
//        print("Monitoring stopped.")
//        isMonitoring = false
//
//        // 制限も解除
//        stopBlocking()
//    }
//
//
//
//    // ブロックを開始するメソッド
//    func startBlocking() {
//        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("ScreenTimeSettings"))
//
//        // アプリ削除をブロック
//        store.application.denyAppRemoval = true
//
//        // 選択されたカテゴリとアプリをシールド
//        store.shield.applicationCategories = .specific(activitySelection.categoryTokens)
//        store.shield.applications = activitySelection.applicationTokens
//
//        print("Blocking started: Categories - \(activitySelection.categoryTokens), Applications - \(activitySelection.applicationTokens)")
//    }
//
//    // ブロックを解除するメソッド
//    func stopBlocking() {
//        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("ScreenTimeSettings"))
//
//        // シールドを解除
//        store.shield.applications = nil
//        store.shield.applicationCategories = nil
//
//        // すべての設定をクリア
//        store.clearAllSettings()
//
//        print("Blocking stopped")
//    }
//}
//
//
//struct ScreenTimeSelectAppsView: View {
//    @ObservedObject var model: ScreenTimeSelectAppsModel
//    @State private var isPresented = false
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Button("スクリーンタイムの認証") {
//                Task {
//                    await authorize()
//                }
//            }
//            .buttonStyle(.borderedProminent)
//
//            Button("ブロックするアプリ") {
//                isPresented = true
//            }
//            .familyActivityPicker(
//                isPresented: $isPresented,
//                selection: $model.activitySelection
//            )
//            .buttonStyle(.borderedProminent)
//            
//            Button("スタート_モニタリング") {
//                            model.startMonitoringWithSchedule()
//                        }
//                        .buttonStyle(.bordered)
//
//                        Button("ストップ_モニタリング") {
//                            model.stopMonitoring()
//                        }
//                        .buttonStyle(.bordered)
//
//            Button("ブロック開始") { // 制限を適用するボタン
//                model.startBlocking()
//            }
//            .buttonStyle(.bordered)
//
//            Button("ブロック終了") { // 制限を適用するボタン
//                model.stopBlocking()
//            }
//            .buttonStyle(.bordered)
//
//                Button("通知の許可をリクエスト") {
//                    LocalNotificationManager.shared.requestAuthorization { granted in
//                        print(granted ? "通知が許可されました" : "通知が拒否されました")
//                    }
//                }
//
//                Button("通知を送信") {
//                    LocalNotificationManager.shared.sendNotification(
//                        title: "外部通知",
//                        body: "これは外部から使用できる通知です。"
//                    )
//                }
//
//            Spacer()
//        }
//        .padding()
//    }
//
//    private func authorize() async {
//        do {
//            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
//            print("Authorization successful")
//        } catch {
//            print("Authorization failed: \(error.localizedDescription)")
//        }
//    }
//}
//
//struct ScreenTimeSelectAppsView_Previews: PreviewProvider {
//    static var previews: some View {
//        let model = ScreenTimeSelectAppsModel()
//        ScreenTimeSelectAppsView(model: model)
//    }
//}
