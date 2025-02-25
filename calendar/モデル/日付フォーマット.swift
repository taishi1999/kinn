import SwiftUI

// 指定した日付を0時にリセットした日付を返す関数
private func 日付の始まり(_ date: Date) -> Date {
    return Calendar.current.startOfDay(for: date)
}

// 今日の日付と比較して、指定した日付との日数差を返す関数
private func 日付の差(_ date: Date) -> (today: Date, entryDate: Date, dayDifference: Int) {
    let calendar = Calendar.current
    let today = 日付の始まり(Date())
    let entryDate = 日付の始まり(date)
    let components = calendar.dateComponents([.day], from: entryDate, to: today)
    let dayDifference = components.day ?? 0
    return (today, entryDate, dayDifference)
}

// 曜日を1文字で返す関数
private func 曜日取得(_ date: Date) -> String {
    let weekdayFormatter = DateFormatter()
    weekdayFormatter.locale = Locale(identifier: "ja_JP")  // 日本語に設定
    weekdayFormatter.dateFormat = "EEE"
    return weekdayFormatter.string(from: date)
}

// メインの日付フォーマット関数
public func 日付フォーマット(_ date: Date) -> String {
    let (today, entryDate, dayDifference) = 日付の差(date)

    // 今日の場合
    if Calendar.current.isDateInToday(entryDate) {
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ja_JP")
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.string(from: date)

        // 昨日の場合
    } else if Calendar.current.isDateInYesterday(entryDate) {
        return "昨日"
//        return "昨日(\(曜日取得(date)))"

        // 6日前まで
    }
    else if dayDifference <= 6 {
        //        return 曜日取得(date) + "曜日"  // 曜日に「曜日」を追加
//        return "\(dayDifference)日前(\(曜日取得(date)))"
        return "\(曜日取得(date))曜日"

        // それ以降
    } 
    else {
        return 年付き日付フォーマット(date, 詳しいフォーマット: false)
    }
}

// 今年かどうかでフォーマットを切り替える関数
public func 年付き日付フォーマット(_ date: Date, 詳しいフォーマット: Bool) -> String {
    let (today, entryDate, _) = 日付の差(date)
    let calendar = Calendar.current
    let currentYear = calendar.component(.year, from: today)
    let entryYear = calendar.component(.year, from: entryDate)

    let weekday = 曜日取得(date)

    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ja_JP")

    // 今年かどうかとフォーマットの種類で分岐
    if currentYear == entryYear {
        dateFormatter.dateFormat = 詳しいフォーマット ? "M月d日 \(weekday)曜日" : "M/d \(weekday)曜日"

//        dateFormatter.dateFormat = 詳しいフォーマット ? "MM月dd日 '(\(weekday))'" : "MM/dd '(\(weekday))'"
    } else {
        dateFormatter.dateFormat = 詳しいフォーマット ? "yyyy年M月d日 \(weekday)曜日" : "yyyy/M/d \(weekday)曜日"

//        dateFormatter.dateFormat = 詳しいフォーマット ? "yyyy年MM月dd日 '(\(weekday))'" : "yyyy/MM/dd '(\(weekday))'"
    }

    return dateFormatter.string(from: date)
}
