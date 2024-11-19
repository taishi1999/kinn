import SwiftUI
import Combine
import CoreData





struct AnimatedCounterView: View {
    @Binding var startCount: String // 外部からバインディングを受け取る
    @Binding var endCount: String   // 外部からバインディングを受け取る
    @Binding var duration: Double   // 外部からバインディングを受け取る
    @State private var currentCount: Int = 0
    @State private var isAnimating: Bool = false

    var body: some View {
        VStack {
            Text("\(currentCount)") // 現在のカウントを表示
                .font(.largeTitle)
                .padding()

            // Start Countを入力するTextField
            TextField("Start Count", text: $startCount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.numberPad)

            // End Countを入力するTextField
            TextField("End Count", text: $endCount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.numberPad)

            // Durationを入力するTextField
            TextField("Duration", value: $duration, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.decimalPad)

            Button(action: {
                if let start = Int(startCount), let end = Int(endCount), !isAnimating {
                    currentCount = start
                    startCountingAnimation(from: start, to: end)
                }
            }) {
                Text("Start Animation")
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .onAppear {
            if let start = Int(startCount) {
                currentCount = start // 初期化時にカウントを同期
            }
        }
    }

    private func startCountingAnimation(from start: Int, to end: Int) {
        isAnimating = true

        let difference = abs(end - start)
        let stepSize = max(1, difference / 50) // 50は最小ステップ数を想定
        let stepInterval = duration / (Double(difference) / Double(stepSize)) // duration内に完了するように計算

        Timer.scheduledTimer(withTimeInterval: stepInterval, repeats: true) { timer in
            if currentCount != end {
                let stepChange = (start < end) ? stepSize : -stepSize
                currentCount += stepChange

                // 終了時の調整
                if (start < end && currentCount >= end) || (start > end && currentCount <= end) {
                    currentCount = end
                    timer.invalidate()
                    isAnimating = false
                }
            } else {
                timer.invalidate()
                isAnimating = false
            }
        }
    }
}

struct AnimatedCounterView_Previews: PreviewProvider {
    @State static var start = "70" // プレビュー用のState変数
    @State static var end = "100"  // プレビュー用のState変数
    @State static var duration = 1.0 // プレビュー用のState変数

    static var previews: some View {
        AnimatedCounterView(startCount: $start, endCount: $end, duration: $duration) // プレビューでバインディングを渡す
    }
}
extension Color {
    static let secondary_dark = Color(red: 0.92, green: 0.92, blue: 0.96, opacity: 0.6)
}

struct AnimatedClipView: View {
    @State private var animatedCount: Int = 0
    @State private var currentCount: String = "50" // currentCountをString型として保持
    private let count: Int = 100

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    // 背面のHStack
                    HStack(spacing: 8) {
                        Text("\(animatedCount)")
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
//                            .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .bold)))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("/\(count) 文字")
                            .fontWeight(.bold)
                            .foregroundColor(Color.secondary_dark) // secondary_darkの代用
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .cornerRadius(16)

                    // 前面のHStack
                    HStack(spacing: 8) {
                        Text("\(animatedCount)")
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
//                            .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .bold)))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Text("/\(count) 文字")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black, lineWidth: 2) // ボーダーの追加
                    )
                    .cornerRadius(16)
                    .mask(
                        Rectangle()
                            .offset(x: geometry.size.width * CGFloat(animatedCount) / CGFloat(count)) // animatedCountを使用してオフセットを計算
                            .animation(.easeInOut(duration: 0.8), value: animatedCount) // animatedCountの変更時にアニメーション
                    )
                }
            }
            .frame(height: 60) // 適切な高さを指定

            // TextFieldを追加
            TextField("Enter count", text: $currentCount)
                .keyboardType(.numberPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

            Button(action: {
                if let finalValue = Int(currentCount) {
                    // animatedCountを直接変更
                    withAnimation(.easeInOut(duration: 0.8)) {
                        animatedCount = finalValue
                    }
                }
            }) {
                Text("Toggle Clip")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding(32)
    }

    // animateCountUp関数はコメントアウトされたまま
//    private func animateCountUp(to finalValue: Int) {
//        let duration: Double = 0.8 // アニメーションの持続時間
//        let steps: Int = 30 // アニメーションのステップ数
//        let interval: Double = duration / Double(steps)
//        let startValue = animatedCount
//        let increment = Double(finalValue - startValue) / Double(steps)
//
//        for i in 0...steps {
//            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
//                animatedCount = startValue + Int(Double(i) * increment)
//            }
//        }
//    }
}

struct AnimatedClipView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedClipView()
    }
}


extension View {

    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers
            .Merge(
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillShowNotification)
                    .map { _ in true },
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in false })
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

struct KeyboardObserverView: View {

    @State private var isKeyboardVisible: Bool = false

    var body: some View {
        VStack {
            Text("キーボードが表示されている: \(isKeyboardVisible ? "はい" : "いいえ")")

            TextField("テキストを入力", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.numberPad)
                .fixedSize()
        }
        .onReceive(keyboardPublisher) { isVisible in
            isKeyboardVisible = isVisible
            print("キーボードが表示されました: \(isVisible ? "はい" : "いいえ")")
        }
    }
}

struct SheetDisplayView: View {

    @State private var isSheetPresented: Bool = false

    var body: some View {
        VStack {
            Button("シートを表示") {
                isSheetPresented.toggle()
            }
            .sheet(isPresented: $isSheetPresented) {
                KeyboardObserverView()
            }
        }
    }
}

struct SheetDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        SheetDisplayView()
    }
}

struct Sub2View: View {
    var pinFocusState: FocusState<Bool>.Binding
    @Binding var isButtonAbled: Bool
    @Binding var date: Date

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Label")
                Spacer()
                TextField("100", text: .constant(""))
                    .keyboardType(.numberPad)
                    .focused(pinFocusState, equals: true)
                    .padding(8)
                    .fixedSize()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .onTapGesture {
                        print("TextField tapped")
                        pinFocusState.wrappedValue = true
                        isButtonAbled = false
                    }
            }
            .padding()
            .border(Color.gray, width: 1)

            Button(action: {

            }) {
                HStack {
                    Text("aaa")
                    Spacer()
                }
                .padding()
            }
            .allowsHitTesting(isButtonAbled)

            DatePicker(
                "開始",
                selection: $date,
                displayedComponents: [.hourAndMinute]
            )
            .allowsHitTesting(isButtonAbled)
        }
    }
}


//---dropdown型のtimePicker
//                    // （１）開始ボタン
//                    Button {
//                        // アニメーションをつけてニュッと開く
//                        withAnimation {
//                            isOpenStartSet.toggle()
//                            isOpenEndSet = false
//                        }
//                    } label: {
//                        HStack {
//                            Text("開始")
//                                .foregroundColor(.primary)
//                            Spacer()
//                            Text("\(numToString(startHour)):\(numToString(startMin))")
//                                .foregroundColor(isOpenStartSet ? .blue : .secondary)
//                            Image(systemName: "chevron.down")
//                                .font(.system(size: 16, weight: .medium))
//                                .fontWeight(.regular)
//                                .foregroundColor(Color(.systemGray2))
//                                .frame(width: 20, height: 20)
//                        }
//                        .padding()
//                    }
//                    // isOpenStartSetがtrueの時、表示
//                    if isOpenStartSet {
//                        SelectTimeWheelView(
//                            hour: $startHour, minute: $startMin,
//                            isOpen: $isOpenStartSet)
//                        Divider()
//
//                    }
//
//                    // （２）終了ボタン
//                    Button {
//                        // アニメーションをつけてニュッと開く
//                        withAnimation {
//                            isOpenEndSet.toggle()
//                            isOpenStartSet = false
//                        }
//                    } label: {
//                        HStack {
//                            Text("終了")
//                                .foregroundColor(.primary)
//                            Spacer()
//                            Text("\(numToString(endHour)):\(numToString(endMin))")
//                                .foregroundColor(isOpenEndSet ? .blue : .secondary)
//                            Image(systemName: "chevron.down")
//                                .font(.system(size: 16, weight: .medium))
//                                .fontWeight(.regular)
//                                .foregroundColor(Color(.systemGray2))
//                                .frame(width: 20, height: 20)
//                        }
//                        .padding()
//                    }
//                    // isOpenEndSetがtrueの時、表示
//                    if isOpenEndSet {
//                        SelectTimeWheelView(
//                            hour: $endHour, minute: $endMin,
//                            isOpen: $isOpenEndSet)
//                    }
//---dropdown型のtimePicker

