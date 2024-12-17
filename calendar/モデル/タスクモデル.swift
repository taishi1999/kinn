import SwiftUI
import FamilyControls

struct CustomPicker: View {
    @State var selectedIndex = 0
    var titles = ["きょう", "すべて"]
    @State private var frames = Array<CGRect>(repeating: .zero, count: 4)

    var body: some View {
            ZStack {
                HStack(spacing: 0) {
                    ForEach(self.titles.indices, id: \.self) { index in
                        Button(action: { self.selectedIndex = index }) {
                            Text(self.titles[index])
                                .padding(.vertical,8)
                                .padding(.horizontal)
                                .foregroundColor(.primary)
                                .font(.system(size: 16, weight: .medium, design: .default))
                                .bold()
                                .frame(maxWidth: .infinity) // ボタンを横幅いっぱいに広げる
                            //こいつを無くせばそれぞれの大きさになる
                        }

                        .measure()
                        .onPreferenceChange(FrameKey.self, perform: { value in
                            self.setFrame(index: index, frame: value)
                        })
                    }
                }
                .background(
                    ZStack {
                        Capsule()
                            .fill(.primary.opacity(0.5)) // .primary 色に透明度を追加
                            .frame(width: self.frames[self.selectedIndex].width,
                                   height: self.frames[self.selectedIndex].height, alignment: .topLeading)
                            .offset(x: self.frames[self.selectedIndex].minX - self.frames[0].minX)

                        Capsule()
                            .fill(.ultraThinMaterial) // ultraThinMaterial を重ねる
                            .frame(width: self.frames[self.selectedIndex].width,
                                   height: self.frames[self.selectedIndex].height, alignment: .topLeading)
                            .offset(x: self.frames[self.selectedIndex].minX - self.frames[0].minX)
                    }, alignment: .leading
                )
            }
            .animation(.default)

        .padding(4)
        .background(.primary.opacity(0.05))
        .background(.ultraThinMaterial)
        .cornerRadius(40)
    }

    func setFrame(index: Int, frame: CGRect) {
        print("Setting frame: \(index): \(frame)")
        self.frames[index] = frame
    }
}


struct FrameKey : PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

extension View {
    func measure() -> some View {
        self.background(GeometryReader { geometry in
            Color.clear
                .preference(key: FrameKey.self, value: geometry.frame(in: .global))
        })
    }
}

struct CustomPicker_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // 背景色を全体に設定
            (Color.darkBackground)
                .edgesIgnoringSafeArea(.all) // 画面全体に背景色を適用

            // CustomPicker() を中央に配置
            CustomPicker()
                .padding()

                .frame(maxWidth: .infinity, maxHeight: .infinity) // 画面全体に配置し、中央に寄せる

        }
        .previewLayout(.sizeThatFits)
    }
}

import CoreData



class TaskViewModel: ObservableObject {
    @Published var coredata_MyTask: MyTask
    

    init(context: NSManagedObjectContext) {
        // 既存のタスクがあるか確認
        let fetchRequest: NSFetchRequest<MyTask> = MyTask.fetchRequest()
        fetchRequest.fetchLimit = 1
        if let existingTask = try? context.fetch(fetchRequest).first {
            self.coredata_MyTask = existingTask
        } else {
            
            // 新しいタスクを作成し、初期値を設定
            let newTask = MyTask(context: context)
            newTask.taskType = "diary"
            newTask.startTime = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
            newTask.endTime = newTask.startTime.addingTimeInterval(3600)
            newTask.repeatDays = "0,1,2,3,4,5,6"
            newTask.characterCount = 100
            self.coredata_MyTask = newTask

            // 非同期で保存
            DispatchQueue.main.async {
                do {
                    try context.save()
                    print("Task saved successfully!")
                } catch {
                    print("Failed to save task: \(error.localizedDescription)")
                }
            }
        }
    }

