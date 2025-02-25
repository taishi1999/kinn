import Foundation
import AVFoundation
import UserNotifications
import SwiftUI
import AudioToolbox


import SwiftUI
import UserNotifications

struct 通知スケジュールビュー: View {
    @State private var permissionStatus: UNAuthorizationStatus = .notDetermined
    @StateObject private var alarmScheduler = AlarmScheduler()
    // DatePicker で選択された日時を保持する
        @State private var scheduledDate = Date()
        // 通知がスケジュールされたかどうかのフラグ（UI表示用）
    var body: some View {
//        VStack {
//            Button("通知の許可を確認") {
//                checkNotificationPermissionStatus { status in
//                    self.permissionStatus = status
//                    if status == .denied {
//                        openAppSettings()
//                    }
//                }
//            }
//
//            Button("Request Permission") {
//                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
//                    if success {
//                        print("All set!")
//                    } else if let error {
//                        print(error.localizedDescription)
//                    }
//                }
//            }
//
//            Button("Schedule Notification") {
//                let content = UNMutableNotificationContent()
//                content.title = "Feed the cat"
//                content.subtitle = "It looks hungry"
//                content.sound = UNNotificationSound.default
//
//                // show this notification five seconds from now
//                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//                // choose a random identifier
//                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//
//                // add our notification request
//                UNUserNotificationCenter.current().add(request)
//            }
//        } .onAppear {
//            checkNotificationPermissionStatus()
//        }
        

        VStack {
            Button("Start Alarm") {
                // 通知の許可リクエスト（初回のみ）
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        print("権限リクエストエラー: \(error.localizedDescription)")
                    } else {
                        print("通知権限: \(granted ? "許可" : "拒否")")
                        if granted {
                            DispatchQueue.main.async {
                                alarmScheduler.startAlarm()
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.green.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("Stop Alarm") {
                alarmScheduler.stopAlarm()
            }
            .padding()
            .background(Color.red.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(8)

            DatePicker("通知時間を選択", selection: $scheduledDate)
                           .datePickerStyle(WheelDatePickerStyle())
                           .labelsHidden()
            Button("ローカル通知をスケジュール") {
//                scheduleNotifications(count: 64)
                scheduleNotificationInFiveSeconds()
//                scheduleOneTimeNotification(at: scheduledDate)
//                scheduleNotifications(atHour: 10, minute: 52, count: 64, intervalMinutes: 1)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .onAppear {
            requestNotificationPermission()
        }
    }
}

func scheduleNotificationInFiveSeconds() {
        let center = UNUserNotificationCenter.current()

        // 通知の許可をリクエスト（既に許可済みならすぐに完了）
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                // 通知内容の設定
                let content = UNMutableNotificationContent()
                content.title = "テスト通知"
                content.body = "ボタンを押してから5秒後に通知が届きました"
                content.sound = UNNotificationSound.default

                // 5秒後に通知を発火するトリガー（リピートなし）
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                // 一意な識別子を設定して通知リクエストを作成
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                // 通知をスケジュール
                center.add(request) { error in
                    if let error = error {
                        print("通知のスケジュールエラー: \(error.localizedDescription)")
                    } else {
                        print("通知が5秒後にスケジュールされました")
                    }
                }
            } else {
                if let error = error {
                    print("権限エラー: \(error.localizedDescription)")
                } else {
                    print("通知の許可が得られませんでした")
                }
            }
        }
    }

func scheduleOneTimeNotification(at date: Date) {
        let center = UNUserNotificationCenter.current()

        // 通知の許可をリクエスト（既に許可済みの場合は即時に完了）
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                // 通知内容の設定
                let content = UNMutableNotificationContent()
                content.title = "予定通知"
                content.body = "指定された時間になりました：\(formatted(date: date))"
                content.sound = .default

                // カレンダーコンポーネントを作成（指定日時に合わせる）
                var triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                triggerDate.second = 0
                // repeats を false にすることで、1回のみ発火
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

                // 一意な識別子を持つ通知リクエストを作成
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                // 通知を登録
                center.add(request) { error in
                    if let error = error {
                        print("通知スケジュールエラー: \(error.localizedDescription)")
                    }
                }
            } else {
                if let error = error {
                    print("権限エラー: \(error.localizedDescription)")
                } else {
                    print("通知の許可が得られませんでした")
                }
            }
        }
    }

func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        // 秒まで表示するためのフォーマットを設定
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter.string(from: date)
    }