//struct PrimaryDisplayView: View {
//    @State private var isOverlayVisible: Bool = true
//
//    var body: some View {
//        VStack(spacing: 20) {
//            FilteredElementView(overlayComponentView: Text("First Element")
//                                    .padding()
//                                    .background(Color.yellow), cornerRadius: 10,
//                                padding: 16, isOverlayVisible: $isOverlayVisible)
//
//
//
//            FilteredElementView(overlayComponentView: 
//                                    HStack{
//                Text("Third Element")
//                    .padding()
//                    .background(Color.green)
//                Spacer()
//            }, cornerRadius: 10,
//                                padding: 16,isOverlayVisible: $isOverlayVisible)
//        }
////        .padding()
//        .background(Color.gray.opacity(0.2))
//    }
//}

// カスタムビューを作成して要素とフィルターを重ねる
//struct FilteredElementView<Content: View>: View {
//    let overlayComponentView: Content
//    let cornerRadius: CGFloat
//
//    var body: some View {
//        overlayComponentView
//            .cornerRadius(cornerRadius)
//            .overlay(
//                Color.black.opacity(0.4)
//                    .cornerRadius(cornerRadius)
//            )
//            .frame(maxWidth: .infinity)
//    }
//}

//struct PrimaryDisplayView_Previews: PreviewProvider {
//    static var previews: some View {
//        PrimaryDisplayView()
//    }
//}


//struct BookDetailView: View {
//    @State var bottomSheetPosition: BottomSheetPosition = .absolute(425)
//
//    let backgroundColors: [Color] = [Color(red: 0.2, green: 0.85, blue: 0.7), Color(red: 0.13, green: 0.55, blue: 0.45)]
//    let readMoreColors: [Color] = [Color(red: 0.70, green: 0.22, blue: 0.22), Color(red: 1, green: 0.32, blue: 0.32)]
//    let bookmarkColors: [Color] = [Color(red: 0.28, green: 0.28, blue: 0.53), Color(red: 0.44, green: 0.44, blue: 0.83)]
//
//    var body: some View {
//        //A green gradient as a background that ignores the safe area.
//        LinearGradient(gradient: Gradient(colors: self.backgroundColors), startPoint: .topLeading, endPoint: .bottomTrailing)
//            .edgesIgnoringSafeArea(.all)
//
//            .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, switchablePositions: [
//                //.dynamicBottom, ここでheaderを表示
//                .absolute(425)
//            ]
////                         ,headerContent: {
////                //The name of the book as the heading and the author as the subtitle with a divider.
////                VStack(alignment: .leading) {
////                    Text("Wuthering Heights")
////                        .font(.title).bold()
////
////                    Text("by Emily Brontë")
////                        .font(.subheadline).foregroundColor(.secondary)
////
////                    Divider()
////                        .padding(.trailing, -30)
////                }
////                .padding([.top, .leading])
////            }
//            ) {
//                //A short introduction to the book, with a "Read More" button and a "Bookmark" button.
//                VStack(spacing: 0) {
//                    Text("This tumultuous tale of life in a bleak farmhouse on the Yorkshire moors is a popular set text for GCSE and A-level English study, but away from the demands of the classroom it’s easier to enjoy its drama and intensity. Populated largely by characters whose inability to control their own emotions...")
//                        .fixedSize(horizontal: false, vertical: true)
//
//                    HStack {
//                        Button(action: {}, label: {
//                            Text("Read More")
//                                .padding(.horizontal)
//                        })
//                            .buttonStyle(BookButton(colors: self.readMoreColors)).clipShape(Capsule())
//
//                        Spacer()
//
//                        Button(action: {}, label: {
//                            Image(systemName: "bookmark")
//                        })
//                            .buttonStyle(BookButton(colors: self.bookmarkColors)).clipShape(Circle())
//                    }
//                    .padding(.top)
//
//                    Spacer(minLength: 0)
//                }
//                .padding([.horizontal, .top])
//            }
//            .enableContentDrag()
//            .showCloseButton(false)
//            .enableSwipeToDismiss()
//            .enableTapToDismiss()
//            .enableFlickThrough()
//            .customThreshold(0.1)
//    }
//}
//
////The gradient ButtonStyle.
//struct BookButton: ButtonStyle {
//
//    let colors: [Color]
//
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.headline)
//            .foregroundColor(.white)
//            .padding()
//            .background(LinearGradient(gradient: Gradient(colors: self.colors), startPoint: .topLeading, endPoint: .bottomTrailing))
//
//    }
//}
//
//struct BookDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        BookDetailView()
//    }
//}


struct OverlayInputView: View {
    @State private var isShowingCustomSheet = false

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            ZStack {
                Button {
                    self.isShowingCustomSheet.toggle()
                } label: {
                    Text("シートを表示する")
                }
                CustomSheet(isShowing: $isShowingCustomSheet, height: height) // heightを直接渡す
            }
        }
    }
}

struct CustomSheet: View {
    @Binding var isShowing: Bool
    var height: CGFloat // バインディングではなく、直接値を受け取る

