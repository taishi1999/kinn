import SwiftUI
import CoreData

struct ページ_タスク作成: View {
//    let days = ["日", "月", "火", "水", "木", "金", "土"]
//    @Binding var initialTask: MyTask
    // 編集用の変数
//    @State private var editableTask: MyTask

    // 親ビューから受け取る@Bindingプロパティを定義
//    @Binding var taskType: TaskType
//    @Binding var startTime: Date
//    @Binding var endTime: Date
//    @Binding var repeatDays: Set<Int>  // Set型で受け取る
//    @Binding var characterCount: Int
//    @Binding var existingTask: MyTask  // 編集対象の既存タスクを親ビューから受け取る
    @State private var taskType: TaskType
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var repeatDays: [Int]
    @State private var characterCount: Int
    @State private var value: Int = 80  // 初期値

    @State private var selectedApp: String = ""
    @State private var selectedPickerIndex: Int? = nil
    @State private var selectedDays: Set<String> = []
    @State private var isStartTimePickerVisible: Bool = false
    @State private var isEndTimePickerVisible: Bool = false
    @State private var textColor: Color = Color.black.opacity(0.3)
    @State private var isShowPopover = false
    @State private var isShowStartTimePopover = false
    @State private var isShowEndTimePopover = false
    @State private var daySpacing: CGFloat = 0
    @State private var isPresented = false
    @State private var isButtonAbled: Bool = true
    @State private var isTextFieldVisible = false
    @State private var isDisabled_保存ボタン = false // ボタンの有効/無効を管理

//    @StateObject private var viewModel = TimeSelectionViewModel()
    @StateObject var contentViewModel = ContentViewModel()

    @FocusState private var pinFocusState: Bool
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var viewModel: TaskViewModel

    var task: MyTask
    
    init(task: MyTask, viewModel: TaskViewModel) {
        print("ページ_タスク.init - Start Time: \(task.startTime), End Time: \(task.endTime)")

        self.task = task
        self.viewModel = viewModel
        // 初期値としてCoreDataの値をコピー
        _taskType = State(initialValue: TaskType(rawValue: task.taskType ?? "diary") ?? .diary)
        _startTime = State(initialValue: task.startTime)
        _endTime = State(initialValue: task.endTime)
        _repeatDays = State(initialValue: task.repeatDays?.split(separator: ",").compactMap { Int($0) } ?? [])
        _characterCount = State(initialValue: Int(task.characterCount))
    }

//    init(taskType: Binding<TaskType>, startTime: Binding<Date>, endTime: Binding<Date>, repeatDays: Binding<Set<Int>>, characterCount: Binding<Int>, existingTask: Binding<MyTask>) {
//        self._taskType = taskType
//        self._startTime = startTime
//        self._endTime = endTime
//        self._repeatDays = repeatDays
//        self._characterCount = characterCount
//        self._existingTask = existingTask  // バインディングとして設定
//
//        // その他の初期化処理
//        _selectedDays = State(initialValue: [getCurrentDayOfWeek()])
//        let bounds = UIScreen.main.bounds
//        let width = bounds.width - 32 //外側のpadding
//        let itemWidth = 40 * CGFloat(days.count)
//        let totalSpacing = width - itemWidth - (2 * 16) // 16 is the padding
//        self._daySpacing = State(initialValue: totalSpacing / CGFloat(days.count - 1))
//    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Text("キャンセル")
                    }
                    Spacer()
                }
                .padding()

                ScrollView(.vertical, showsIndicators: false) {
                    Spacer().frame(height: 24)
                    VStack(spacing: 16) {
                        ビュー_タスク作成(
                            taskType: $taskType,
                            startTime: $startTime,
                            endTime: $endTime,
                            repeatDays: $repeatDays,
                            characterCount: $characterCount,
//                            taskType: Binding(
//                                get: { TaskType(rawValue: existingTask.taskType ?? "diary") ?? .diary },
//                                set: { existingTask.taskType = $0.rawValue }
//                            ),
//                            startTime: Binding(
//                                get: { existingTask.startTime ?? Date() },
//                                set: { existingTask.startTime = $0 }
//                            ),
//                            endTime: Binding(
//                                get: { existingTask.endTime ?? Date().addingTimeInterval(3600) },
//                                set: { existingTask.endTime = $0 }
//                            ),
//                            repeatDays: Binding(
//                                get: { Array(Set(existingTask.repeatDays?.split(separator: ",").compactMap { Int($0) } ?? [])) },
//                                set: { existingTask.repeatDays = Set($0).sorted().map { String($0) }.joined(separator: ",") }
//                            )
//                            ,
//                            characterCount: Binding(
//                                get: { Int(existingTask.characterCount) },
//                                set: { existingTask.characterCount = Int16($0) }
//                            ),
                            pinFocusState: $pinFocusState,
                            isButtonAbled: $isButtonAbled,
                            isTextFieldVisible: $isTextFieldVisible
//                            value: $value
                        )
                        Spacer().frame(height: 100)
                    }
                }
            }

            VStack {
                Spacer()

                Button(action: {
                    isDisabled_保存ボタン = true
                    updateTask(context: viewContext)
                }) {
                    Text("保存")
                        .foregroundColor(isDisabled_保存ボタン ? .secondary : .primary)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(Color.buttonOrange)
                .cornerRadius(24)
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .disabled(isDisabled_保存ボタン)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
        }
        .onReceive(keyboardPublisher) { isVisible in
            print("キーボードが表示されました: \(isVisible ? "はい" : "いいえ")")
        }
        .background(Color.darkBackground)
        .onTapGesture {
            pinFocusState = false
            isButtonAbled = true
            isTextFieldVisible = false
        }
        

    }

