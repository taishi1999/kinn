import UserNotifications

class LocalNotificationManager {
    static let shared = LocalNotificationManager()

    private init() {}

    /// 通知の許可をリクエスト
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("通知許可リクエストエラー: \(error.localizedDescription)")
                completion(false)
            } else {
                print("通知許可が\(granted ? "許可されました" : "拒否されました")")
                completion(granted)
            }
        }
    }

    /// 通知を送信
    func sendNotification(title: String, body: String, timeInterval: TimeInterval = 5) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知送信エラー: \(error.localizedDescription)")
            } else {
                print("通知が送信されました")
            }
        }
    }
}