    var body: some View {
        VStack {
            Spacer()
            if isShowing {
                VStack {
                    Text("Custom Sheet Content")
                        .padding()
                    Button("閉じる") {
                        isShowing = false
                    }
                    .padding()
                }
                .frame(width: UIScreen.main.bounds.width, height: height * 0.5) // 高さの一部を使用
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .transition(.move(edge: .bottom))
                .animation(.spring())
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}


private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

// 最初のモーダルの内容
struct FirstModalView: View {
    @Binding var isPresented: Bool
    @State private var nestedText: String = ""
    @State private var isNestedModalPresented = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            // モーダル内のNumberPadを持つTextField
            TextField("Enter nested number", text: $nestedText)
                .keyboardType(.numberPad)
                .padding()
                .background(Color(.tertiarySystemFill))
                .cornerRadius(8)
                .font(.system(size: 16))
                .frame(maxWidth: .infinity, maxHeight: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .focused($isTextFieldFocused)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button {
                            isTextFieldFocused = false
                        } label: {
                            Text("完了")
                        }
                    }
                }

            // さらにモーダルを表示するボタン
            Button(action: {
                isNestedModalPresented.toggle()
            }) {
                Text("Show Nested Modal")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .fullScreenCover(isPresented: $isNestedModalPresented) {
                NestedModalView(isPresented: $isNestedModalPresented)
            }

            Spacer()

            // モーダルを閉じるボタン
            Button("Close") {
                isPresented = false
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

// さらにネストされたモーダルの内容
struct NestedModalView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text("This is the nested modal content")
                .font(.largeTitle)
                .padding()

            Spacer()

            Button("Close") {
                isPresented = false
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

struct OverlayInputView_Previews: PreviewProvider {
    static var previews: some View {
        OverlayInputView()
    }
}




struct DynamicHeaderView: View {
    @State private var headerHeight: CGFloat = 0

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 16) { // 間隔を設定
                            // UpcomingとSpacerを並べたHStack
                            HStack {
                                Text("Upcoming")
                                    .font(.headline)
                                Spacer()
                            }


                            // 日記を書くとSpacerを並べた背景色付きの角丸HStack
                            HStack {
                                Text("日記を書く")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                .padding(.horizontal)
                .padding(.top, headerHeight + 32) // ヘッダーの高さ分だけ余白を設定
            }

            headerView
                .background(GeometryReader { geometry in
                    Color.clear
                        .preference(key: HeaderHeightKey.self, value: geometry.size.height)
                })
                .onPreferenceChange(HeaderHeightKey.self) { value in
                    headerHeight = value
                }
        }
//        .edgesIgnoringSafeArea(.top)
    }

    private var headerView: some View {
        VStack {
            Text("固定ヘッダー")
//                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding()
            Divider()
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }
}

struct HeaderHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct DynamicHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicHeaderView()
    }
}

struct SampleView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("About")
                    Text("Software Update")
                }
                Section {
                    Text("AirDrop")
                    Text("AirPlay & Handoff")
                    Text("Picture in Picture")
                    Text("CarPlay")
                }
                Section {
                    Text("iPhone Storage")
                    Text("Background App Refresh")
                }
                Section {
                    Text("Date & Time")
                    Text("Keyboard")
                    Text("Fonts")
                    Text("Language & Region")
                }
            }
            .navigationTitle("あ")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Circle()
                .fill(Color.blue)
                .frame(width: 32, height: 32)
            )
        }
    }
}
struct SampleView_Previews: PreviewProvider {
    static var previews: some View {
        SampleView()
    }
}



struct TimePicker2View: View {
    @State private var date = Date()

    var body: some View {
        VStack {
            DatePicker(
                    "開始",
                     selection: $date,
                    displayedComponents: [/*.date,*/.hourAndMinute]
                )
        }
    }
}


struct TimePicker2View_Previews: PreviewProvider {
    static var previews: some View {
        TimePicker2View()
    }
}

struct PrimaryView: View {
    @State private var showSheet = false
    var totalWidth: CGFloat = 250
        var lineLength: CGFloat = 6

        var segmentCount: CGFloat {
            var closestSegmentCount: CGFloat = 2
            var smallestDifference: CGFloat = CGFloat.greatestFiniteMagnitude

            for count in stride(from: 2, through: Int(totalWidth / 2), by: 2) {
                let segmentLength = totalWidth / CGFloat(count)
                let difference = abs(segmentLength - lineLength)
                if difference < smallestDifference {
                    smallestDifference = difference
                    closestSegmentCount = CGFloat(count)
                }
            }

            return closestSegmentCount
        }

        var segmentLength: CGFloat {
            totalWidth / segmentCount
        }

        var dashLength: CGFloat {
            segmentLength / 2
        }

        var dashPattern: [CGFloat] {
            [dashLength] + Array(repeating: segmentLength, count: Int(segmentCount) - 1)
        }
//    var totalWidth: CGFloat = 50
//    var segmentCount: CGFloat = 8
//
//    var segmentLength: CGFloat {
//        totalWidth / segmentCount
//    }
//
//    var dashLength: CGFloat {
//        segmentLength / 2
//    }
//
//    var dashPattern: [CGFloat] {
//        [dashLength] + Array(repeating: segmentLength, count: Int(segmentCount) - 1)
//    }

    var body: some View {
         VStack(spacing: 0) {
                    HStack {
                        Spacer()
                    }
                    .padding()


                    GeometryReader { geometry in
                        let totalWidth = geometry.size.width
                        let lineLength: CGFloat = 12
                        var segmentCount: CGFloat {
                                var closestSegmentCount: CGFloat = 2
                                var smallestDifference: CGFloat = CGFloat.greatestFiniteMagnitude

                                for count in stride(from: 2, through: Int(totalWidth / 2), by: 2) {
                                    let segmentLength = totalWidth / CGFloat(count)
                                    let difference = abs(segmentLength - lineLength)
                                    if difference < smallestDifference {
                                        smallestDifference = difference
                                        closestSegmentCount = CGFloat(count)
                                    }
                                }

                                return closestSegmentCount
                            }
                        let segmentLength = totalWidth / segmentCount
                        let dashLength = segmentLength / 2
                        let dashPattern = [dashLength] + Array(repeating: segmentLength, count: Int(segmentCount) - 1)

                        パーツ_ライン()
                            .stroke(style: StrokeStyle(
                                lineWidth: 1,
                                dash: dashPattern
                            ))
                            .foregroundColor(.blue)
                    }
                    .frame(height: 1)

                    HStack {
                        Spacer()
                    }
                    .padding()
                }
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding()


//        .sheet(isPresented: $showSheet) {
//            SubView()
////            SettingsSheetView()
//        }
    }
}



struct SettingsSheetView: View {
    @State private var text: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack {


            TextField("Placeholder", text: $text)
                .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    HStack {
                                        Spacer()
                                        Button("閉じる") {
                                            UIApplication.shared.endEditing2()
                                        }
                                        Spacer().frame(width: 16)
                                    }
                                }
                            }
        }
        .padding()
    }
}

extension UIApplication {
    func endEditing2() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct SubView: View {
    @State var text = ""

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationView {
            VStack{


                TextField("", text: $text)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .padding(20)
                    .focused($isTextFieldFocused) // フォーカスの管理
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button {
                                print("完了")
                                isTextFieldFocused = false // フォーカスを解除
                            } label: {
                                Text("完了")
                            }
                        }
                    }
            }

        }

    }
}


// プレビュー用のコード
struct PrimaryView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryView()
    }
}

struct TextEditorView: View {
    @State private var upperText: String = "100"


    var body: some View {
        VStack {
            TextField("0", text: $upperText/*,axis: .vertical*/)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .fixedSize()
                .lineLimit(nil)
                .frame( maxWidth: 200) // 必要に応じて高さを調整
                .onChange(of: upperText) { newValue in

                }


        }
//        .padding()
    }
}

struct TextEditorView_Previews: PreviewProvider {
    static var previews: some View {
        TextEditorView()
    }
}

struct CustomTextField: View {
    @State private var text: String = "あああ"
       @FocusState private var isFocused: Bool
       let maxWidth: CGFloat

       var body: some View {
               TextField("description", text: $text,axis: .vertical)

                   .lineLimit(1...10) // 無制限の行数を許可
//                   .fixedSize(horizontal: true, vertical: true)
                   .padding(4)
                   .background(Color.gray.opacity(0.2))
                   .cornerRadius(10)
                   .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                   .frame(maxWidth: maxWidth)
                   .focused($isFocused) // フォーカス状態をバインド
                   .onAppear {
                       isFocused = true // 表示時にフォーカスを設定
                   }

       }
}

struct NoteInputView: View {
    var body: some View {
        CustomTextField(maxWidth: 200)
    }
}

struct NoteInputView_Previews: PreviewProvider {
    static var previews: some View {
        NoteInputView()
    }
}

struct SameStyledTextAndFieldView: View {
    @State private var textFieldText = ""

