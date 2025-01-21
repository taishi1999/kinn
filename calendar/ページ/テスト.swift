import SwiftUI
import DeviceActivity

import UserNotifications

//class MyMonitorExtension: DeviceActivityMonitor {
//    let notificationManager = LocalNotificationManager.shared
//
//    override func intervalDidStart(for activity: DeviceActivityName) {
//        super.intervalDidStart(for: activity)
//
//        if activity == .daily {
//            print("intervalDidStart: \(activity.rawValue)")
//
//            // ローカル通知を発火
//            LocalNotificationManager.shared.sendNotification(
//                title: "スケジュール開始",
//                body: "デバイスアクティビティモニターが発火しました。"
//            )
//        }
//    }
//}
//-----------------
//import DeviceActivity
//import UserNotifications
//
//
//// Optionally override any of the functions below.
//// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
//class DeviceActivityMonitorExtension: DeviceActivityMonitor {
//
//    func scheduleNotification(with title: String) {
//        let center = UNUserNotificationCenter.current()
//        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if granted {
//                let content = UNMutableNotificationContent()
//                content.title = title // Using the custom title here
//                content.body = "Here is the body text of the notification."
//                content.sound = UNNotificationSound.default
//
//                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // 5 seconds from now
//
//                let request = UNNotificationRequest(identifier: "MyNotification", content: content, trigger: trigger)
//
//                center.add(request) { error in
//                    if let error = error {
//                        print("Error scheduling notification: \(error)")
//                    }
//                }
//            } else {
//                print("Permission denied. \(error?.localizedDescription ?? "")")
//            }
//        }
//    }
//
//    override func intervalDidStart(for activity: DeviceActivityName) {
//        super.intervalDidStart(for: activity)
//
//        // Handle the start of the interval.
//        print("Interval began")
//        scheduleNotification(with: "interval did start")
//    }
//
//    override func intervalDidEnd(for activity: DeviceActivityName) {
//        super.intervalDidEnd(for: activity)
//
//        // Handle the end of the interval.
//        print("Interval ended")
//        scheduleNotification(with: "interval did end")
//    }
//
//    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
//        super.eventDidReachThreshold(event, activity: activity)
//
//        // Handle the event reaching its threshold.
//        print("Threshold reached")
//        scheduleNotification(with: "event did reach threshold warning")
//    }
//
//    override func intervalWillStartWarning(for activity: DeviceActivityName) {
//        super.intervalWillStartWarning(for: activity)
//
//        // Handle the warning before the interval starts.
//        print("Interval will start")
//        scheduleNotification(with: "interval will start warning")
//    }
//
//    override func intervalWillEndWarning(for activity: DeviceActivityName) {
//        super.intervalWillEndWarning(for: activity)
//
//        // Handle the warning before the interval ends.
//        print("Interval will end")
//        scheduleNotification(with: "interval will end warning")
//    }
//
//    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
//        super.eventWillReachThresholdWarning(event, activity: activity)
//
//        // Handle the warning before the event reaches its threshold.
//        print("Interval will reach threshold")
//        scheduleNotification(with: "event will reach threshold warning")
//    }
//}

import SwiftUI
import FamilyControls
import DeviceActivity
import Combine

let schedule = DeviceActivitySchedule(
    intervalStart: DateComponents(hour: 7, minute: 31, second: 0),
    intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
    repeats: true,
    warningTime: DateComponents(minute: 14)
)

func description(for selection: FamilyActivitySelection) -> String {
    var result = "Include Entire Category: \(selection.includeEntireCategory ? "Yes" : "No")\n"
    result += "Application Tokens: \(selection.applicationTokens.count)\n"
    result += "Category Tokens: \(selection.categoryTokens.count)\n"
    result += "Web Domain Tokens: \(selection.webDomainTokens.count)"
    return result
}

class ActivitySelectionModel: ObservableObject {
    @Published var activitySelection = FamilyActivitySelection()
    private var cancellables = Set<AnyCancellable>()

    // Used to encode and decode codable to UserDefaults
    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()
    private let userDefaultsKey = "ScreenTimeSelection"

    init() {
        activitySelection = savedSelection() ?? FamilyActivitySelection()

        $activitySelection
            .sink { [weak self] selection in
                self?.saveSelection(selection: selection)
            }
            .store(in: &cancellables)
    }

    func saveSelection(selection: FamilyActivitySelection) {
        let defaults = UserDefaults.standard
        defaults.set(
            try? encoder.encode(selection),
            forKey: userDefaultsKey
        )
    }

    func savedSelection() -> FamilyActivitySelection? {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: userDefaultsKey) else {
            return nil
        }
        return try? decoder.decode(
            FamilyActivitySelection.self,
            from: data
        )
    }
}

