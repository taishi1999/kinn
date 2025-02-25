import SwiftUI

struct パーツ_時刻選択: View {
    @Binding var 開始時刻: Date
    @Binding var 終了時刻: Date

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("開始")
                Spacer()
                DatePicker(
                    "",
                    selection: $開始時刻,
                    displayedComponents: [.hourAndMinute]
                )
            }

            DatePicker(
                "終了",
                selection: $終了時刻,
                displayedComponents: [.hourAndMinute]
            )
        }
//        .padding()
    }
}