// 🔹 通知の許可状態を取得（非同期）
    func checkNotificationPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    // 🔹 設定アプリを開く
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }

    // 🔹 許可状態をテキストに変換
    func permissionStatusText(_ status: UNAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "未設定"
        case .denied: return "拒否"
        case .authorized: return "許可"
        case .provisional: return "プロビジョナル"
        case .ephemeral: return "一時的"
        @unknown default: return "不明"
        }
    }
func checkNotificationPermissionStatus() {
    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings { settings in
        DispatchQueue.main.async {
            switch settings.authorizationStatus {
            case .notDetermined:
                print("通知の許可: 未設定（初回リクエスト可能）")
            case .denied:
                print("通知の許可: 拒否（設定アプリで手動許可が必要）")
            case .authorized:
                print("通知の許可: 許可済み")
            case .provisional:
                print("通知の許可: プロビジョナル（iOS 12以降のサイレント通知）")
            case .ephemeral:
                print("通知の許可: 一時的（iOS 14以降）")
            @unknown default:
                print("通知の許可: 未知の状態")
            }
        }
    }
}


// 通知の許可をリクエスト
func requestNotificationPermission() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("通知の許可リクエストエラー: \(error.localizedDescription)")
        } else if granted {
            print("通知の許可が取得されました。")
        } else {
            print("通知の許可が拒否されました。")
        }
    }
}

func scheduleNotifications(count: Int) {
    let center = UNUserNotificationCenter.current()
    let calendar = Calendar.current

    // 現在の日時を基準に初回通知の時間を計算（5秒後に初回通知）
    let now = Date()
    let startDate = now.addingTimeInterval(5)

    for i in 0..<count {
        // 5秒ごとに通知する
        let notificationDate = calendar.date(byAdding: .second, value: i * 5, to: startDate)!

        // 通知内容を作成
        let content = UNMutableNotificationContent()
        content.title = "通知 \(i + 1)"
        // 時刻情報に秒まで表示するように変更
        let hour = calendar.component(.hour, from: notificationDate)
        let minute = calendar.component(.minute, from: notificationDate)
        let second = calendar.component(.second, from: notificationDate)
        content.body = "\(hour)時\(minute)分\(second)秒の通知です。"
        content.sound = .default

        // 通知トリガーを作成
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // 通知リクエストを作成
        let request = UNNotificationRequest(
            identifier: "notification_\(i)",
            content: content,
            trigger: trigger
        )

        // 通知を登録
        center.add(request) { error in
            if let error = error {
                print("通知のスケジュールエラー: \(error.localizedDescription)")
            } else {
                print("通知 \(i + 1) がスケジュールされました: \(notificationDate)")
            }
        }
    }
}

// ローカル通知をスケジュール
//func scheduleNotifications(atHour hour: Int, minute: Int, count: Int, intervalMinutes: Int) {
//    let center = UNUserNotificationCenter.current()
//    let calendar = Calendar.current
//
//    // 現在の日付を基準に初回通知の時間を計算
//    let now = Date()
//    var startDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now)!
//
//    // 目標時刻が現在時刻より前の場合、翌日を設定
//    if startDate < now {
//        startDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
//    }
//
//    for i in 0..<count {
//        // 通知時刻を計算
//        let notificationDate = calendar.date(byAdding: .minute, value: i * intervalMinutes, to: startDate)!
//
//        // 通知内容を作成
//        let content = UNMutableNotificationContent()
//        content.title = "通知 \(i + 1)"
//        content.body = "\(calendar.component(.hour, from: notificationDate))時\(calendar.component(.minute, from: notificationDate))分の通知です。"
//        content.sound = .default
//
//        // 通知トリガーを作成
//        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//
//        // 通知リクエストを作成
//        let request = UNNotificationRequest(
//            identifier: "notification_\(i)",
//            content: content,
//            trigger: trigger
//        )
//
//        // 通知を登録
//        center.add(request) { error in
//            if let error = error {
//                print("通知のスケジュールエラー: \(error.localizedDescription)")
//            } else {
//                print("通知 \(i + 1) がスケジュールされました: \(notificationDate)")
//            }
//        }
//    }
//}