    var body: some View {
        HStack {
            TextField("Enter text", text: $textFieldText)
                .padding(.vertical, 5)
                .padding(.horizontal, 12)
                .background(Color(.systemGroupedBackground))
                .cornerRadius(15)
                .fixedSize()
                .onChange(of: textFieldText) { newValue in
                    checkTextWidth()
                }

//            Text("Sample Text")
//                .padding(.vertical, 5)
//                .padding(.horizontal, 12)
//                .background(Color(.systemGroupedBackground))
//                .cornerRadius(15)
        }
        .padding()
    }

    private func checkTextWidth() {
        let screenWidth = UIScreen.main.bounds.width
        let maxWidth = screenWidth - 40 // Adjust according to padding
        let textWidth = calculateTextWidth(for: textFieldText)

        print("TextField width: \(textWidth)")

        if textWidth > maxWidth {
            print("Text exceeds screen width")
        }
    }

    private func calculateTextWidth(for text: String) -> CGFloat {
        let label = UILabel()
        label.text = text
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.sizeToFit()
        return label.frame.width
    }
}

struct SameStyledTextAndFieldView_Previews: PreviewProvider {
    static var previews: some View {
        SameStyledTextAndFieldView()
    }
}

struct WrappedTextView: View {
    let text: String
    let maxWidth: CGFloat
    let fontSize: CGFloat

    var body: some View {
        let lines = splitTextIntoLines(for: text, maxWidth: maxWidth)
        return VStack(alignment: .leading) {
            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.system(size: fontSize, weight: .medium))
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func textWidth(for text: String, maxWidth: CGFloat, font: UIFont) -> CGFloat {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        label.font = font
        let maxSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let textWidth = label.sizeThatFits(maxSize).width
        return textWidth
    }

    private func splitTextIntoLines(for text: String, maxWidth: CGFloat) -> [String] {
        let font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        var lines: [String] = []
        var currentIndex = text.startIndex

        while currentIndex < text.endIndex {
            let nextIndex = indexWhereLineBreakShouldOccur(for: text, from: currentIndex, maxWidth: maxWidth, font: font)
            lines.append(String(text[currentIndex..<nextIndex]))
            currentIndex = nextIndex
        }

        return lines
    }

    private func indexWhereLineBreakShouldOccur(for text: String, from startIndex: String.Index, maxWidth: CGFloat, font: UIFont) -> String.Index {
        var index = startIndex
        var width: CGFloat = 0

        while index < text.endIndex && width < maxWidth {
            let nextIndex = text.index(after: index)
            let substring = String(text[startIndex..<nextIndex])
            width = textWidth(for: substring, maxWidth: maxWidth, font: font)
            if width > maxWidth {
                return index
            }
            index = nextIndex
        }

        return text.endIndex
    }
}

struct FlowLayout: Layout {
    var alignment: Alignment = .center
    var spacing: (horizontal: CGFloat, vertical: CGFloat)

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            alignment: alignment,
            spacing: spacing
        )
        return result.bounds
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            alignment: alignment,
            spacing: spacing
        )
        for row in result.rows {
            let rowXOffset = (bounds.width - row.frame.width) * alignment.horizontal.percent
            for index in row.range {
                let xPos = rowXOffset + row.frame.minX + row.xOffsets[index - row.range.lowerBound] + bounds.minX
                let rowYAlignment = (row.frame.height - subviews[index].sizeThatFits(.unspecified).height) * alignment.vertical.percent
                let yPos = row.frame.minY + rowYAlignment + bounds.minY
                subviews[index].place(at: CGPoint(x: xPos, y: yPos), anchor: .topLeading, proposal: .unspecified)
            }
        }
    }

    struct FlowResult {
        var bounds = CGSize.zero
        var rows = [Row]()

        struct Row {
            var range: Range<Int>
            var xOffsets: [Double]
            var frame: CGRect
        }

        init(in maxPossibleWidth: Double, subviews: Subviews, alignment: Alignment, spacing: (horizontal: CGFloat, vertical: CGFloat)) {
            var itemsInRow = 0
            var remainingWidth = maxPossibleWidth.isFinite ? maxPossibleWidth : .greatestFiniteMagnitude
            var rowMinY = 0.0
            var rowHeight = 0.0
            var xOffsets: [Double] = []
            for (index, subview) in zip(subviews.indices, subviews) {
                let idealSize = subview.sizeThatFits(.unspecified)
                if index != 0 && widthInRow(index: index, idealWidth: idealSize.width) > remainingWidth {
                    finalizeRow(index: max(index - 1, 0), idealSize: idealSize)
                }
                addToRow(index: index, idealSize: idealSize)

                if index == subviews.count - 1 {
                    finalizeRow(index: index, idealSize: idealSize)
                }
            }

            func spacingBefore(index: Int) -> Double {
                guard itemsInRow > 0 else { return 0 }
                return spacing.horizontal
            }

            func widthInRow(index: Int, idealWidth: Double) -> Double {
                idealWidth + spacingBefore(index: index)
            }

            func addToRow(index: Int, idealSize: CGSize) {
                let width = widthInRow(index: index, idealWidth: idealSize.width)

                xOffsets.append(maxPossibleWidth - remainingWidth + spacingBefore(index: index))
                remainingWidth -= width
                rowHeight = max(rowHeight, idealSize.height)
                itemsInRow += 1
            }

            func finalizeRow(index: Int, idealSize: CGSize) {
                let rowWidth = maxPossibleWidth - remainingWidth
                rows.append(
                    Row(
                        range: index - max(itemsInRow - 1, 0) ..< index + 1,
                        xOffsets: xOffsets,
                        frame: CGRect(x: 0, y: rowMinY, width: rowWidth, height: rowHeight)
                    )
                )
                bounds.width = max(bounds.width, rowWidth)
                bounds.height += rowHeight + (rows.count > 1 ? spacing.vertical : 0)
                rowMinY += rowHeight + spacing.vertical
                itemsInRow = 0
                rowHeight = 0
                xOffsets.removeAll()
                remainingWidth = maxPossibleWidth
            }
        }
    }
}

private extension HorizontalAlignment {
    var percent: Double {
        switch self {
        case .leading: return 0
        case .trailing: return 1
        default: return 0.5
        }
    }
}

private extension VerticalAlignment {
    var percent: Double {
        switch self {
        case .top: return 0
        case .bottom: return 1
        default: return 0.5
        }
    }
}

struct DynamicTextField: View {
    @Binding var text: String
    let maxWidth: CGFloat

    var body: some View {
        let lines = splitTextIntoLines(for: text, maxWidth: maxWidth)
        return VStack(alignment: .leading) {
            ForEach(lines, id: \.self) { line in
                Text(line)
            }
        }
//        .background(
//            TextField("", text: $text)
//                .opacity(0) // Make the actual TextField invisible
//        )
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, 5)
        .padding(.horizontal, 12)
        .background(Color(.systemGray5))
        .cornerRadius(15)
    }

    private func textWidth(for text: String, maxWidth: CGFloat) -> CGFloat {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.preferredFont(forTextStyle: .body)
        let maxSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let textWidth = label.sizeThatFits(maxSize).width
        return textWidth
    }

    private func splitTextIntoLines(for text: String, maxWidth: CGFloat) -> [String] {
        var lines: [String] = []
        var currentIndex = text.startIndex

        while currentIndex < text.endIndex {
            let nextIndex = indexWhereLineBreakShouldOccur(for: text, from: currentIndex, maxWidth: maxWidth)
            lines.append(String(text[currentIndex..<nextIndex]))
            currentIndex = nextIndex
        }

        return lines
    }

    private func indexWhereLineBreakShouldOccur(for text: String, from startIndex: String.Index, maxWidth: CGFloat) -> String.Index {
        var index = startIndex
        var width: CGFloat = 0

        while index < text.endIndex && width < maxWidth {
            let nextIndex = text.index(after: index)
            let substring = String(text[startIndex..<nextIndex])
            width = textWidth(for: substring, maxWidth: maxWidth)
            if width > maxWidth {
                return index
            }
            index = nextIndex
        }

        return text.endIndex
    }
}

