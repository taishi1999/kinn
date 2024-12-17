import SwiftUI
import CoreData

struct ButtonWithMenuView: View {
    @State private var selectedItem: String = "Diary" // 初期化時に最初の要素を選択
    @State private var date = Date()

    var body: some View {
        VStack(){
            DatePicker(
                           "Start Date",
                           selection: $date,
                           displayedComponents: [.hourAndMinute]
                       )

            Menu {
                // Option 1
                Button(action: {
                    selectedItem = "Diary"
                }) {
                    HStack {
                        Text("✍️ 日記を書く")
                        Spacer()
                        if selectedItem == "Diary" {
                            Image(systemName: "checkmark")
                        }
                    }
                    .padding()
                    .background(selectedItem == "Diary" ? Color.blue.opacity(0.2) : Color.clear) // 選択時の背景色
                }

                // Option 2
                Button(action: {
                    selectedItem = "Timer"
                }) {
                    HStack {
                        Text("⏳ 時間")
                        Spacer()
                        if selectedItem == "Timer" {
                            Image(systemName: "checkmark")
                        }
                    }
                    .padding()
                    .background(selectedItem == "Timer" ? Color.blue.opacity(0.2) : Color.clear) // 選択時の背景色
                }
            } label: {
                // ボタンのラベルを動的に変更
                HStack {
                    if selectedItem == "Diary" {
                        Text("✍️ 日記を書く")
                    } else if selectedItem == "Timer" {
                        Text("⏳ 時間")
                    }
                    Spacer() // 横幅を最大にする

                }
                .padding()
                .background(Color.darkButton_normal)
                .foregroundColor(.white)
                .cornerRadius(16)
                .frame(maxWidth: .infinity) // 横幅最大に設定
                .padding(.horizontal)
            }
        }

    }
}

struct ButtonWithMenuView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonWithMenuView()
    }
}

struct テキスト表示ビュー: View {
    var body: some View {
        VStack {
            Text("テキストを表示しています。")
        }
        .padding()
    }
}

struct テキスト表示ビュー_Previews: PreviewProvider {
    static var previews: some View {
        テキスト表示ビュー()
    }
}


//struct 日記エディタta: View {
//    var body: some View {
//        VStack {
//            Text("zzz")
//        }
//        .padding()
//    }
//}
//
//struct 日記エディタta_Previews: PreviewProvider {
//    static var previews: some View {
//        日記エディタta()  // Core Dataコンテキストを渡さずにプレビュー
//    }
//}

struct DropdownButton: View {
    @Binding var buttonPosition: CGPoint
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text("Dropdown Button")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        updateButtonPosition(geometry: geometry)
                    }
                    .onChange(of: geometry.frame(in: .named("scroll"))) { _ in
                        updateButtonPosition(geometry: geometry)
                    }
            }
        )
    }

    private func updateButtonPosition(geometry: GeometryProxy) {
        let globalFrame = geometry.frame(in: .named("scroll"))
        buttonPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: globalFrame.maxY)
    }
}

struct ScrollViewButtonOverlayView: View {
    @State private var buttonPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
    @State private var bObjectViewSize: CGSize = .zero // DropdownMenuのサイズを保存する変数
    @State private var isOverlayVisible: Bool = false // Overlayの表示状態を管理する変数

    var body: some View {
        ZStack {
            ScrollView {
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.frame(in: .named("scroll")).minY) { newValue in
                            if isOverlayVisible {
                                // スクロールしたらDropdownMenuを非表示にする
                                isOverlayVisible = false
                            }
                        }
                }

                VStack(spacing: 20) {
                    ForEach(0..<10, id: \.self) { index in
                        if index == 7 {
                            DropdownButton(buttonPosition: $buttonPosition) {
                                isOverlayVisible.toggle() // DropdownButtonが押された時にトグルする
                            }
                        } else {
                            Button(action: {
                                print("Button \(index) tapped")
                            }) {
                                Text("Button \(index)")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
            }
            .coordinateSpace(name: "scroll")

            // DropdownMenuの上側をbuttonPositionのY座標に揃える
            DropdownMenu(isVisible: $isOverlayVisible)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                bObjectViewSize = geometry.size // DropdownMenuのサイズを取得
                            }
                    }
                )
                .position(x: buttonPosition.x, y: buttonPosition.y + (bObjectViewSize.height / 2 + 16))

            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .position(buttonPosition)
        }
        .background(Color(.systemGray4))
        // タップ領域を追加し、タップされたらisOverlayVisibleをfalseにする
        .contentShape(Rectangle())
        .onTapGesture {
            if isOverlayVisible {
                isOverlayVisible = false
            }
        }
    }
}