struct ActivitySelectionView: View {
    @State private var pickerIsPresented = false
    @StateObject private var model = ActivitySelectionModel()

    var body: some View {
        VStack {
            Button("Select Apps") {
                pickerIsPresented = true
            }
            .familyActivityPicker(
                isPresented: $pickerIsPresented,
                selection: $model.activitySelection
            )
            Text("Selected Activities: \(description(for: model.activitySelection))")
        }
        .onAppear {
            requestAuthorization()
            setupDeviceActivityMonitoring()
        }
    }

    private func requestAuthorization() {
        Task {
            let ac = AuthorizationCenter.shared
            do {
                try await ac.requestAuthorization(for: .individual)
            } catch {
                print("Error getting auth for Family Controls")
            }
        }
    }

    private func setupDeviceActivityMonitoring() {
        guard let selection = model.savedSelection() else {
            print("No saved selection found")
            return
        }

        let event = DeviceActivityEvent(
            applications: selection.applicationTokens,
            categories: selection.categoryTokens,
            webDomains: selection.webDomainTokens,
            threshold: DateComponents(minute: 15)
        )

        print("Event is", event)
        print("Event applications", event.applications)
        print("Schedule is", schedule)

        let center = DeviceActivityCenter()
        center.stopMonitoring()

        let activity = DeviceActivityName("MyApp.ScreenTime")
        let eventName = DeviceActivityEvent.Name("MyApp.SomeEventName")

        print("Starting monitoring")

        do {
            try center.startMonitoring(
                activity,
                during: schedule,
                events: [
                    eventName: event
                ]
            )
        } catch {
            print("Error starting monitoring")
        }
    }
}



//------------------

struct LocalNotificationView: View {
    var body: some View {
        VStack {
            Button("通知の許可をリクエスト") {
                LocalNotificationManager.shared.requestAuthorization { granted in
                    print(granted ? "通知が許可されました" : "通知が拒否されました")
                }
            }
            .buttonStyle(.borderedProminent)

            Button("通知を送信") {
                LocalNotificationManager.shared.sendNotification(
                    title: "外部通知",
                    body: "これは外部から使用できる通知です。"
                )
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}



struct LocalNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        LocalNotificationView()
    }
}

//-------------------------

// メインビュー
struct NavigationPathExample: View {
    @State private var path = NavigationPath() // NavigationPathを定義

    var body: some View {
        NavigationStack(path: $path) {
            ScreenA(path: $path) // A画面
                .navigationDestination(for: String.self) { destination in
                    switch destination {
                    case "B":
                        ScreenB(path: $path) // B画面
                    case "C":
                        ScreenC(path: $path) // C画面
                    case "D":
                        ScreenD(path: $path) // D画面
                    default:
                        EmptyView()
                    }
                }
        }
    }
}

// A画面
struct ScreenA: View {
    @Binding var path: NavigationPath

    var body: some View {
        VStack {
            Text("This is A")
                .font(.largeTitle)
                .padding()

            Button("Go to B") {
                path.append("B") // 次の画面へ遷移
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("A")
    }
}

// B画面
struct ScreenB: View {
    @Binding var path: NavigationPath

    var body: some View {
        VStack {
            Text("This is B")
                .font(.largeTitle)
                .padding()

            Button("Go to C") {
                path.append("C") // 次の画面へ遷移
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("B")
    }
}

// C画面
struct ScreenC: View {
    @Binding var path: NavigationPath

    var body: some View {
        VStack {
            Text("This is C")
                .font(.largeTitle)
                .padding()

            Button("Go to D") {
                path.append("D") // 次の画面へ遷移
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("C")
    }
}

// D画面
struct ScreenD: View {
    @Binding var path: NavigationPath

    var body: some View {
        VStack {
            Text("This is D")
                .font(.largeTitle)
                .padding()

            Button("Go Back to Root") {
                path.removeLast(path.count) // ルートビューに戻る
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("D")
    }
}

// プレビュー
//struct NavigationPathExample_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationPathExample()
//    }
//}
import SwiftUI

struct TextInputWithLimitView: View {
    @State private var text: String = "10"
    let characterLimit = 4 // 文字数制限
    let focusOnAppear = true // 初期化時にフォーカスするかどうか

    var body: some View {
        VStack {
            HStack{
                CharacterCountTextField(
                    text: $text,
                    characterLimit: characterLimit,
                    focusOnAppear: focusOnAppear
                )
                .frame(width: 24) // 横幅を固定
    //            .frame(height: 40)
    //            .padding()
                Text("文字")
            }


            Button(action: {
                print("Submitted text: \(text)")
            }) {
                Text("Submit")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(text.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(text.isEmpty)
            .padding()
        }
        .padding()
    }
}

struct TextInputWithLimitView_Previews: PreviewProvider {
    static var previews: some View {
        TextInputWithLimitView()
    }
}

