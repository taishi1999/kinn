
import SwiftUI

extension Color {
    static let customBlue = Color(red: 24/255, green: 140/255, blue: 216/255)
    static let darkBackground = Color(red: 16/255, green: 16/255, blue: 16/255)  // 黒い背景色の追加
    static let darkButton_normal = Color(red: 28/255, green: 28/255, blue: 28/255)  // 追加した色
    static let darkButton_thin = Color(red: 14/255, green: 14/255, blue: 14/255)  // 追加した色

    static let buttonOrange = Color(red: 166/255, green: 102/255, blue: 0/255)  // 淡いオレンジ色
    static var ThemeColor: Color {
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : .white
        })
    }
    static let lightGray200 = Color(red: 200 / 255, green: 200 / 255, blue: 200 / 255)
}

extension Date {
    func withZeroMinutes() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: self)
        return calendar.date(from: components) ?? self
    }
}
