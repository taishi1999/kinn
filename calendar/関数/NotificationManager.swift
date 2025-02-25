import SwiftUI
import UserNotifications

final class NotificationManager {
    static let instance = NotificationManager()

    // 権限リクエスト
    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
                print("Permission granted: \(granted)")
            }
    }

    // 通知の登録
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Notification Title"
        content.body = "Local Notification Test"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "notification01", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}


/// ローカル通知のスケジュール処理を管理する ObservableObject
class NotificationScheduler: ObservableObject {

    /// シングルトンパターンで共有インスタンスを用意
    static let shared = NotificationScheduler()

    private init() { }

    /// 5秒後にローカル通知をスケジュールするメソッド
    func scheduleNotificationInFiveSeconds() {
        let center = UNUserNotificationCenter.current()

        // 通知の許可をリクエスト（すでに許可済みなら即時に完了）
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                // 通知内容の設定
                let content = UNMutableNotificationContent()
                content.title = "Device Activity"
                content.body = "5秒後にこの通知が届きます。"
                content.sound = .default

                // 5秒後に発火するトリガー（リピートなし）
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                // 一意な識別子を用いて通知リクエストを作成
                let request = UNNotificationRequest(identifier: UUID().uuidString,
                                                    content: content,
                                                    trigger: trigger)

                // 通知を登録
                center.add(request) { error in
                    if let error = error {
                        print("通知スケジュールエラー: \(error.localizedDescription)")
                    } else {
                        print("5秒後に通知がスケジュールされました")
                    }
                }
            } else {
                if let error = error {
                    print("通知権限リクエストエラー: \(error.localizedDescription)")
                } else {
                    print("通知の許可が得られませんでした")
                }
            }
        }
    }

    
    enum NotificationError: Error {
        case permissionDenied
        case schedulingFailed
        case unknownError(String)
    }

    func scheduleNotification(startTime: Date, weekdays: [Int], repeats: Bool = true, completion: @escaping (Result<Void, NotificationError>) -> Void) {
        //ローカル通知を削除
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        let center = UNUserNotificationCenter.current()

        print("dateは: \(startTime)")

        // 通知権限をリクエスト
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("通知権限リクエストエラー: \(error.localizedDescription)")
                completion(.failure(.unknownError(error.localizedDescription)))
                return
            }

            guard granted else {
                print("通知の許可が得られませんでした")
                completion(.failure(.permissionDenied))
                return
            }

            let calendar = Calendar.current
            let now = Date()

            let hour = calendar.component(.hour, from: startTime)
            let minute = calendar.component(.minute, from: startTime)
            print("hourは: \(hour) minuteは: \(minute)")

            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()

            var hasScheduledNotification = false

            for weekday in weekdays {
                let content = UNMutableNotificationContent()
                content.title = "Continote"
                content.body = "日記を書く時間です！"
                content.sound = .default

                if let candidateToday = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now),
                   calendar.component(.weekday, from: candidateToday) == weekday,
                   candidateToday > now {
                    print("candidateToday: \(candidateToday)")
                    self.scheduleNotificationAt(date: candidateToday, content: content, repeats: repeats)
                    hasScheduledNotification = true
                } else {
                    var dateComponents = DateComponents()
                    dateComponents.hour = hour
                    dateComponents.minute = minute
                    dateComponents.second = 0
                    dateComponents.weekday = weekday

                    if let nextDate = calendar.nextDate(after: now, matching: dateComponents, matchingPolicy: .nextTime) {
                        print("nextDate: \(nextDate)")
                        self.scheduleNotificationAt(date: nextDate, content: content, repeats: repeats)
                        hasScheduledNotification = true
                    } else {
                        print("次の通知時刻が計算できませんでした (weekday \(weekday))")
                    }
                }
            }

            if hasScheduledNotification {
                completion(.success(()))
            } else {
                completion(.failure(.schedulingFailed))
            }
        }
    }


//    func scheduleNotification(startTime: Date, weekdays: [Int], repeats: Bool = true) {
//        //ローカル通知を削除
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//
//        let center = UNUserNotificationCenter.current()
//        print("dateは: \(startTime)")
//        
//        // 通知権限をリクエスト（すでに許可済みなら即座に完了します）
//        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if granted {
//                let calendar = Calendar.current
//                let now = Date()
//
//                let hour = calendar.component(.hour, from: startTime)
//                let minute = calendar.component(.minute, from: startTime)
//                print("hourは: \(hour) minuteは: \(minute)")
//
//                let center = UNUserNotificationCenter.current()
//                 // まず、以前に登録したすべての通知を削除する
//                 center.removeAllPendingNotificationRequests()
//
//                // 曜日ごとにループして通知をスケジュールする
//                for weekday in weekdays {
//                    // 通知内容の設定（曜日の数値はそのまま表示する例）
//                    let content = UNMutableNotificationContent()
//                    content.title = "Continote"
//                    content.body = "日記を書く時間です！"
//                    content.sound = .default
//
//                    // まず、今日の日付で指定時刻（秒は常に0）の候補を作成
//                    if let candidateToday = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now),
//                       calendar.component(.weekday, from: candidateToday) == weekday,
//                       candidateToday > now {
//                        print("candidateToday: \(candidateToday)")
//                        // 今日の指定時刻がまだ来ていない場合、今日の日時を使用
//                        self.scheduleNotificationAt(date: candidateToday, content: content, repeats: repeats)
//                    } else {
//                        // 今日が該当しない場合、次の指定曜日の日付を計算
//                        var dateComponents = DateComponents()
//                        dateComponents.hour = hour
//                        dateComponents.minute = minute
//                        dateComponents.second = 0
//                        dateComponents.weekday = weekday  // 指定曜日をセット
//
//                        // nextDate(after:matching:) は常に現在より未来の日付を返す
//                        if let nextDate = calendar.nextDate(after: now, matching: dateComponents, matchingPolicy: .nextTime) {
//                            print("nextDate: \(nextDate)")
//                            self.scheduleNotificationAt(date: nextDate, content: content, repeats: repeats)
//                        } else {
//                            print("次の通知時刻が計算できませんでした (weekday \(weekday))")
//                        }
//                    }
//                }
//            } else {
//                if let error = error {
//                    print("通知権限リクエストエラー: \(error.localizedDescription)")
//                } else {
//                    print("通知の許可が得られませんでした")
//                }
//            }
//        }
//    }

    func scheduleNotificationAt(date: Date, content: UNMutableNotificationContent, repeats: Bool) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)

        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知スケジュールエラー: \(error.localizedDescription)")
            } else {
                // ※ 出力される日時は UTC 表示のため、実際のローカル日時と異なる場合があります
                print("通知が \(date) にスケジュールされました (weekday: \(calendar.component(.weekday, from: date)))")
            }
        }
    }

    func cancelAllScheduledNotifications() {
        let center = UNUserNotificationCenter.current()

        center.removeAllPendingNotificationRequests() // 🔹 すべての未実行の通知を削除
//        center.removeAllDeliveredNotifications() // 🔹 すでに表示された通知も削除
        print("🔔 すべてのローカル通知をキャンセルしました")
    }
}
