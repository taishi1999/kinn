import SwiftUI

struct ビュー_ブロック状態監視: View {
    @StateObject private var 状態監視: ブロック状態監視

    init(startTime: Date, endTime: Date, repeatDaysString: String) {
        let repeatDays = repeatDaysString
            .split(separator: ",")
            .compactMap { Int($0) }

        _状態監視 = StateObject(wrappedValue: ブロック状態監視(
            startTime: startTime,
            endTime: endTime,
            repeatDays: repeatDays
        ))
    }

    var body: some View {
        VStack {
            Text("現在のブロック状態:")
                .font(.headline)

            Text(状態監視.現在の状態Text)
                .font(.largeTitle)
                .padding()

            Text("次の状態変化までの残り時間: \(状態監視.残り時間Text)")
                .font(.title2)
                .padding()

            Spacer()
        }
        .padding()
    }
}

// プレビュー用コード
struct ビュー_ブロック状態監視_Previews: PreviewProvider {
    static var previews: some View {
        ビュー_ブロック状態監視(
            startTime: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!,
            endTime: Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Date())!,
            repeatDaysString: "0,1,2,3,4,5,6"
        )
    }
}