struct TagView: View {
    @State private var textFieldText = ""
    @State private var text = "100"

    private let tags = ["文字以上書く"/*, "明朝体明朝体", "WWDC", "Python", "JavaScript", "PHP", "Ruby", "Flutter", "Dart", "Android", "iPhone"*/]

    var body: some View {
        HStack{
            GeometryReader { geometry in
                FlowLayout(alignment: .leading, spacing: (horizontal: 4, vertical: 6)) {
                    WrappedTextView(text: "日記を", maxWidth: geometry.size.width - 16 - 40, fontSize: 18)
                        .frame(maxWidth: .infinity) // 横幅を最大に設定

                    TextField("0", text: $text)
                        .keyboardType(.numberPad)
                        .font(.system(size: 18, weight: .medium))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity) // 横幅を最大に設定
                        .onChange(of: text) { newValue in
                            if newValue.count > 5 {
                                text = String(newValue.prefix(5))
                            }
                        }
                        .onSubmit {
                            // 任意のアクション
                        }

                    ForEach(tags, id: \.self) { tag in
                        WrappedTextView(text: tag, maxWidth: geometry.size.width - 16 - 40, fontSize: 18)
                            .frame(maxWidth: .infinity) // 横幅を最大に設定
                    }
                }
                .padding(20)
                .background(Color(.systemGray6))
                .frame(height: geometry.size.height / 2) // 高さを制限
            }
            .frame(height: 100) // GeometryReaderの高さを制限
            Text("aaa")
                .padding()

        }
        .background(Color(.systemGray5))

    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView()
    }
}


//struct WrapingHStackView: View {
//    let textArray = ["テキスト１", "テキスト２", "テキスト３", "テキスト４", "テキスト５"]
//
//    var body: some View {
//        WrappingHStack(textArray, id: \.self) { text in
//            Text(text)
//                .padding(5)
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(5)
//        }
//        .padding()
//    }
//}
//
//struct WrapingHStackView_Previews: PreviewProvider {
//    static var previews: some View {
//        WrapingHStackView()
//    }
//}

struct TestWrappedLayout: View {
    @State var platforms = ["日記を", "100", "文字以上書く", "PlayStation2PlayStation2PlayStation2PlayStation2PlayStation2", ]
//    "PlayStation 3", "PlayStation 4"

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        print("スマホの横幅: \(g.size.width)")

        return ZStack(alignment: .topLeading) {
            ForEach(self.platforms, id: \.self) { platform in
                self.item(for: platform)
                    .padding(/*.horizontal,*/ 0)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            print("\(platform) が幅を超えたので次の行へ (width: \(width), d.width: \(d.width), d.height:\(d.height)")
                            //はみ出て、次の行に移動する。次の行は何も表示されてないので0にリセット。heightは追加
                            width = 0
                            height -= (d.height/2+4)
//                            height -= d.height
                        }
                        let result = width
                        if platform == self.platforms.last! {
                            print("\(platform) は最後のアイテムなのでwidthをリセット")
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if platform == self.platforms.last! {
                            print("\(platform) は最後のアイテムなのでheightをリセット")
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
        .background(Color(.systemGray5))
    }

    func item(for text: String) -> some View {
        Text(text)
            .padding(4)
            .font(.body)
            .background(Color.blue)
            .foregroundColor(Color.white)
            .cornerRadius(4)
    }
}

struct TestWrappedLayout_Previews: PreviewProvider {
    static var previews: some View {
        TestWrappedLayout()
    }
}

// UIViewRepresentableを使用してUILabelをラップ
struct UILabelRepresentable: UIViewRepresentable {
    var text: String
    var textColor: UIColor
    var backgroundColor: UIColor

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0 // 自動的に折り返すように設定
        label.textAlignment = .left
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = text
        uiView.textColor = textColor
        uiView.backgroundColor = backgroundColor
    }
}

import UIKit

struct InteractiveTextView: UIViewRepresentable {
    var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.attributedText = makeAttributedStringText(text: text)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = makeAttributedStringText(text: text)
    }

    func makeCoordinator() -> Coordinator {

        Coordinator()
    }

    class Coordinator: NSObject, UITextViewDelegate {
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

            if URL.absoluteString == "highlighted" {
                print("Tapped on highlighted text")
                return false
            }
            return true
        }
    }

    func makeAttributedStringText(text: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: text)
        let highlightedText = "重要重要重要重要"
        let range = (text as NSString).range(of: highlightedText)

        if range.location != NSNotFound {
            attributed.addAttribute(.foregroundColor, value: UIColor.white, range: range)
            attributed.addAttribute(.backgroundColor, value: UIColor.red, range: range)
            attributed.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .headline), range: range)
            attributed.addAttribute(.link, value: "highlighted", range: range)
        }

        return attributed
    }
}

struct CustomView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            makeAttributedStringText(text: " 明日は面談あり明日は面談あり明日は面談あり重要重要重要重要明日は面談あり明日は面談あり明日は面談あり")
        }
    }

    func makeAttributedStringText(text: String) -> some View {
        let attributed = AttributedString(text)
        let parts = text.split(separator: " ")

        var views: [AnyView] = []

        for part in parts {
            let partStr = String(part)
            if partStr.contains("重要重要重要重要") {
                let tappableText = Text(partStr)
                    .foregroundColor(.white)
                    .background(Color.red)
                    .font(.headline)
                    .onTapGesture {
                        print("\(partStr) tapped!")
                    }
                views.append(AnyView(tappableText))
            } else {
                let normalText = Text(partStr)
                views.append(AnyView(normalText))
            }
        }

        return HStack {
            ForEach(0..<views.count, id: \.self) { index in
                views[index]
            }
        }
    }
}

struct CustomView_Previews: PreviewProvider {
    static var previews: some View {
        CustomView()
    }
}

struct AttributedTextView: View {
    var attributedString: AttributedString

        init() {
            //either like this:
            attributedString = AttributedString("Hello, #swift")
            let range = attributedString.range(of: "#swift")!
            attributedString[range].link = URL(string: "https://www.hackingwithswift.com")!

            //or like this:
            attributedString = try! AttributedString(markdown: "こんにちわこんにちわこんにちわこんにちわこんにちわこんにちわ, [#swiftswiftswiftswiftswiftswiftswiftswiftswiftaaa](https://www.hackingwithswift.com)")
        }

        var body: some View {
//            Text(attributedString)
//                .padding()
            Text("Some text [clickable subtext](https://www.hackingwithswift.com) *italic ending* ")
        }
}

struct AttributedTextView_Previews: PreviewProvider {
    static var previews: some View {
        AttributedTextView()
    }
}

