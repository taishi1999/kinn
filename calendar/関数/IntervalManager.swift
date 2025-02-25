//import Foundation
//import Combine
//
//class IntervalManager: ObservableObject {
//    @Published var interval: TimeInterval = 0
//    @Published var nextEventLabel: String = "none"
//    private var timer: Timer?
//    private let diaryTaskManager = DiaryTaskManager.shared
//
//    init() {
//        startUpdatingInterval()
//    }
//
//    /// `interval` を 1 秒ごとに更新
//    private func startUpdatingInterval() {
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            if let (eventDate, eventLabel) = self.diaryTaskManager.findNextEvent() {
//                self.nextEventLabel = eventLabel
//                self.interval = max(0, eventDate.timeIntervalSinceNow)
//            } else {
//                self.nextEventLabel = "none"
//                self.interval = 0
//            }
//        }
//    }
//
//    /// 停止する
//    func stopUpdatingInterval() {
//        timer?.invalidate()
//    }
//
//    deinit {
//        stopUpdatingInterval()
//    }
//}
