import SwiftUI

struct パーツ_ボタン_タスク: View {
    @State private var progress: Double = 0.3
    @Binding var taskType: String // taskTypeをバインディングとして渡す
    @Binding var startTime: Date // startTimeをバインディングとして渡す
    @Binding var endTime: Date // endTimeをバインディングとして渡す
    @Binding var repeatDays: String // repeatDaysをバインディングとして渡す
    @Binding var isCompleted: Bool // isCompletedをバインディングとして渡す
    @Binding var characterCount: Int16 // characterCountをバインディングとして渡す

    var body: some View {
        VStack(spacing: 8) {
            // 時間
            HStack(spacing: 4) {
                Text(dateFormatter.string(from: startTime)) // startTimeを表示
                    .font(.callout)
                    .fontWeight(.semibold)
                Text("-").foregroundColor(.secondary)
                Text(dateFormatter.string(from: endTime)) // endTimeを表示
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // タスク
            VStack(spacing: 8) {
                HStack(alignment: .center) {
                    Text(taskTitle(for: taskType))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)

                    Spacer()

                    VStack {
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.primary.opacity(0.3))
                            .font(.system(size: 16)) // アイコンのサイズを小さくする
                            .frame(width: 24, height: 24)
                    }
                }

                // 進捗
                VStack(spacing: 4) {
                    // taskTypeがDiaryの場合の進捗表示
                    if taskType == "Diary" {
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            HStack(spacing:0){
                                Text("\(10000)") // characterCountを表示
                                    .font(.system(size: 28, design: .rounded))
                                    .fontWeight(.bold)

                                Text("/\(characterCount)") // characterCountを表示
                                    .font(.system(size: 28, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                            }
                            Text("文字") // "文字"の部分をCalloutフォントで表示
                                .font(.system(size: 16, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)

                            Spacer()
                        }
                        ProgressView(value: progress)
                            .tint(Color.primary)
                    }

                    // taskTypeがTimerの場合の時間表示
                    if taskType == "Timer" {
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text(timeIntervalString(from: startTime, to: endTime)) // 時間、分、秒を表示
                                .font(.system(size: 28, design: .rounded))
                                .fontWeight(.bold)

                            Spacer()
                        }
                        ProgressView(value: progress)
                            .tint(Color.primary)
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
            .padding(.horizontal, 16)
            .background(Color.darkButton_normal) // 背景色
            .cornerRadius(20) // 角丸
        }
        .padding(.horizontal, 16) // 外側のパディング
    }

    // taskTypeに応じて表示するテキストを切り替える関数
    private func taskTitle(for taskType: String) -> String {
        switch taskType {
        case "Diary":
            return TaskTitle.diary.rawValue
        case "Timer":
            return TaskTitle.timer.rawValue
        default:
            return taskType // デフォルトで元のtaskTypeを表示
        }
    }

    // DateFormatterの設定
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }

    // startTimeとendTimeの差を00:00:00形式で表示する関数
    private func timeIntervalString(from startTime: Date, to endTime: Date) -> String {
        let interval = endTime.timeIntervalSince(startTime)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
//struct パーツ_ボタン_タスク_Previews: PreviewProvider {
//    static var previews: some View {
//        パーツ_ボタン_タスク()
//    }
//}