struct ScrollViewButtonOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollViewButtonOverlayView()
    }
}


//struct OverlayExampleView: View {
//    @State private var isOverlayVisible = false
//    @State private var buttonFrame: CGRect = .zero
//    @State private var bObjectFrame: CGRect = .zero
//    @State private var selectedButtonIndex: Int? = nil
//
//    var body: some View {
//        ZStack {
//            ScrollView {
//                VStack(spacing: 40) {  // スペースを40に設定
//                    Button(action: {
//
//                        self.isOverlayVisible.toggle()
//
//                    }) {
//                        Text("Show Overlay")
//                            .padding()
//                            .background(Color.green)
//                            .foregroundColor(.white)
//                    }
//                    .background(
//                        GeometryReader { geometry in
//                            Color.clear
//                                .onAppear {
//                                    self.buttonFrame = geometry.frame(in: .global)
//                                }
//                                .onChange(of: geometry.frame(in: .global)) { newValue in
//                                    self.buttonFrame = newValue
//                                }
//                        }
//                    )
//                    //                    .position(x: 100, y: 500)
//                    ForEach(0..<10, id: \.self) { index in
//
//                        // 複数のRectangleを追加
//                        Rectangle()
//                            .fill(Color.blue)
//                            .frame(height: 100)
//                            .cornerRadius(10)
//                            .padding(.horizontal)
//                    }
//
//
//                }
//                .padding()
//            }
//
//            if isOverlayVisible {
//                // 透明なフィルター
//                //                Color.black.opacity(0.001)
//                //                    .edgesIgnoringSafeArea(.all)
//                //                    .onTapGesture {
//                //                        withAnimation(.easeOut(duration: 0.2)) {
//                //                            self.isOverlayVisible = false
//                //                        }
//                //                        self.selectedButtonIndex = nil
//                //
//                //                    }
//
//                // DropdownMenu
//                DropdownMenu()
//                    .background(
//                        GeometryReader { geometry in
//                            Color.clear
//                                .onAppear {
//                                    self.bObjectFrame = geometry.frame(in: .global)
//                                }
//                                .onChange(of: geometry.frame(in: .global)) { newValue in
//                                    self.bObjectFrame = newValue
//                                }
//                        }
//                    )
//                    .position(x: UIScreen.main.bounds.width / 2/*buttonFrame.maxY+0*/)
//                    .offset(y: buttonFrame.maxY/*bObjectFrame.height*/ )
//            }
//        }
//        .background(Color(.systemGray5))
//        //        .edgesIgnoringSafeArea(.all)
//    }
//}

struct DropdownMenu: View {
    @Binding var isVisible: Bool  // 外部からバインディングで渡す
    @State private var selectedDate = Date()
    @State private var animate = false
    @State private var scaleValue: CGFloat = 0.0  // 初期のスケール値
    @State private var selectedItem: String? = "diary"

    var body: some View {
        VStack(spacing: 8) {
            // 日記を書くボタン
            Button(action: {
                selectedItem = "diary"
            }) {
                HStack {
                    Text("✍️ 日記を書く")
                        .foregroundColor(.primary)
                    Spacer()
                    if selectedItem == "diary" {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(selectedItem == "diary" ? Color.white.opacity(0.12) : Color.clear)  // 選択されたときに背景色を変更
                .cornerRadius(12)
            }

            // 時間ボタン
            Button(action: {
                selectedItem = "time"
            }) {
                HStack {
                    Text("⏳ 時間")
                        .foregroundColor(.primary)
                    Spacer()
                    if selectedItem == "time" {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(selectedItem == "time" ? Color.white.opacity(0.12) : Color.clear)  // 選択されたときに背景色を変更
                .cornerRadius(12)
            }
        }
        .padding(8)
        .background(Color.darkBackground)
        .cornerRadius(20)
        .padding(.horizontal, 14)
        .shadow(color: .black.opacity(0.6), radius: 16, x: 0, y: 16)
        .scaleEffect(scaleValue, anchor: .top)
        .opacity(animate ? 1 : 0)
        .onChange(of: isVisible) { visible in
            if visible {
                // 表示されるときのアニメーション
                withAnimation(.easeOut(duration: 0.2)) {
                    scaleValue = 1.04
                    animate = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.linear(duration: 0.15)) {
                        scaleValue = 1.0
                    }
                }
            } else {
                // 非表示になるときのアニメーション
                withAnimation(.linear(duration: 0.15)) {
                    scaleValue = 0.0
                    animate = false
                }
            }
        }
    }
}


//struct OverlayExampleView_Previews: PreviewProvider {
//    static var previews: some View {
//        OverlayExampleView()
//    }
//}

struct TaskListView: View {
    @FetchRequest(
        entity: MyTask.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \MyTask.createdAt, ascending: false)]  // createdAtで降順ソート
    ) var tasks: FetchedResults<MyTask>

    var body: some View {
        List(tasks) { task in
            VStack(alignment: .leading, spacing: 5) {
                Text(task.taskType ?? "Unknown Task")
                    .font(.headline)

                Text("Character Count: \(task.characterCount)")

                // startTimeを安全にアンラップして表示
                Text("Start Time: \(task.startTime.formatted())")

                // endTimeを安全にアンラップして表示
                Text("End Time: \(task.endTime.formatted())")

                Text("Repeat Days: \(task.repeatDays ?? "None")")

                // createdAtも安全にアンラップして表示
                Text("Created At: \(task.createdAt?.formatted() ?? "Unknown")")
            }
            .padding(.vertical, 5)
        }
        .navigationTitle("Saved Tasks")
    }
}



extension Date {
    // Dateのフォーマットを統一するためのメソッド
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}


struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        // プレビュー用にIn-Memory Core Dataコンテキストを使用
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext

        // プレビュー用にダミーデータを作成
        for _ in 0..<5 {
            let newTask = MyTask(context: viewContext)
            newTask.taskType = "Sample Task"
            newTask.isCompleted = false
            newTask.startTime = Date()
            newTask.endTime = Date().addingTimeInterval(3600)  // 1時間後
            newTask.repeatDays = "1,2,3"  // 繰り返し設定
        }

        do {
            try viewContext.save()  // ダミーデータを保存
        } catch {
            print("Failed to save preview data: \(error.localizedDescription)")
        }

        return TaskListView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}

//-----------
import SwiftUI



struct TaskTypePickerView: View {
    @State private var selectedTaskType: TaskTitle = .diary  // デフォルトの選択肢
    @State private var isPresented = false  // メニュー表示のフラグ

    var body: some View {
        VStack {
            Button(action: {
                isPresented = true  // HStack全体をタップでメニューを表示
            }) {
                HStack {
                    Text("Selected Task: \(selectedTaskType.rawValue)")
                        .foregroundColor(.primary)  // テキスト色をprimaryに変更
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(16)
            }
            .confirmationDialog("", isPresented: $isPresented, actions: {
                ForEach(TaskTitle.allCases, id: \.self) { task in
                    Button(task.rawValue) {
                        selectedTaskType = task  // 選択されたタスクタイプを更新
                    }
                }
                Button("キャンセル", role: .cancel) {}
            })
        }
        .padding()
    }
}

struct TaskTypePickerView_Previews: PreviewProvider {
    static var previews: some View {
        TaskTypePickerView()
    }
}

//----
import SwiftUI

// PreferenceKeyの名前を変更
struct ButtonPositionPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ScrollViewWithButtonPositionAndOverlay: View {
    @State private var buttonYPosition: CGFloat = 0.0  // ボタンのY座標を保存

    var body: some View {
        ZStack {
            // ScrollView
            ScrollView {
                VStack(spacing: 0) {
                    // 他の要素（ダミー要素）
                    ForEach(0..<5) { _ in  // 0から5に変更
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 50)
                            .cornerRadius(16)
                    }

                    Button(action: {
                        // ボタンアクション
                    }) {
                        HStack {
                            Text("Tap Me")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(16)
                    }
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(key: ButtonPositionPreferenceKey.self, value: geo.frame(in: .global).minY)
                        }
                    )
                    .onPreferenceChange(ButtonPositionPreferenceKey.self) { value in
                        self.buttonYPosition = value
                    }

                    // 他の要素（ダミー要素）
                    ForEach(0..<5) { _ in  // 0から5に変更
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 50)
                            .cornerRadius(16)
                    }
                }
            }

            // ZStackの上にRectangleを表示し、ボタンの位置に合わせてoffsetで調整
            Rectangle()
                .fill(Color.black.opacity(0.5))
                .frame(height: 300)
                .offset(x: 0, y: buttonYPosition)  // ボタンの位置に合わせてオフセットを調整
        }
        .padding()
    }
}

struct ScrollViewWithButtonPositionAndOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ScrollViewWithButtonPositionAndOverlay()
    }
}
