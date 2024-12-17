import Foundation
import AVFoundation
import UserNotifications
import SwiftUI
import AudioToolbox


import SwiftUI
import UserNotifications

struct 通知スケジュールビュー: View {
    var body: some View {
        VStack {
            Button("10:00にローカル通知をスケジュール") {
                scheduleNotifications(atHour: 13, minute: 20, count: 64, intervalMinutes: 1)
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

// ローカル通知をスケジュール
func scheduleNotifications(atHour hour: Int, minute: Int, count: Int, intervalMinutes: Int) {
    let center = UNUserNotificationCenter.current()
    let calendar = Calendar.current

    // 現在の日付を基準に初回通知の時間を計算
    let now = Date()
    var startDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now)!

    // 目標時刻が現在時刻より前の場合、翌日を設定
    if startDate < now {
        startDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
    }

    for i in 0..<count {
        // 通知時刻を計算
        let notificationDate = calendar.date(byAdding: .minute, value: i * intervalMinutes, to: startDate)!

        // 通知内容を作成
        let content = UNMutableNotificationContent()
        content.title = "通知 \(i + 1)"
        content.body = "\(calendar.component(.hour, from: notificationDate))時\(calendar.component(.minute, from: notificationDate))分の通知です。"
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
