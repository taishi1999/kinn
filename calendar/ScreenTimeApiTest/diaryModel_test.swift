import SwiftUI
import FamilyControls


class DiaryTaskManager: ObservableObject {
    static let shared = DiaryTaskManager()
    /// DiaryTask
    @Published var diaryTask: DiaryTask
    @Published var selection = FamilyActivitySelection()
    // UserDefaultsのキー名
    private static let diaryTaskKey = "diary"
    private static let selectionsKey = "selection_1"

    private static func defaultStartTime() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 12
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    private static func defaultEndTime() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 13
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    private init() {
        // UserDefaultsから値を読み取る
        if let loadedTask = DiaryTaskManager.loadDiaryTask(forKey: DiaryTaskManager.diaryTaskKey) {
            diaryTask = loadedTask
        } else {
            // 初期値
            diaryTask = DiaryTask(
                type: "diary",
                selectionID: "selection_1",
//                selection: FamilyActivitySelection(),
                startTime: DiaryTaskManager.defaultStartTime(), // 初期値を12:00
                endTime: DiaryTaskManager.defaultEndTime(),
                weekDays: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
                characterCount: 100
            )
        }

        // UserDefaultsからFamilyActivitySelectionを読み取る
        if let loadedSelection = DiaryTaskManager.loadFamilyActivitySelection(forKey: diaryTask.selectionID) {
            selection = loadedSelection
        } else {
            // 初期値
            selection = FamilyActivitySelection()
        }
    }

    /// DiaryTaskをUserDefaultsに保存
    func saveDiaryTask(_ diaryTask: DiaryTask, selection: FamilyActivitySelection, taskKey: String, selectionKey: String) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // 日付フォーマットを指定
        do {
            let appGroupDefaults = UserDefaults(suiteName: "group.com.karasaki.kinn.date")

            // DiaryTask の保存
            let taskData = try encoder.encode(diaryTask)
            appGroupDefaults?.set(taskData, forKey: taskKey)
            print("DiaryTask を保存しました (キー: \(taskKey))")

            // FamilyActivitySelection の保存
            let selectionData = try encoder.encode(selection)
            appGroupDefaults?.set(selectionData, forKey: selectionKey)
            print("FamilyActivitySelection を保存しました (キー: \(selectionKey))")
        } catch {
            print("保存に失敗しました: \(error)")
        }
    }


    /// UserDefaultsからDiaryTaskを読み込む
    static func loadDiaryTask(forKey key: String) -> DiaryTask? {
        let appGroupDefaults = UserDefaults(suiteName: "group.com.karasaki.kinn.date")
        guard let data = appGroupDefaults?.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // 日付フォーマットを指定
        do {
            return try decoder.decode(DiaryTask.self, from: data)
        } catch {
            print("Failed to load DiaryTask: \(error)")
            return nil
        }
    }

    static func loadFamilyActivitySelection(forKey key: String) -> FamilyActivitySelection? {
        let appGroupDefaults = UserDefaults(suiteName: "group.com.karasaki.kinn.date")
        guard let data = appGroupDefaults?.data(forKey: key) else {
            print("FamilyActivitySelection のデータが見つかりません (キー: \(key))")
            return nil
        }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(FamilyActivitySelection.self, from: data)
        } catch {
            print("FamilyActivitySelection の読み込みに失敗しました: \(error)")
            return nil
        }
    }

    func loadTaskAndSelection() {
            if let loadedTask = DiaryTaskManager.loadDiaryTask(forKey: "diary") {
                self.diaryTask = loadedTask
                print("DiaryTask loaded: \(loadedTask)")

                // selectionID を使って FamilyActivitySelection をロード
                if let loadedSelection = DiaryTaskManager.loadFamilyActivitySelection(forKey: loadedTask.selectionID) {
                    print("FamilyActivitySelection loaded: \(loadedSelection)")
                } else {
                    print("No FamilyActivitySelection found for key: \(loadedTask.selectionID)")
                }
            } else {
                print("No DiaryTask found.")
            }
        
        }

    func deleteDiaryTask(taskKey: String, selectionKey: String) {
        // アプリグループのUserDefaultsを使用
        let appGroupDefaults = UserDefaults(suiteName: "group.com.karasaki.kinn.date")

        // DiaryTask の削除
        appGroupDefaults?.removeObject(forKey: taskKey)
        print("DiaryTask を削除しました (キー: \(taskKey))")
        // FamilyActivitySelection の削除
        appGroupDefaults?.removeObject(forKey: selectionKey)
        print("FamilyActivitySelection を削除しました (キー: \(selectionKey))")
    }

}

struct DiaryTask: Codable {
    var type: String
    var selectionID: String
    var startTime: Date
    var endTime: Date
    var weekDays: [String]
    var characterCount: Int
}