//struct StyledTextView: View {
//    var body: some View {
//        WrappingHStack(items: ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6", "Item 7", "Item 8"])
////        Section {
////            HStack{
////
////                Text("日記を")
////                    .foregroundColor(.black)
////                Text("100")
////                    .foregroundColor(.black)
////                Text("文字書く文字書く文字書く文字書く文字書く文字書く文字書く")
////                    .foregroundColor(.red)
////                    .font(.system(size: 16, weight: .bold))
////                    .underline(true, color: .red)
////            }
////            // 複数のTextビューを連結する例
//////            Text("日記を")
//////                .foregroundColor(.black) +
//////            Text("100")
//////                .foregroundColor(.black) +
//////            Text("文字書く")
//////                .foregroundColor(.red)
//////                .font(.system(size: 16, weight: .bold))
//////                .underline(true, color: .red)
////        }
//    }
//}
//
//struct StyledTextView_Previews: PreviewProvider {
//    static var previews: some View {
//        StyledTextView()
//    }
//}

struct CustomTouchCaptureViewExample: View {
    @State private var isPressed = false
    @State private var text = "100"
    @State private var showTextField = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        HStack(alignment: .center) {


//            Button {
//                print("Left")
//                showTextField = false
//            } label: {
//                Text("Left")
//                    .padding()
//                    .background(Color(.systemGray5))
//                    .cornerRadius(12)
//            }
//            .buttonStyle(PlainButtonStyle())
            Text("日記を")
                .font(.system(size: 18, weight: .medium))
            //タスクの条件入力欄
            if showTextField {
                TextField("0", text: $text)
                    .font(.system(size: 18, weight: .medium))
                    .padding(4)
                    .fixedSize()
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .focused($isTextFieldFocused) // FocusStateを適用
                    .onAppear {
                        isTextFieldFocused = true // TextFieldが表示されたときにフォーカスを設定
                    }
                // Returnキーが押されたときのアクション
                    .onSubmit {

                        isTextFieldFocused = false // フォーカスを外す
                        showTextField = false // showTextFieldをfalseに設定
                    }
            } else {
                Button {
                    showTextField.toggle()
                } label: {
                    Text(text)
                        .padding(4)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                        .font(.system(size: 18, weight: .medium))
                }
                //                    .buttonStyle(PlainButtonStyle())
            }
            Text("文字以上書く")
                .font(.system(size: 18, weight: .medium))
                 // 押し込まれたときの透明度を設定

            Spacer()
        }
        .padding(4)
        .contentShape(Rectangle())
        .cornerRadius(8)
        .padding()
        .opacity(isPressed ? 0.5 : 1.0)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true // 押し込まれたときにフラグをtrueにする
                    }
                }
                .onEnded { _ in
                    isPressed = false // 指が離れたときにフラグをfalseにする
                }
        )

    }
}

struct CustomTouchCaptureViewExample_Previews: PreviewProvider {
    static var previews: some View {
        CustomTouchCaptureViewExample()
    }
}

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color.blue : Color.red)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct OuterButton: View {
    @State private var textTapped = false

    var body: some View {
        Button(action: {
            // No action needed here
        }) {
            HStack {
                InnerButton()
                Spacer()
                Text("aaa")
            }
            .padding()
            .background(textTapped ? Color(.systemBackground).opacity(0.5) : Color(.systemGray6))
            .cornerRadius(16) // Add corner radius for better visuals
            .contentShape(Rectangle()) // Ensure the outer button only detects taps within its bounds
        }
        .buttonStyle(OuterButtonStyle(textTapped: $textTapped))
    }
}

struct InnerButton: View {
    var body: some View {
        Button(action: {
            print("hello")
        }) {
            Image(systemName: "circle.fill").padding()
                .border(Color.red)
        }
        .buttonStyle(PlainButtonStyle()) // Ensure inner button has its own style and does not interfere with outer button
    }
}

struct OuterButtonStyle: ButtonStyle {
    var textTapped: Binding<Bool>

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Group {
                    if configuration.isPressed {
                        Color(.systemBackground).opacity(0.5)
                    } else {
                        Color(.systemGray6)
                    }
                }
            )
            .cornerRadius(8) // Add corner radius for better visuals
            .onChange(of: configuration.isPressed) { newValue in
                textTapped.wrappedValue = newValue
            }
            .animation(.easeInOut, value: configuration.isPressed)
    }
}


struct OuterButton_Previews: PreviewProvider {
    static var previews: some View {
        OuterButton()
    }
}


struct StackOverflow5: View {
    @State private var text = "100"
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            TextField("Enter text", text:self.$text)
                .focused(self.$isFocused) // `focused`修飾子で`FocusState`にバインド
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Focus TextField") {
                isFocused = true // ボタンを押すとフォーカスを設定
            }

            Button("Unfocus TextField") {
                isFocused = false // ボタンを押すとフォーカスを解除
            }
            Section{
                Button{

                } label: {
                    HStack(spacing:8){
                        TextField("0", text: $text)
                            .font(.system(size: 18, weight: .medium))
                        //                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                            .padding(8)
                            .fixedSize()
                            .background(Color(.systemGray5))
                            .cornerRadius(16)
                        Text("文字以上日記を書く")
                            .foregroundColor(.primary)
                            .font(.system(size: 18, weight: .medium))
                    }


                    .padding(12)
                }
            }
            //        .padding(0)
            .background(Color.gray.opacity(0.5))
            .background(Color.white.opacity(0.05))
            .background(Color(.systemBackground))
            .cornerRadius(16)

        }
        .padding()

        //        HStack(spacing:8){
        //            TextField("0", text: $text)
        //                .font(.system(size: 24, weight: .medium))
        ////                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
        //                .padding(8)
        //                .fixedSize()
        //                .background(Color(.systemGray5))
        //                .cornerRadius(16)
        //            Text("文字以上日記を書く")
        //                .font(.system(size: 24, weight: .medium))
        //        }




    }
}

struct StackOverflow5_Previews: PreviewProvider {
    static var previews: some View {
        StackOverflow5()
    }
}

struct Page2: View {
    var body: some View {
        Text("Page2")
    }
}

//struct ContentView: View {
//    @State private var hour = 0
//    @State private var minute = 0
//    @State private var isSheetOpen = false
//    @StateObject private var viewModel = TimeSelectionViewModel()
//    @State var isOpenStartSet=false
//    @State var isOpenEndSet=false
//
//    private func numToString(_ num: Int) -> String {
//        return String(format: "%02d", num)
//    }
//    @State var startHour=0
//    @State var startMin=0
//    @State var endHour=0
//    @State var endMin=0
//
//    var body: some View {
//        VStack {
//            Button("Open Sheet") {
//                isSheetOpen.toggle()
//            }
//            .sheet(isPresented: $isSheetOpen) {
//                Section {
//                    // （１）開始ボタン
//                    Button {
//                        // アニメーションをつけてニュッと開く
//                        withAnimation {
//                            isOpenStartSet.toggle()
//                            isOpenEndSet = false
//                        }
//                    } label: {
//                        HStack {
//                            Text("開始")
//                                .foregroundColor(.primary)
//                            Spacer()
//                            Text("\(numToString(startHour)):\(numToString(startMin))")
//                                .foregroundColor(isOpenStartSet ? .blue : .secondary)
//                            Image(systemName: "chevron.down")
//                                .font(.system(size: 16, weight: .medium))
//                                .fontWeight(.regular)
//                                .foregroundColor(Color(.systemGray2))
//                                .frame(width: 20, height: 20)
//                        }
//                    }
//                    SelectTimeWheelView(
//                        hour: $startHour, minute: $startMin,
//                        isOpen: $isOpenStartSet)
//                    // isOpenStartSetがtrueの時、表示
//                    if isOpenStartSet {
//                        SelectTimeWheelView(
//                            hour: $startHour, minute: $startMin,
//                            isOpen: $isOpenStartSet)
//                    }
//                    // （２）終了ボタン
//                    Button {
//                        // アニメーションをつけてニュッと開く
//                        withAnimation {
//                            isOpenEndSet.toggle()
//                            isOpenStartSet = false
//                        }
//                    } label: {
//                        HStack {
//                            Text("終了")
//                                .foregroundColor(.primary)
//                            Spacer()
//                            Text("\(numToString(endHour)):\(numToString(endMin))")
//                                .foregroundColor(isOpenEndSet ? .blue : .secondary)
//                            Image(systemName: "chevron.down")
//                                .font(.system(size: 16, weight: .medium))
//                                .fontWeight(.regular)
//                                .foregroundColor(Color(.systemGray2))
//                                .frame(width: 20, height: 20)
//                        }
//                    }
//                    // isOpenEndSetがtrueの時、表示
//                    if isOpenEndSet {
//                        SelectTimeWheelView(
//                            hour: $endHour, minute: $endMin,
//                            isOpen: $isOpenEndSet)
//                    }
//
//                }
////                SelectTimeWheelView(hour: $hour, minute: $minute, isOpen: $isSheetOpen)
//                    .presentationCornerRadius(32) // ここで角丸を適用
//                    .presentationDragIndicator(.visible) // インジケータを表示
//            }
//        }
//    }
//}
struct TextFieldView: View {
    @State private var text: String = "100"

