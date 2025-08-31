//
//  CoreDataManager.swift
//  ToDoApp
//
//  Created by Huseyin Jafarli on 30.08.25.
//

import Foundation
import CoreData
class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init(){}
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoApp")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data Error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
                print("Context saved.")
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    func createToDoItem(name: String) -> ToDoAppItem {
        let newItem = ToDoAppItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        newItem.isDone = false
        save()
        print("Created Succesfully - Items count: \(fetchAllToDoItems().count)")
        return newItem
    }
    
    func fetchAllToDoItems() -> [ToDoAppItem] {
        let fetchRequest: NSFetchRequest<ToDoAppItem> = ToDoAppItem.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching data: \(error)")
            return []
        }
    }
    
    func deleteToDoItem(_ item: ToDoAppItem) {
        context.delete(item)
        save()
        print("Deleted Succesfully")
    }
    
    func updateToDoItem(_ item: ToDoAppItem, name: String) {
        item.name = name
        item.createdAt = Date()
        save()
        print("Updated Succesfully")
    }
    
    func toggleIsDone(_ item: ToDoAppItem) {
        item.isDone.toggle()
        save()
        print("Toggle updated Succesfully")
    }
    
}
