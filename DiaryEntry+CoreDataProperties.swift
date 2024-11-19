//
//  DiaryEntry+CoreDataProperties.swift
//  calendar
//
//  Created by 唐崎大志 on 2024/10/17.
//
//

import Foundation
import CoreData


extension DiaryEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiaryEntry> {
        return NSFetchRequest<DiaryEntry>(entityName: "DiaryEntry")
    }

    @NSManaged public var body: String?
    @NSManaged public var createdAt: Date?
}

extension DiaryEntry : Identifiable {

}
