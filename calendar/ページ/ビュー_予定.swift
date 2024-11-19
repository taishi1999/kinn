import SwiftUI

struct ビュー_予定: View {
    var tasks: FetchedResults<MyTask> // FetchedResultsを受け取る

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 32) { // LazyVStackのspacingを指定
                // tasksの要素に基づいてパーツ_ボタン_タスクを表示
                ForEach(tasks, id: \.self) { task in
                    if let taskType = task.taskType,
                       let repeatDays = task.repeatDays {
                        // 各パラメータを渡してパーツ_ボタン_タスクを表示
                        パーツ_ボタン_タスク(
                            taskType: .constant(taskType),
                            startTime: .constant(task.startTime), // 直接使用
                            endTime: .constant(task.endTime),     // 直接使用
                            repeatDays: .constant(repeatDays),
                            isCompleted: .constant(task.isCompleted),
                            characterCount: .constant(task.characterCount)
                        )
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}


//struct ビュー_予定: View {
//    var tasks: FetchedResults<MyTask>
//    
//    var body: some View {
//        VStack(spacing:32){
//            パーツ_ボタン_タスク(taskType:task)
//            パーツ_ボタン_タスク()
//        }
//        
////        List(tasks) { task in
////            VStack(alignment: .leading) {
////
////                
////                Text(task.taskType ?? "Unknown Task")
////                if task.taskType == "Diary" {
////                    Text("Character Count: \(task.characterCount)")
////                }
////                Text("Completed: \(task.isCompleted ? "Yes" : "No")")
////                Text("Start Time: \(task.startTime?.description ?? "Unknown")")
////                Text("End Time: \(task.endTime?.description ?? "Unknown")")
////                Text("Repeat Days: \(task.repeatDays ?? "None")")
////                Text("createdAt: \(task.createdAt?.description ?? "Unknown")")
////
////
////            }
////        }
////        ScrollView {
////            VStack(spacing: 24) {
////                ForEach(0..<4) { index in
////                    Text("Item \(index)")
////                        .frame(maxWidth: .infinity)
////                        .padding()
////                        .background(Color.gray.opacity(0.2))
////                        .cornerRadius(10)
////                }
////            }
////            .padding(.horizontal, 14)
////        }
//    }
//}

//struct ビュー_予定_Previews: PreviewProvider {
//    static var previews: some View {
//        ビュー_予定()
//    }
//}