struct NotificationView: View {
    @State private var isGranted = false

    var body: some View {
        VStack(spacing: 20) {
            Text("ローカル通知テスト")
                .font(.largeTitle)

            Button(action: {
                requestNotificationAuthorization { granted in
                    isGranted = granted
                    if granted {
                        scheduleMultipleNotifications()
                    } else {
                        print("通知の許可が拒否されました")
                    }
                }
            }) {
                Text(isGranted ? "通知を再スケジュール" : "通知をリクエスト")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isGranted ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    // 通知の許可をリクエスト
    func requestNotificationAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { granted, error in
            if let error = error {
                print("通知の許可リクエストでエラーが発生しました: \(error)")
                completion(false)
            } else {
                completion(granted)
            }
        }
    }

    // 通知を100個スケジュール
    func scheduleMultipleNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // 古い通知を削除

        for i in 1...100 {
            let content = UNMutableNotificationContent()
            content.title = "Test"
            content.body = "Notification \(i)"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(1 + (1 * i)), repeats: false)

            let request = UNNotificationRequest(
                identifier: "identifier-\(i)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("通知のスケジュールに失敗しました: \(error)")
                } else {
                    print("通知 \(i) をスケジュールしました")
                }
            }
        }
    }
}


func scheduleNotifications(interval: TimeInterval, repeatCount: Int) {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests() // 古い通知を削除

    for i in 0..<repeatCount {
        let content = UNMutableNotificationContent()
        content.title = "起きる時間です！"
        content.body = "アラームを停止してください。"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval * Double(i + 1), repeats: false)

        let request = UNNotificationRequest(
            identifier: "Notification_\(i)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("通知のスケジュールに失敗しました: \(error)")
            } else {
                print("通知 \(i + 1) をスケジュールしました")
            }
        }
    }
}


struct AlarmNotificationView: View {
    @State private var isNotificationScheduled = false

    var body: some View {
        VStack(spacing: 20) {
            Text("5秒間隔通知アプリ")
                .font(.largeTitle)
                .padding()

            Button(action: {
                requestNotificationAuthorization { granted in
                    if granted {
                        if isNotificationScheduled {
                            stopNotifications()
                        } else {
                            startNotifications()
                        }
                    } else {
                        print("通知の許可が拒否されました")
                    }
                }
            }) {
                Text(isNotificationScheduled ? "通知を停止" : "通知を開始")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isNotificationScheduled ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    // 通知の許可をリクエスト
    func requestNotificationAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("通知の許可リクエストでエラーが発生しました: \(error)")
                completion(false)
            } else {
                completion(granted)
            }
        }
    }

    // 通知のスケジュールを開始
    func startNotifications() {
        isNotificationScheduled = true
        scheduleNotifications(interval: 3, repeatCount: 68) // 5秒間隔
    }

    // 通知を停止
    func stopNotifications() {
        isNotificationScheduled = false
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("すべての通知をキャンセルしました")
    }
}



class AudioManager {
    static let shared = AudioManager()
    private var player: AVAudioPlayer?
    private var vibrationTimer: Timer?

    // MP3再生の準備
    func prepareAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    // MP3ファイルを再生
    func playSound(fileName: String, fileExtension: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Audio file not found: \(fileName).\(fileExtension)")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // 無限ループ
            player?.play()
            print("Playing audio: \(fileName).\(fileExtension)")
        } catch {
            print("Error playing audio: \(error)")
        }
    }

    // 再生を停止
    func stopSound() {
        player?.stop()
        player = nil
        print("Audio stopped")
    }

    // バイブレーションを1回発生
    func triggerVibration() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        print("Vibration triggered")
    }

    // バイブレーションを繰り返し発生
    func startRepeatingVibration(interval: TimeInterval) {
        stopRepeatingVibration() // 既存のタイマーを停止
        vibrationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.triggerVibration()
        }
        print("Started repeating vibration with interval \(interval) seconds")
    }

    // 繰り返しバイブレーションを停止
    func stopRepeatingVibration() {
        vibrationTimer?.invalidate()
        vibrationTimer = nil
        print("Stopped repeating vibration")
    }
}

