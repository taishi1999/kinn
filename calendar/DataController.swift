//
//  DataController.swift
//  calendar
//
//  Created by 唐崎大志 on 2024/09/22.
//

//import CoreData
//import Foundation
//
//class DataController: ObservableObject {
//    let container: NSPersistentContainer
//
//    init(inMemory: Bool = false) {
//        container = NSPersistentContainer(name: "Tasks")
//
//        if inMemory {
//            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")  // In-Memoryストアを使用
//        }
//
//        container.loadPersistentStores { description, error in
//            if let error = error {
//                print("Core Data failed to load: \(error.localizedDescription)")
//            }
//        }
//    }
//}

import CoreData
import Foundation

class DataController: ObservableObject {
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Tasks")  // モデル名が正しいことを確認

        if inMemory {
            // In-Memoryストアの設定（メモリ上のみにデータを保存する）
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
