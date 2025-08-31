//
//  ToDoAppItem+CoreDataProperties.swift
//  ToDoApp
//
//  Created by Huseyin Jafarli on 30.08.25.
//
//

import Foundation
import CoreData


extension ToDoAppItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoAppItem> {
        return NSFetchRequest<ToDoAppItem>(entityName: "ToDoAppItem")
    }

    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?

}

extension ToDoAppItem : Identifiable {

}