class VibrationManager {
    static let shared = VibrationManager()
    private var timer: Timer?

    // バイブレーションを繰り返し発生させる
    func startRepeatingVibration(interval: TimeInterval) {
        stopRepeatingVibration() // 既存のタイマーを停止

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) // バイブレーションを発生
        }
        print("Started repeating vibration with interval \(interval) seconds")
    }

    // バイブレーションを停止
    func stopRepeatingVibration() {
        timer?.invalidate()
        timer = nil
        print("Stopped repeating vibration")
    }
}

struct AudioPlayerView: View {
    @State private var isPlaying = false
    @State private var isVibrating = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Audio & Vibration")
                .font(.largeTitle)

            // 音声再生/停止ボタン
            Button(action: {
                if isPlaying {
                    AudioManager.shared.stopSound()
                } else {
                    AudioManager.shared.prepareAudioSession()
                    AudioManager.shared.playSound(fileName: "Clock_Alarm", fileExtension: "mp3")
                }
                isPlaying.toggle()
            }) {
                Text(isPlaying ? "Stop Audio" : "Play Audio")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isPlaying ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            // バイブレーション開始/停止ボタン
            Button(action: {
                if isVibrating {
                    VibrationManager.shared.stopRepeatingVibration()
                } else {
                    VibrationManager.shared.startRepeatingVibration(interval: 1.0) // 1秒間隔
                }
                isVibrating.toggle()
            }) {
                Text(isVibrating ? "Stop Vibration" : "Start Repeating Vibration")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isVibrating ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}


class AlarmManager: ObservableObject {
    static let shared = AlarmManager()
    private var player: AVAudioPlayer?

    // アラーム音を再生
    func startAlarmSound() {
        guard let url = Bundle.main.url(forResource: "alarm_sound", withExtension: "mp3") else { return }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // 無限ループ
            player?.play()
        } catch {
            print("Error playing alarm sound: \(error)")
        }
    }

    // アラーム音を停止
    func stopAlarmSound() {
        player?.stop()
    }

    // ローカル通知をスケジュール
    func scheduleAlarm(at date: Date) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Wake Up!"
                content.body = "It's time to get up!"
                content.sound = UNNotificationSound.default

                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.hour, .minute, .second], from: date),
                    repeats: false
                )

                let request = UNNotificationRequest(
                    identifier: "ALARM_NOTIFICATION",
                    content: content,
                    trigger: trigger
                )

                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    }
                }
            } else {
                print("Notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

import SwiftUI

struct AlarmView: View {
    @State private var alarmTime = Date()

    var body: some View {
        VStack {
            Text("Set Alarm")
                .font(.largeTitle)
                .padding()

            DatePicker("Select Time", selection: $alarmTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()

            Button(action: {
                AlarmManager.shared.scheduleAlarm(at: alarmTime)
                print("Alarm set for \(alarmTime)")
            }) {
                Text("Set Alarm")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}


final class AlarmScheduler: ObservableObject {

    private var timer: Timer?
    private let notificationCenter = UNUserNotificationCenter.current()

    /// アラーム（タイマー）を開始する
    func startAlarm() {
        // 既存の通知をクリアする（必要に応じて）
        notificationCenter.removeAllPendingNotificationRequests()

        // 4秒ごとに次の通知をスケジュールするタイマーを作成
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] _ in
            self?.scheduleNextNotification()
        }
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
        print("アラーム開始")
    }

    /// アラーム（タイマー）を停止する
    func stopAlarm() {
        timer?.invalidate()
        timer = nil
        notificationCenter.removeAllPendingNotificationRequests()
        print("アラーム停止")
    }

    /// 1回限りの通知をスケジュールする
    private func scheduleNextNotification() {
        let content = UNMutableNotificationContent()
        content.title = "アラーム通知"
        content.body = "通知発火時刻: \(Date())"
        content.sound = .default

        // ここでは、1秒後に発火する通知を設定
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // 識別子は UUID を利用してユニークに
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("通知スケジュールエラー: \(error.localizedDescription)")
            } else {
                print("通知をスケジュールしました")
            }
        }
    }
}