//    func getCurrentDayOfWeek() -> String {
//        let today = Date()
//        let calendar = Calendar.current
//        let dayNumber = calendar.component(.weekday, from: today)
//        return days[dayNumber - 1]
//    }

    private func AddTask(context: NSManagedObjectContext) {
        let newTask = MyTask(context: context)
        newTask.startTime = startTime
        newTask.endTime = endTime
        newTask.createdAt = Date()
        newTask.repeatDays = repeatDays.sorted().map { String($0) }.joined(separator: ",")

        if taskType == .diary {
            newTask.taskType = "Diary"
            newTask.characterCount = Int16(characterCount)
        } else if taskType == .timer {
            newTask.taskType = "Timer"
        }

        do {
            try context.save()
            print("New task added successfully!")
            dismiss()
        } catch {
            print("Failed to add task: \(error.localizedDescription)")
        }
    }

    private func updateTask(context: NSManagedObjectContext) {
        print("updateTask startTime:\(startTime) endTime:\(endTime)")
        let calendar = Calendar.current
        // 時間と分を抽出して比較
            let startHour = calendar.component(.hour, from: startTime)
            let startMinute = calendar.component(.minute, from: startTime)
            let endHour = calendar.component(.hour, from: endTime)
            let endMinute = calendar.component(.minute, from: endTime)

        // 時間と分だけを比較
           if startHour < endHour || (startHour == endHour && startMinute < endMinute) {
               // startTime < endTime の場合、日付を同じにする
               let startDateComponents = calendar.dateComponents([.year, .month, .day], from: startTime)
               endTime = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: calendar.date(from: startDateComponents)!) ?? endTime
           } else {
               // endTime >= startTime の場合
               // endTime を startTime の 1 日後に設定
               let startDatePlusOneDay = calendar.date(byAdding: .day, value: 1, to: startTime) ?? startTime
               endTime = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: startDatePlusOneDay) ?? endTime

               // 時間と分が同じ場合、-1 分調整
               if startHour == endHour && startMinute == endMinute {
                   endTime = calendar.date(byAdding: .minute, value: -5, to: endTime) ?? endTime
               }
           }


        task.startTime = startTime
        task.endTime = endTime
        task.repeatDays = repeatDays.sorted().map { String($0) }.joined(separator: ",")

        if taskType == .diary {
            task.taskType = "Diary"
            task.characterCount = Int16(characterCount)
        } else if taskType == .timer {
            task.taskType = "Timer"
        }

        DispatchQueue.global(qos: .background).async {
            do {
                try context.save()
                DispatchQueue.main.async {
                    print("Task updated successfully!")
                    self.viewModel.objectWillChange.send()  // 値変更を通知
//                    self.viewModel.coredata_MyTask = task // 変更を通知するために再代入
                    dismiss()  // 保存完了後にメインスレッドで画面を閉じる
                    isDisabled_保存ボタン=false
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to update task: \(error.localizedDescription)")
                    isDisabled_保存ボタン=false
                }
            }
        }


    }
}

//struct ページ_タスク作成_Previews: PreviewProvider {
//    @State static var taskType: TaskType = .diary  // ダミーのタスクタイプ
//    @State static var startTime: Date = Date()  // ダミーの開始時間
//    @State static var endTime: Date = Date().addingTimeInterval(3600)  // ダミーの終了時間
//    @State static var repeatDays: Set<Int> = [1, 3, 5]  // ダミーの繰り返し曜日
//    @State static var characterCount: Int = 100  // ダミーの文字数
//    @State static var existingTask = MyTask()  // ダミーの既存タスク
//
//    static var previews: some View {
//        ページ_タスク作成(
//            taskType: $taskType,
//            startTime: $startTime,
//            endTime: $endTime,
//            repeatDays: $repeatDays,
//            characterCount: $characterCount,
//            existingTask: $existingTask
//        )
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
