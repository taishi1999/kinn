import SwiftUI
struct DatePickerExample: View {
    @State private var date = Date()
   
    var body: some View {
        DatePicker(
            "Pick a date",
            selection: $date,
            in: Date()...,
            displayedComponents: [.date])
            .padding()
    }
}

struct DatePickerExample_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerExample()
    }
}

struct リマインダーで見るタイプのtimePicker: View {
    @FocusState private var pinFocusState: Bool
    @State private var isButtonAbled: Bool = true
    @State private var date = Date()

    @State private var isOpenStartSet: Bool=false
    @State private var isOpenEndSet: Bool=false
    @State private var startTime: Date=Date()
    @State private var endTime: Date=Date()

    var body: some View {
        ZStack {
            Color.white
            ScrollView{
                VStack(spacing:0){
                    //---dropdown型のtimePicker
                    // （１）開始ボタン
                    Button {
                        // アニメーションをつけてニュッと開く
                        withAnimation {
                            isOpenStartSet.toggle()
                            isOpenEndSet = false
                        }
                    } label: {
                        HStack {
                            Text("開始")
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding()
                    }
                    // isOpenStartSetがtrueの時、表示
                    if isOpenStartSet {
                        SelectTimeWheelView(
                            selectedDate: $startTime, isOpen: $isOpenStartSet
                        )

                        Divider()
                    }

                    // （２）終了ボタン
                    Button {
                        // アニメーションをつけてニュッと開く
                        withAnimation {
                            isOpenEndSet.toggle()
                            isOpenStartSet = false
                        }
                    } label: {
                        HStack {
                            Text("終了")
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding()
                    }
                    // isOpenEndSetがtrueの時、表示
                    if isOpenEndSet {
                        SelectTimeWheelView(
                            selectedDate: $endTime, isOpen: $isOpenEndSet)
                    }
                    //---dropdown型のtimePicker


                }
                .background(Color(.systemGray6))
            }

        }
        .onTapGesture {
            pinFocusState = false
            isButtonAbled = true
        }
    }
}

struct リマインダーで見るタイプのtimePicker_Previews: PreviewProvider {
    static var previews: some View {
        リマインダーで見るタイプのtimePicker()
    }
}
