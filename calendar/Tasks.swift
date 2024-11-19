//import SwiftUI
//
//@main
//struct TasksApp: App {
//    @StateObject private var dataController = DataController()
//
//     var body: some Scene {
//        WindowGroup {
//            TaskListView()
//                .environment(\.managedObjectContext, dataController.container.viewContext)
//        }
//     }
//}
//import SwiftUI
//import CoreData
//
//struct TaskListView: View {
//    @FetchRequest(sortDescriptors: []) var myTask: FetchedResults<MyTask>
//
//    var body: some View {
//        VStack {
//            List(myTask) { myTask in
//                Text(myTask.taskType ?? "Unknown")
//            }
//        }
//    }
//}

// プレビュー用の構造体
//struct TaskListView_Previews: PreviewProvider {
//    static var previews: some View {
//        let dataController = DataController(inMemory: true)  // In-Memoryのデータコントローラを作成
//        let viewContext = dataController.container.viewContext
//
//        // サンプルデータを追加
//        for _ in 0..<10 {
//            let newTask = MyTask(context: viewContext)
//            newTask.taskType = "Sample Task"
//        }
//
//        // プレビューでCore Dataのコンテキストを渡す
//        return TaskListView()
//            .environment(\.managedObjectContext, viewContext)
//    }
//}

// DataController.swift (In-Memoryサポートの追加)


//class DataController: ObservableObject {
//    let container: NSPersistentContainer
//
//    init(inMemory: Bool = false) {
//        container = NSPersistentContainer(name: "Tasks")
//
//        if inMemory {
//            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")  // In-Memoryのストアを使用
//        }
//
//        container.loadPersistentStores { description, error in
//            if let error = error {
//                print("Core Data failed to load: \(error.localizedDescription)")
//            }
//        }
//    }
//}
