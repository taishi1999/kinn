import SwiftUI
import ManagedSettings
import Combine

struct ビュー_タスク作成: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var taskType: TaskType
    @Binding var startTime: Date
    @Binding var endTime: Date
    @Binding var repeatDays: [Int]
    @Binding var characterCount: Int
    var pinFocusState: FocusState<Bool>.Binding
    @Binding var isButtonAbled: Bool
    @Binding var isTextFieldVisible: Bool
    //    @Binding var value: Int

    private var days: [String] {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ja_JP") // 日本語ロケール
            formatter.dateFormat = "EEE"
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date()) // 今日の日付の開始時間
            return (0..<7).map { offset in
                guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { return "" }
                return formatter.string(from: date) // 曜日を文字列で取得
            }
        }

    @State private var selectedDays: Set<String> = []

    @State private var selectedApp: String = ""
    @State private var isPresented = false
    @StateObject var contentViewModel = ContentViewModel()
    //    @State private var text: String = "100"
    //    @State private var 指定文字数: Int = 100

    @State private var isPressed = false
    @State private var showTextField = false
    @FocusState private var isTextFieldFocused: Bool
    private let maxLength = 4 // 最大文字数を設定
    //    init(){
    //        print("初期化じゃあ")
    //    }
    //    @State private var taskType: String = "Diary" // 初期化時に最初の要素を選択

    var body: some View {

        VStack(spacing:40) {

            VStack(spacing:0){
                //                パーツ_フィルター(
                //                    overlayComponentView:
                //                        Menu {
                //                            // Option 1
                //                            Button(action: {
                //                                taskType = .diary
                //                            }) {
                //                                HStack {
                //                                    Text(TaskTitle.diary.rawValue)
                //                                    Spacer()
                //                                    if taskType == .diary {
                //                                        Image(systemName: "checkmark")
                //                                    }
                //                                }
                //                                .padding()
                //                                .background(taskType == .diary ? Color.blue.opacity(0.2) : Color.clear) // 選択時の背景色
                //                            }
                //
                //                            // Option 2
                //                            Button(action: {
                //                                taskType = .timer
                //                            }) {
                //                                HStack {
                //                                    Text(TaskTitle.timer.rawValue)
                //                                    Spacer()
                //                                    if taskType == .timer {
                //                                        Image(systemName: "checkmark")
                //                                    }
                //                                }
                //                                .padding()
                //                                .background(taskType == .timer ? Color.blue.opacity(0.2) : Color.clear) // 選択時の背景色
                //                            }
                //                        } label: {
                //                            // ボタンのラベルを動的に変更
                //                            HStack(spacing:4) {
                //                                       GeometryReader { geometry in
                //                                           // taskType に基づいて表示を切り替える
                //                                           if taskType == .diary {
                //                                               Text("✍️")
                //                                                   .font(.system(size: 16))
                //                                                   .frame(width: 32, height: 32)
                //                                                   .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                //                                           } else if taskType == .timer {
                //                                               Text("⏳")
                //                                                   .font(.system(size: 16))
                //                                                   .frame(width: 32, height: 32)
                //                                                   .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                //                                           }
                //                                       }
                ////                                       .background(Color(.systemGray6))
                //                                       .frame(width: 32, height: 32)
                //                                       .cornerRadius(8)
                //
                //                                       // taskType に基づいて表示を切り替える
                //                                if taskType == .diary {
                //                                           Text("日記を書く")
                //                                               .font(.system(size: 18, weight: .regular))
                //                                               .foregroundColor(.primary)
                //                                } else if taskType == .timer {
                //                                           Text("時間")
                //                                               .font(.system(size: 18, weight: .regular))
                //                                               .foregroundColor(.primary)
                //                                       }
                //
                //                                       Spacer()
                //
                //                                       Image(systemName: "chevron.down")
                //                                           .rotationEffect(.degrees(0))
                //                                           .font(.system(size: 16, weight: .medium))
                //                                           .fontWeight(.regular)
                //                                           .foregroundColor(Color(.systemGray2))
                //                                           .frame(width: 20, height: 20)
                //                                   }
                //                            .padding(.horizontal, 16)
                //                            .padding(.vertical, 8)
                //                        },
                //
                ////                        Button{
                ////
                ////                        } label: {
                ////                            HStack {
                ////                                GeometryReader { geometry in
                ////                                    Text("✍️")
                ////                                        .font(.system(size: 16))
                ////                                        .frame(width: 32, height: 32)
                ////                                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                ////
                ////                                }
                ////                                .background(Color(.systemGray6))
                ////                                .frame(width: 32, height: 32)
                ////                                .cornerRadius(8)
                ////
                ////                                Text("日記を書く")
                ////                                    .font(.system(size: 18, weight: .regular))
                ////                                    .foregroundColor(.primary)
                ////
                ////                                Spacer()
                ////
                ////                                Image(systemName: "chevron.down")
                ////                                    .rotationEffect(.degrees(0))
                ////                                    .font(.system(size: 16, weight: .medium))
                ////                                    .fontWeight(.regular)
                ////                                    .foregroundColor(Color(.systemGray2))
                ////                                    .frame(width: 20, height: 20)
                ////                            }
                ////                            .padding(.horizontal, 16)
                ////                            .padding(.vertical, 8)
                ////
                ////                        },
                //                    cornerRadius: 16,
                //                    padding: 0,
                //                    isButtonAbled:$isButtonAbled
                //                )


                if taskType != .timer {
                    //ライン
                    //                    GeometryReader { geometry in
                    //                        let totalWidth = geometry.size.width
                    //                        let lineLength: CGFloat = 8
                    //                        var segmentCount: CGFloat {
                    //                            var closestSegmentCount: CGFloat = 2
                    //                            var smallestDifference: CGFloat = CGFloat.greatestFiniteMagnitude
                    //
                    //                            for count in stride(from: 2, through: Int(totalWidth / 2), by: 2) {
                    //                                let segmentLength = totalWidth / CGFloat(count)
                    //                                let difference = abs(segmentLength - lineLength)
                    //                                if difference < smallestDifference {
                    //                                    smallestDifference = difference
                    //                                    closestSegmentCount = CGFloat(count)
                    //                                }
                    //                            }
                    //
                    //                            return closestSegmentCount
                    //                        }
                    //                        let segmentLength = totalWidth / segmentCount
                    //                        let dashLength = segmentLength / 2
                    //                        let dashPattern = [dashLength] + Array(repeating: segmentLength, count: Int(segmentCount) - 1)
                    //
                    //                        パーツ_ライン()
                    //                            .stroke(style: StrokeStyle(
                    //                                lineWidth: 1,
                    //                                dash: dashPattern
                    //                            ))
                    //                            .foregroundColor(Color(UIColor { traitCollection in
                    //                                return traitCollection.userInterfaceStyle == .dark ? .systemGray4 : .systemGray4
                    //                            }))
                    //
                    //                    }
                    //                    .frame(height: 1)

                    HStack {
                        Text("文字数")
                            .foregroundColor(.primary)

                        Spacer()
                        //                        パーツ_文字数入力欄(value: $指定文字数)

                        ZStack {
                            if !isButtonAbled {
                                TextField("10", text: Binding(
                                    get: { String(characterCount) },
                                    set: { newValue in
                                        // 新しい値をテキストに設定
                                        characterCount = Int(newValue) ?? characterCount
                                    }
                                ))
                                .keyboardType(.numberPad)
                                .font(.system(size: 16, weight: .regular))
                                .padding(.horizontal, 8)
                                .fixedSize()
                                .frame(height: 32)
                                .focused($isTextFieldFocused)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(UIColor { traitCollection in
                                            return traitCollection.userInterfaceStyle == .dark ? .systemGray2 : .systemGray5
                                        }), lineWidth: 1)
                                )
                                .onAppear {
                                    isTextFieldFocused = true  // TextField 表示時に自動的にフォーカス
                                }
                                .onReceive(Just(characterCount), perform: { _ in
                                    let textString = String(characterCount)  // 現在のテキストを文字列で取得
                                    if textString.count > maxLength {
                                        characterCount = Int(textString.prefix(maxLength)) ?? characterCount  // 4桁に切り詰め
                                    }
                                })
                            } else {
                                Button {
                                    isButtonAbled = false
                                    isTextFieldVisible = true
                                } label: {
                                    Text("\(characterCount)")
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 8)
                                        .frame(height: 32)
                                        .cornerRadius(8)
                                        .font(.system(size: 16, weight: .regular))
                                }
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(UIColor { traitCollection in
                                            return traitCollection.userInterfaceStyle == .dark ? .systemGray2 : .systemGray5
                                        }), lineWidth: 1)
                                )
                                .onAppear {
                                    if characterCount < 10 {
                                        characterCount = 10
                                    }
                                }
                            }
                        }

                        Text("文字")
                            .foregroundColor(Color(.gray))
                        //                        Spacer()

                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }

            }
            .background(Color.darkButton_normal)
            //            .background(Color(.systemBackground))
            .cornerRadius(16)
            .padding(.horizontal)


            パーツ_フィルター(
                overlayComponentView:
                    Section {
                        Button {
                            isPresented = true
                            print("showTextField: \(showTextField) isTextFieldFocused: \(isTextFieldFocused)")
                        } label: {
                            HStack {
                                Text("ブロックするアプリ")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(selectedApp.isEmpty ? "選択" : selectedApp)
                                    .foregroundColor(Color(.gray))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 16, weight: .medium))
                                    .fontWeight(.regular)
                                    .foregroundColor(Color(.systemGray2))
                                    .frame(width: 20, height: 20)
                            }
                            .padding()
                        }
                        .familyActivityPicker(
                            isPresented: $isPresented,
                            selection: $contentViewModel.selection
                        )
                    }
                //                        .background(Color.white.opacity(0.05))
                //                        .background(Color(.systemBackground))
                ,
                //                    .cornerRadius(16)
                /*.padding(.horizontal),*/
                cornerRadius: 16,
                padding: 16,
                isButtonAbled:$isButtonAbled
            )
            // 時間セクション


            パーツ_フィルター(
                overlayComponentView:
                    VStack(spacing:0){
                        パーツ_時刻選択(開始時刻: $startTime, 終了時刻: $endTime)
                        パーツ_ライン()
                            .stroke(Color(UIColor { traitCollection in
                                return traitCollection.userInterfaceStyle == .dark ? .systemGray5 : .systemGray5
                            }), lineWidth: 1)
                            .frame(height: 1)
                        パーツ_曜日選択ビュー(繰り返し曜日: $repeatDays)
                    },
                cornerRadius: 16,
                padding: 16,
                isButtonAbled:$isButtonAbled
            )
        }
        .background(Color.clear)
        .onAppear {
            // 5分刻み
            UIDatePicker.appearance().minuteInterval = 5
        }



    } // body

    // Int型の"2"を"02"とか0埋めしてくれる処理
    private func numToString(_ num: Int) -> String {
        return String(format: "%02d", num)
    }
}

