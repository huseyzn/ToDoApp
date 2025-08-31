//
//  ToDoAppItem+CoreDataProperties.swift
//  ToDoApp
//
//  Created by Huseyin Jafarli on 31.08.25.
//
//

import Foundation
import CoreData


extension ToDoAppItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoAppItem> {
        return NSFetchRequest<ToDoAppItem>(entityName: "ToDoAppItem")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var isDone: Bool
    @NSManaged public var name: String?

}

extension ToDoAppItem : Identifiable {

}