    var body: some View {
        ZStack {
            VStack {
                Spacer()

                TextField("Enter", text: $text)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Spacer()
            }

            VStack {
                Spacer()

                Button(action: {
                    print("Button tapped")
                }) {
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
                .background(Color.white)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .onTapGesture {
            self.dismissKeyboard()
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct TextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        TimePickerView()
    }
}


struct ContentView: View {
    @StateObject private var viewModel = TimeSelectionViewModel()

    //    @State private var isShowPopoverEnd = false
    //    @State private var isShowPopoverStart = false
    //    @State private var endTime = Date()
    //    @State private var startTime = Date()
    //
    //    private var dateFormatter: DateFormatter {
    //        let formatter = DateFormatter()
    //        formatter.dateStyle = .short
    //        formatter.timeStyle = .short
    //        return formatter
    //    }

    var body: some View {

        VStack{
            //                Text("aa")
//            SelectTimeView(
//                startHour: $viewModel.startHour,
//                startMin: $viewModel.startMin,
//                endHour: $viewModel.endHour,
//                endMin: $viewModel.endMin,
//                isOpenStartSet: $viewModel.isOpenStartSet,
//                isOpenEndSet: $viewModel.isOpenEndSet
//            )
//            .background(Color(.systemGray5))
//            .cornerRadius(16)
        }

    }
}

struct CustomDatePickerPopover: View {
    @Binding var selectedDate: Date
    @Binding var isShowPopover: Bool

    var body: some View {
        VStack {

            DatePicker(
                "Time",
                selection: $selectedDate,
                displayedComponents: [.hourAndMinute]
            )
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()

        }
    }
}

struct CustomPressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.black.opacity(0.1) : Color(.systemBackground))
    }
}

//22222
struct CenteredTextView: View {
    var text: String

    var body: some View {
        VStack {
            Spacer()
            Text(text)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
}

struct ボタンタップ時にボタンの中央にcustompopover表示: View {
    @State private var isPopoverPresented = false


    var body: some View {
        VStack {
            Button("Show Popover") {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPopoverPresented = true
                }
            }
            .customPopover(isPresented: $isPopoverPresented) {
                Text("This is a custom popover")
                    .padding()
            }
        }
    }
}

struct MenuView: View {
    @State private var selectedMenu: Int? = nil
    @State private var isPopoverPresented = false

    let menuItems = ["メニュー1", "メニュー2", "メニュー3", "メニュー4"]

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)

            Color.black.opacity(selectedMenu != nil ? 0.1 : 0)
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut(duration: 0.2), value: selectedMenu)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMenu = nil
                    }
                }
            VStack {
                Button("Show Popover") {
                    withAnimation {
                        isPopoverPresented = true
                    }
                }
            }
            .customPopover(isPresented: $isPopoverPresented) {
                AnyView(
                    Text("This is a custom popover")
                        .padding()
                )
            }


            VStack {
                VStack(spacing: 0) {
                    ForEach(0..<menuItems.count, id: \.self) { index in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if selectedMenu == nil || selectedMenu == index {
                                    selectedMenu = index
                                } else {
                                    selectedMenu = nil
                                }
                            }
                        }) {
                            Text(menuItems[index])
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .overlay(
                                    // フィルターのオーバーレイ
                                    selectedMenu != nil && selectedMenu != index ?
                                    Color.black.opacity(0.1) : Color.clear
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .background(Color.white)
                .cornerRadius(16)
                .padding()
            }
        }
    }
}



struct CustomPopover<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content

    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.001) // 背景の薄い影
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isPresented = false

                    }

                VStack {
                    content
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 0) // 影のカスタマイズ
                }
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.2)))
            }
        }
    }
}

extension View {
    func customPopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        ZStack {
            self
            CustomPopover(isPresented: isPresented, content: content())
        }
    }
}


struct ボタンタップしたらwheelをボタンの下に表示: View {
    @State private var isTapped = false
    @State private var isVisible = false
    @State private var selectedDate = Date()

    var body: some View {
        ZStack {
            if isVisible {
                // DatePicker with corner radius and opacity animation
                VStack {
                    DatePicker("Select Time", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                }
                .frame(width: 200, height: 200) // Base frame size
                .background(.regularMaterial)
                .cornerRadius(20)
                .scaleEffect(isTapped ? 1 : 0.5, anchor: .top)
                .opacity(isTapped ? 1 : 0)
                .onAppear {
                    withAnimation(.timingCurve(0.3, 1.6, 0.6, 1.0, duration: 0.3)) {
                        isTapped = true
                    }
                }
                .onDisappear {
                    withAnimation(.easeIn(duration: 0.3)) {
                        isTapped = false
                    }
                }
            }

            VStack {
                // Button
                Button(action: {
                    if isTapped {
                        withAnimation(.easeIn(duration: 0.1)) {
                            isTapped = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isVisible = false
                        }
                    } else {
                        isVisible = true
                        withAnimation(.timingCurve(0.3, 1.6, 0.6, 1.0, duration: 0.3)) {
                            isTapped = true
                        }
                    }
                }) {
                    Text("Animate")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 50) // Adjust bottom padding as needed
            }
        }
    }
}

// カスタム構造体を作成し、Identifiableプロトコルに準拠させる
struct ListItem: Identifiable {
    let id = UUID() // 一意のID
    let name: String
}
struct ListmenuView: View {
    let items = [
        ListItem(name: "アイテム1"),
        ListItem(name: "アイテム2"),
        ListItem(name: "アイテム3"),
        ListItem(name: "アイテム4")
    ]
    @State private var selectedItem: ListItem?
    @StateObject private var viewModel = TimeSelectionViewModel()