struct パーツ_フィルター<Content: View>: View {
    let overlayComponentView: Content
    let cornerRadius: CGFloat
    let padding: CGFloat
    @Binding var isButtonAbled: Bool

    var body: some View {
        overlayComponentView
            .background(Color.darkButton_normal)
            .cornerRadius(cornerRadius)
            .padding(.horizontal, padding)
            .allowsHitTesting(isButtonAbled)
    }
}

struct SelectTimeWheelView: View {
    @State var opacity: Double = 0
    // Binding for the selected date
    @Binding var selectedDate: Date
    @Binding var isOpen: Bool

    var body: some View {
        VStack {
            DatePicker("",
                       selection: $selectedDate,
                       displayedComponents: [.hourAndMinute])
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
        }
        .opacity(self.opacity)
        .onAppear {
            withAnimation(.linear(duration: 0.3)) {
                // NOTE: opacityを変更する画面再描画に対してアニメーションを適用する
                self.opacity = 1.0
            }
        }
    }
}

//extension UIApplication {
//    func endEditing() {
//        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}

struct パーツ_ライン: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

//---------------------
//struct メニュー_タスク作成_Previews: PreviewProvider {
//    @State static var startHour = 10
//    @State static var startMin = 0
//    @State static var endHour = 11
//    @State static var endMin = 0
//    @State static var startTime = Date()
//    @State static var endTime = Date()
//
//    static var previews: some View {
//        メニュー_タスク作成Wrapper()
//    }
//
//    struct メニュー_タスク作成Wrapper: View {
//        @State private var startHour = 10
//        @State private var startMin = 0
//        @State private var endHour = 11
//        @State private var endMin = 0
//
//        @State private var startTime = Date()
//        @State private var endTime = Date()
//        @State private var repeatDays = [1]
//        @FocusState private var pinFocusState: Bool
//        @State private var isButtonAbled = true
//        @State private var isTextFieldVisible = false
//
//
//        var body: some View {
//            ビュー_タスク作成(
//                startTime: $startTime,
//                endTime: $endTime,
//                repeatDays: $repeatDays,
//                pinFocusState: $pinFocusState,
//                isButtonAbled:$isButtonAbled,
//                isTextFieldVisible: $isTextFieldVisible
//            )
//        }
//    }
//}
