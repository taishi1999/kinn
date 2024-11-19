import SwiftUI

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

class TimeSelectionViewModel: ObservableObject {
    @Published var startTime: Date
    @Published var endTime: Date
    @Published var diary: TaskType_Diary
    @Published var timer: TaskType_Timer

    // taskTypeを管理するプロパティ
    @Published var taskType: TaskType = .diary

    // 今日の曜日を表す数字の配列（例: 0 は日曜日, 1 は月曜日）
    @Published var repeatDays: [Int]

    init() {
        let currentDate = Date()
        let calendar = Calendar.current

        // Set initialStartTime to 12:00
        let initialStartTime = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: currentDate)!

        // Set initialEndTime to 13:00 (1 hour after initialStartTime)
        let initialEndTime = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: currentDate)!

        // Initialize properties
        self.startTime = initialStartTime
        self.endTime = initialEndTime

        // Diaryインスタンスを作成 (characterCountはデフォルトで100)
        self.diary = TaskType_Diary()
        // Timerインスタンスを作成
        self.timer = TaskType_Timer()


        // 今日の曜日を取得して repeatDays 配列に設定 (0が日曜, 6が土曜)
        let today = calendar.component(.weekday, from: currentDate) - 1  // 0が日曜
//        self.repeatDays = [today]  // 配列に今日の曜日を追加
        self.repeatDays = Array(0...6)
    }

    // TaskTypeを切り替えるメソッド

}

