import SwiftUI

struct パーツ_セグメントピッカー: View {
    private enum Periods: String, CaseIterable, Identifiable {
        case schedule = "スケジュール"
        case task = "タスク"
//        case month = "月"
//        case year = "年"

        var id: String { rawValue }
    }

    @State private var selectedPeriod = Periods.schedule

//    init() {
//        // 背景色
//        UISegmentedControl.appearance().backgroundColor = UIColor(Color.secondary.opacity(0.4))
//        // 選択項目の背景色
//        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.darkButton)
//        // 選択項目の文字色
//        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
//    }

    var body: some View {
        Picker("periods", selection: $selectedPeriod) {
            ForEach(Periods.allCases) {
                Text($0.rawValue).tag($0)
            }

        }

        .background(.bar)
        .cornerRadius(8)
        .pickerStyle(.segmented)
        .padding(.horizontal,24)

    }
}

struct パーツ_セグメントピッカー_Previews: PreviewProvider {
    static var previews: some View {
        パーツ_セグメントピッカー()
    }
}