    var body: some View {
        List {
            Section{
//                SelectTimeView(
//                    startHour: $viewModel.startHour,
//                    startMin: $viewModel.startMin,
//                    endHour: $viewModel.endHour,
//                    endMin: $viewModel.endMin,
//                    isOpenStartSet: $viewModel.isOpenStartSet,
//                    isOpenEndSet: $viewModel.isOpenEndSet
//                )
            }
            Section(header: Spacer(minLength: 10)) {
                Text(verbatim: "First Section")
            }
            Text("リンゴ🍎")
            Text("ミカン🍊")
            Text("バナナ🍌")
            Text("ぶどう🍇")
            Text("パイナップル🍍")
//            SelectTimeView(
//                startHour: $viewModel.startHour,
//                startMin: $viewModel.startMin,
//                endHour: $viewModel.endHour,
//                endMin: $viewModel.endMin,
//                isOpenStartSet: $viewModel.isOpenStartSet,
//                isOpenEndSet: $viewModel.isOpenEndSet
//            )
        }

    }
}
struct DetailView: View {
    var selectedItem: ListItem

    var body: some View {
        VStack {
            Text("選択されたアイテム: \(selectedItem.name)")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .padding()
    }
}


struct DynamicPopover<Content: View>: View {
    @Binding var isPresented: Bool
    let yPosition: CGFloat
    let content: Content

    init(isPresented: Binding<Bool>, yPosition: CGFloat, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.yPosition = yPosition
        self.content = content()
    }

    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.1) // 背景の薄い影
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isPresented = false
                    }

                VStack {
                    content
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4) // 影のカスタマイズ
                }
                .position(x: UIScreen.main.bounds.width / 2, y: yPosition)
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.2)))
            }
        }
    }
}

struct ButtonPositionKey: PreferenceKey {
    typealias Value = [Int: CGRect]
    static var defaultValue: [Int: CGRect] = [:]

    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { (_, new) in new }
    }
}

struct ボタンタップ時にMenuを表示: View {
    @State private var selectedOption = "選択してください"

    var body: some View {
        VStack {
            Text("選択されたオプション: \(selectedOption)")
                .padding()

            Menu {
                Button(action: {
                    selectedOption = "オプション1"
                }) {
                    Text("オプション1")
                    Image(systemName: "1.circle")
                }

                Button(action: {
                    selectedOption = "オプション2"
                }) {
                    Text("オプション2")
                    Image(systemName: "2.circle")
                }

                Button(action: {
                    selectedOption = "オプション3"
                }) {
                    Text("オプション3")
                    Image(systemName: "3.circle")
                }
            } label: {
                Label("メニューを開く", systemImage: "ellipsis.circle")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        //        SelectTimeView()
        //        OverlayExampleView()
//        OverlayExampleView()
        /*AuthorizationView()*/
//        ボタンタップ時にMenuを表示()
//        ボタンタップ時にボタンの中央にcustompopover表示()
//        ボタンタップしたらwheelをボタンの下に表示()
        //        CenteredTextView(text: "This is centered text")

    }
}

struct TimePickerView: View {
    @State var currentTime = Date()
    @State private var isTimePickerVisible = false

    var body: some View {
        Form{
            Section(header:Text("")){
                DatePicker("開始",selection: $currentTime)
            }
        }
    }
}

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var isTimePickerVisible: Bool

    var body: some View {
        VStack {
            DatePicker(
                "Select a time",
                selection: $selectedDate,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
            .padding()

            HStack {
                Button(action: {
                    isTimePickerVisible = false
                }) {
                    Text("Cancel")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                Button(action: {
                    isTimePickerVisible = false
                }) {
                    Text("Confirm")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                //                .padding()
            }
            //            .padding()

            Spacer()
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        //        .padding()
    }
}


//struct CustomButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .background(configuration.isPressed ? Color.black.opacity(0.05) : Color(.systemBackground))
//            .cornerRadius(8)
//            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
//            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
//    }
//}


//struct SelectTimeView: View {
//    init() {
//            UIDatePicker.appearance().minuteInterval = 5
//        }
//    // 現在の時間を取得
//    let currentHour = Calendar.current.component(.hour, from: Date())
//
//    // 保存される時間
//    @AppStorage("start_hour1") var startHour: Int = Calendar.current.component(.hour, from: Date()) + 1
//    @AppStorage("start_min1") var startMin: Int = 0
//    @AppStorage("end_hour1") var endHour: Int = Calendar.current.component(.hour, from: Date()) + 2
//    @AppStorage("end_min1") var endMin: Int = 0
//
//    // Pickerを開け閉めするための状態変数
//    @State var isOpenStartSet: Bool = false
//    @State var isOpenEndSet: Bool = false
//
//    var body: some View {
//        List {
//            // 開始・終了セクション
//            Section {
//                // （１）開始ボタン
//                Button {
//                    // アニメーションをつけてニュッと開く
//                    withAnimation {
//                        isOpenStartSet.toggle()
//                        isOpenEndSet = false
//                    }
//                } label: {
//                    HStack {
//                        Text("開始")
//                            .foregroundColor(.primary)
//                        Spacer()
//                        Text("\(numToString(startHour)):\(numToString(startMin))")
//                            .foregroundColor(isOpenStartSet ? .blue : .secondary)
//                        Image(systemName: "chevron.down")
//                            .font(.system(size: 16, weight: .medium))
//                            .fontWeight(.regular)
//                            .foregroundColor(Color(.systemGray2))
//                            .frame(width: 20, height: 20)
//                    }
//                }
//                // isOpenStartSetがtrueの時、表示
//                if isOpenStartSet {
//                    SelectTimeWheelView(
//                        hour: $startHour, minute: $startMin,
//                        isOpen: $isOpenStartSet)
//                }
//                // （２）終了ボタン
//                Button {
//                    // アニメーションをつけてニュッと開く
//                    withAnimation {
//                        isOpenEndSet.toggle()
//                        isOpenStartSet = false
//                    }
//                } label: {
//                    HStack {
//                        Text("終了")
//                            .foregroundColor(.primary)
//                        Spacer()
//                        Text("\(numToString(endHour)):\(numToString(endMin))")
//                            .foregroundColor(isOpenEndSet ? .blue : .secondary)
//                        Image(systemName: "chevron.down")
//                            .font(.system(size: 16, weight: .medium))
//                            .fontWeight(.regular)
//                            .foregroundColor(Color(.systemGray2))
//                            .frame(width: 20, height: 20)
//                    }
//                }
//                // isOpenEndSetがtrueの時、表示
//                if isOpenEndSet {
//                    SelectTimeWheelView(
//                        hour: $endHour, minute: $endMin,
//                        isOpen: $isOpenEndSet)
//                }
//            }
//            Section(header: Text("ここに説明とか入れるとそれっぽいですね。").font(.caption)) {}
//        } // List
//    } // body
//
//    // Int型の"2"を"02"とか0埋めしてくれる処理
//    private func numToString(_ num: Int) -> String {
//        return String(format: "%02d", num)
//    }
//}
//
//struct SelectTimeWheelView: View {
//    // バインド変数
//    @Binding var hour: Int
//    @Binding var minute: Int
//    @Binding var isOpen: Bool
//
//    var body: some View {
//        VStack {
//            DatePicker("",
//                       selection: Binding(
//                        get: { combineToSelectedDate(hour: hour, minute: minute) },
//                        set: { date in
//                            let components = Calendar.current.dateComponents([.hour, .minute], from: date)
//                            hour = components.hour ?? 0
//                            minute = components.minute ?? 0
//                        }
//                       ),
//                       displayedComponents: [.hourAndMinute])
//            .datePickerStyle(WheelDatePickerStyle())
//            .labelsHidden()
//        }
//    }
//
//    private func combineToSelectedDate(hour: Int, minute: Int) -> Date {
//        let calendar = Calendar.current
//        var components = DateComponents()
//        components.hour = hour
//        components.minute = minute
//        return calendar.date(from: components) ?? Date()
//    }
//}


