import SwiftUI
import FamilyControls
import ManagedSettings

class ShieldManager: ObservableObject {
    static let shared = ShieldManager()
//    @Published var diaryTask: DiaryTask?

//    @Published var discouragedSelections = FamilyActivitySelection()
//    @Published var startTime = Date()
//    @Published var endTime = Date()
//    @Published var weekDays: [WeekDays] = []
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
//        let result = savedSelection()
//        discouragedSelections = result.selection ?? FamilyActivitySelection()
//        startTime = result.startTime ?? Date() // 既存の保存値、または現在時刻
//        endTime = result.endTime ?? Date().addingTimeInterval(60 * 60) // 既存の保存値、または1時間後
//        weekDays = result.weekDays ?? []


//        self.diaryTask = loadTask(withKey: "diary", as: DiaryTask.self)
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
    
//    func saveTask<T: Codable>(_ task: T, withKey key: String) {
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601 // 日付のフォーマットを指定
//        if let encodedTask = try? encoder.encode(task) {
//            UserDefaults.standard.set(encodedTask, forKey: key)
//            print("\(key) saved successfully.")
//        } else {
//            print("Failed to encode \(key).")
//        }
//    }
//
//    func loadTask<T: Codable>(withKey key: String, as type: T.Type) -> T? {
//        if let savedData = UserDefaults.standard.data(forKey: key) {
//            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .iso8601 // 日付のフォーマットを指定
//            if let task = try? decoder.decode(type, from: savedData) {
//                print("\(key) loaded successfully.")
//                return task
//            } else {
//                print("Failed to decode \(key).")
//            }
//        } else {
//            print("No task found for key: \(key).")
//        }
//        return nil
//    }
//    
//    func loadInitialData() {
//            // DiaryTaskを非同期で読み込む処理
//            DispatchQueue.global().asyncAfter(deadline: .now() + 2) { // 擬似的な遅延
//                DispatchQueue.main.async {
//                    self.diaryTask = self.loadTask(withKey: "diary", as: DiaryTask.self)
//                }
//            }
//        }


    func saveSelection(selection: FamilyActivitySelection,startTime: Date, endTime: Date, weekDays: [WeekDays]) {
//        let defaults = UserDefaults.standard
        let appGroupDefaults = UserDefaults(suiteName: "group.com.karasaki.kinn.date")
//        defaults.set(
        appGroupDefaults?.set(
            try? encoder.encode(selection),
            forKey: userDefaultsKey
        )
        appGroupDefaults?.set(startTime, forKey: startTimeKey)
        appGroupDefaults?.set(endTime, forKey: endTimeKey)

        let weekDaysRawValues = weekDays.map { $0.rawValue }
        appGroupDefaults?.set(weekDaysRawValues, forKey: "weekDaysKey")
        print("saved")
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
    func savedSelection() -> (selection: FamilyActivitySelection?, startTime: Date?, endTime: Date?, weekDays: [WeekDays]?) {
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
        let weekDays: [WeekDays]? = {
                guard let rawValues = userDefaults?.array(forKey: "weekDaysKey") as? [Int] else {
                    return nil
                }
                return rawValues.compactMap { WeekDays(rawValue: $0) }
            }()
        // 結果をタプルで返す
        return (selection, startTime, endTime, weekDays)
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

enum WeekDays: Int, CaseIterable, Identifiable {
    case sun = 1
    case mon, tue, wed, thu, fri, sat

    var id: Int { rawValue } // Picker 用の Identifiable 準拠

    // 英語の略称を追加
    var shortName: String {
        switch self {
        case .sun: return "Sun"
        case .mon: return "Mon"
        case .tue: return "Tue"
        case .wed: return "Wed"
        case .thu: return "Thu"
        case .fri: return "Fri"
        case .sat: return "Sat"
        }
    }

    var displayName: String {
        switch self {
        case .sun: return "日曜日"
        case .mon: return "月曜日"
        case .tue: return "火曜日"
        case .wed: return "水曜日"
        case .thu: return "木曜日"
        case .fri: return "金曜日"
        case .sat: return "土曜日"
        }
    }
}
