import SwiftUI
import CoreData

class TaskDataController: ObservableObject {
    private var viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    func deleteAllTasks() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MyTask.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()  // 削除を保存して確定
            print("All tasks deleted successfully!")
        } catch {
            print("Failed to delete tasks: \(error.localizedDescription)")
        }
    }
}
