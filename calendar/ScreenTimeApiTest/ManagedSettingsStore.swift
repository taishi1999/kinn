import SwiftUI
import FamilyControls
import ManagedSettings

class ShieldManager: ObservableObject {
    static let shared = ShieldManager()
    @Published var discouragedSelections = FamilyActivitySelection()
    @Published var startTime = Date()
    @Published var endTime = Date()
    @Published var weekDays: [WeekDays] = []
    // 現在のブロック状態を監視するフラグ
    @Published var isBlocked: Bool = false

    private let store = ManagedSettingsStore()
    private var timer: Timer?


    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()
    private let userDefaultsKey = "ScreenTimeSelection_DAMExtension"
    private let startTimeKey = "startTimeKey"
    private let endTimeKey = "endTimeKey"

    init() {
        let result = savedSelection()
        discouragedSelections = result.selection ?? FamilyActivitySelection()
        startTime = result.startTime ?? Date() // 既存の保存値、または現在時刻
        endTime = result.endTime ?? Date().addingTimeInterval(60 * 60) // 既存の保存値、または1時間後
    }

//    func saveSelectedApplications() {
//        // ApplicationToken の bundleIdentifier を保存
//        let applicationIdentifiers = discouragedSelections.applicationTokens.compactMap { $0.rawValue.bundleIdentifier }
//        appGroupDefaults?.set(applicationIdentifiers, forKey: "selectedApplications")
//        NSLog("Saved Applications: \(applicationIdentifiers)")
//    }

    func startMonitoringBlockedState() {
        // タイマーを作成して1秒ごとにチェック
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.isBlocked = self.isCurrentlyBlocked()
            print("現在のブロック状態: \(self.isBlocked ? "ブロック中" : "ブロックされていない")")
        }
    }

    func stopMonitoringBlockedState() {
           // タイマーを停止
           timer?.invalidate()
           timer = nil
       }

    func saveSelection(selection: FamilyActivitySelection,startTime: Date, endTime: Date) {
//        let defaults = UserDefaults.standard
        let appGroupDefaults = UserDefaults(suiteName: "group.com.karasaki.kinn.date")
//        defaults.set(
        appGroupDefaults?.set(
            try? encoder.encode(selection),
            forKey: userDefaultsKey
        )
        appGroupDefaults?.set(startTime, forKey: startTimeKey)
        appGroupDefaults?.set(endTime, forKey: endTimeKey)
    }

    func loadSelectionFromAppGroup() -> FamilyActivitySelection? {
        let appGroupDefaults = UserDefaults(suiteName: "group.com.karasaki.kinn.date")
        let decoder = PropertyListDecoder()

        guard let data = appGroupDefaults?.data(forKey: "ScreenTimeSelection") else {
            print("No selection found in App Group UserDefaults.")
            return nil
        }

        do {
            let selection = try decoder.decode(FamilyActivitySelection.self, from: data)
            print("Loaded selection from App Group UserDefaults: \(selection)")
            return selection
        } catch {
            print("Failed to load selection: \(error)")
            return nil
        }
    }
    
//    func savedSelection() -> FamilyActivitySelection? {
////        let defaults = UserDefaults.standard
//        //appGroupを使用
//        let userDefaults = UserDefaults(suiteName: "group.com.karasaki.kinn.date")
//
//        guard let data = userDefaults?.data(forKey: userDefaultsKey) else {
//            return nil
//        }
//        return try? decoder.decode(
//            FamilyActivitySelection.self,
//            from: data
//        )
//    }
    func savedSelection() -> (selection: FamilyActivitySelection?, startTime: Date?, endTime: Date?) {
        // appGroup を使用
        let userDefaults = UserDefaults(suiteName: "group.com.karasaki.kinn.date")

        // FamilyActivitySelection を読み込む
        let selection: FamilyActivitySelection? = {
            guard let data = userDefaults?.data(forKey: userDefaultsKey) else {
                return nil
            }
            return try? decoder.decode(FamilyActivitySelection.self, from: data)
        }()

        // startTime と endTime を読み込む
        let startTime = userDefaults?.object(forKey: startTimeKey) as? Date
        let endTime = userDefaults?.object(forKey: endTimeKey) as? Date

        // 結果をタプルで返す
        return (selection, startTime, endTime)
    }


    func shieldActivities(selection: FamilyActivitySelection) {
        // Clear to reset previous settings
        print("print_shieldActivities")
        NSLog("NSLog_shieldActivities")
        store.clearAllSettings()

        let applications = /*discouragedSelections*/selection.applicationTokens
        let categories = /*discouragedSelections*/selection.categoryTokens
        let webDomains = selection.webDomainTokens
//        print("print_Applications: \(applications) ")
//        NSLog("Applications: \(applications)")
//        NSLog("Categories: \(categories)")
//        
        store.shield.applications = applications.isEmpty ? nil : applications
        store.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories)
        store.shield.webDomains = webDomains.isEmpty ? nil : webDomains
        store.shield.webDomainCategories = categories.isEmpty ? nil : .specific(categories)
    }

    func removeAllShields() {
        // すべてのシールドを解除
        store.clearAllSettings()
//        store.shield.applications = nil
//        store.shield.applicationCategories = nil
//        store.shield.webDomains = nil
//        store.shield.webDomainCategories = nil

        NSLog("All shields have been removed.")
    }

    func isCurrentlyBlocked() -> Bool {
        if store.shield.applications != nil{
            print("アプリ存在")
            return true // ブロックされているアプリが存在する
        }

        if store.shield.applicationCategories != nil {
            print("カテゴリー存在")
            return true // nilではない場合、常にtrueを返す
        }

        if store.shield.webDomains != nil{
            print("ドメイン存在")
            return true // ブロックされているWebドメインが存在する
        }


        if store.shield.webDomainCategories != nil{
            print("ドメインカテゴリー存在")
            return true // ブロックされているWebドメインが存在する
        }
        print("ブロックなし")
        return false // ブロックされていない
    }
}

struct ActivityData: Codable {
    let selection: FamilyActivitySelection
    let startTime: Date
    let endTime: Date
}