    func updateTask(
        taskType: TaskType,
        startTime: Date,
        endTime: Date,
        repeatDays: [Int],
        characterCount: Int,
        context: NSManagedObjectContext,
        completion: ((Bool) -> Void)? = nil // オプショナルに変更
    ) {
        let calendar = Calendar.current
        var adjustedEndTime = endTime

        // 時間の調整
        let startHour = calendar.component(.hour, from: startTime)
        let startMinute = calendar.component(.minute, from: startTime)
        let endHour = calendar.component(.hour, from: endTime)
        let endMinute = calendar.component(.minute, from: endTime)

        if startHour < endHour || (startHour == endHour && startMinute < endMinute) {
            let startDateComponents = calendar.dateComponents([.year, .month, .day], from: startTime)
            adjustedEndTime = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: calendar.date(from: startDateComponents)!) ?? endTime
        } else {
            // endTime >= startTime の場合
            // endTime を startTime の 1 日後に設定
            let startDatePlusOneDay = calendar.date(byAdding: .day, value: 1, to: startTime) ?? startTime
            adjustedEndTime = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: startDatePlusOneDay) ?? endTime

            // 時間と分が同じ場合、-5 分調整
            if startHour == endHour && startMinute == endMinute {
                adjustedEndTime = calendar.date(byAdding: .minute, value: -5, to: adjustedEndTime) ?? endTime
            }
        }

        // CoreData タスクの更新
        coredata_MyTask.startTime = startTime
        coredata_MyTask.endTime = adjustedEndTime
        coredata_MyTask.repeatDays = repeatDays.sorted().map { String($0) }.joined(separator: ",")
        if taskType == .diary {
            coredata_MyTask.taskType = "Diary"
            coredata_MyTask.characterCount = Int16(characterCount)
        } else if taskType == .timer {
            coredata_MyTask.taskType = "Timer"
        }

        // 保存処理
        DispatchQueue.global(qos: .background).async {
            do {
                try context.save()
                DispatchQueue.main.async {
                    print("Task updated successfully!")
                    self.objectWillChange.send()
                    completion?(true) // completion が存在する場合のみ実行
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to update task: \(error.localizedDescription)")
                    completion?(false) // completion が存在する場合のみ実行
                }
            }
        }
    }


    // Core Dataの全タスクを削除するメソッド
        func deleteAllTasks(context: NSManagedObjectContext) {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MyTask.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(deleteRequest)
                try context.save()
                print("All tasks have been deleted.")

                // キャッシュをリフレッシュ
                context.refreshAllObjects()
            } catch let error as NSError {
                print("Could not delete all tasks. \(error), \(error.userInfo)")
            }
        }
}

class TaskData: ObservableObject {
    @Published var taskType: TaskType = .diary
    @Published var startTime: Date = Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var endTime: Date = Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var repeatDays: [Int] = Array(0...6)
    @Published var characterCount: Int = 100
}


enum TaskType: String {
    case diary = "Diary"
    case timer = "Timer"
}

enum TaskTitle: String, CaseIterable {
    case diary = "✍️ 日記を書く"
    case timer = "⏳ タイマー"
}

class TaskType_Diary {
    var characterCount: Int

    // 初期値として100を設定するイニシャライザ
    init(characterCount: Int = 100) {
        self.characterCount = characterCount
    }

    // 文字数を更新するメソッド
    func updateCharacterCount(_ count: Int) {
        self.characterCount = count
    }
}

class TaskType_Timer {

}


//class TimeSelectionViewModel: ObservableObject {
//    @Published var startTime: Date
//    @Published var endTime: Date
//    @Published var diary: TaskType_Diary
//    @Published var timer: TaskType_Timer
//
//    // taskTypeを管理するプロパティ
//    @Published var taskType: TaskType = .diary
//
//    // 今日の曜日を表す数字の配列（例: 0 は日曜日, 1 は月曜日）
//    @Published var repeatDays: [Int]
//
//    init() {
//        let currentDate = Date()
//        let calendar = Calendar.current
//
//        // Set initialStartTime to 12:00
//        let initialStartTime = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: currentDate)!
//
//        // Set initialEndTime to 13:00 (1 hour after initialStartTime)
//        let initialEndTime = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: currentDate)!
//
//        // Initialize properties
//        self.startTime = initialStartTime
//        self.endTime = initialEndTime
//
//        // Diaryインスタンスを作成 (characterCountはデフォルトで100)
//        self.diary = TaskType_Diary()
//        // Timerインスタンスを作成
//        self.timer = TaskType_Timer()
//
//
//        // 今日の曜日を取得して repeatDays 配列に設定 (0が日曜, 6が土曜)
//        let today = calendar.component(.weekday, from: currentDate) - 1  // 0が日曜
////        self.repeatDays = [today]  // 配列に今日の曜日を追加
//        self.repeatDays = Array(0...6)
//    }
//
//    // TaskTypeを切り替えるメソッド
//
//}

