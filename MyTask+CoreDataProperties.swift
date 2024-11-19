//
//  MyTask+CoreDataProperties.swift
//  calendar
//
//  Created by 唐崎大志 on 2024/09/26.
//
//

import Foundation
import CoreData


extension MyTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyTask> {
        return NSFetchRequest<MyTask>(entityName: "MyTask")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var endTime: Date
    @NSManaged public var isCompleted: Bool
    @NSManaged public var repeatDays: String?
    @NSManaged public var startTime: Date
    @NSManaged public var taskType: String?
    @NSManaged public var characterCount: Int16

}

extension MyTask : Identifiable {

}
