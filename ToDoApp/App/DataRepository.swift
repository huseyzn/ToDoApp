//
//  CoreDataManager.swift
//  ToDoApp
//
//  Created by Huseyin Jafarli on 30.08.25.
//

import Foundation
import CoreData
import Firebase
import FirebaseAuth

class DataRepository {
    static let shared = DataRepository()
    
    private init(){}
    
    let db = Firestore.firestore()
    
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
                print("Context saved successfully")
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    func createToDoItem(name: String) -> ToDoAppItem {
        let uid = Auth.auth().currentUser?.uid ?? ""
        print("Creating item for user: \(uid)")
        
        let newItem = ToDoAppItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        newItem.isDone = false
        newItem.userID = uid
        
        let doc = db.collection("users").document(uid).collection("todos").document()
        newItem.itemID = doc.documentID
        
        save()
        
        doc.setData([
            "id": doc.documentID,
            "name": name,
            "createdAt": Timestamp(date: newItem.createdAt ?? Date()),
            "isDone": false
        ]) { err in
            if let err = err {
                print("Error adding document to Firebase: \(err)")
            } else {
                print("Document added to Firebase: \(doc.documentID)")
            }
        }
        
        return newItem
    }
    
    func syncFromFirebase(uid: String, completion: @escaping () -> Void) {
        print("Starting sync from Firebase for user: \(uid)")
        
        let todosRef = db.collection("users").document(uid).collection("todos")
        todosRef.getDocuments { snapshot, error in
            if let error = error {
                print("Firebase sync error: \(error)")
                completion()
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found in Firebase")
                completion()
                return
            }
            
            print("Found \(documents.count) documents in Firebase")
            
            let existingItems = self.fetchAllToDoItems(for: uid)
            print("Found \(existingItems.count) existing items in Core Data")
            
            var firebaseItemIDs = Set<String>()
            
            for doc in documents {
                let data = doc.data()
                let id = data["id"] as? String ?? doc.documentID
                let name = data["name"] as? String ?? ""
                let isDone = data["isDone"] as? Bool ?? false
                let timestamp = data["createdAt"] as? Timestamp
                let createdAt = timestamp?.dateValue() ?? Date()
                
                firebaseItemIDs.insert(id)
                
                if let existingItem = existingItems.first(where: { $0.itemID == id }) {
                    print("Updating existing item: \(name)")
                    existingItem.name = name
                    existingItem.isDone = isDone
                } else {
                    print("Creating new item: \(name)")
                    let newItem = ToDoAppItem(context: self.context)
                    newItem.itemID = id
                    newItem.name = name
                    newItem.isDone = isDone
                    newItem.createdAt = createdAt
                    newItem.userID = uid
                }
            }
            
            for item in existingItems {
                if let itemID = item.itemID, !firebaseItemIDs.contains(itemID) {
                    print("Deleting item not in Firebase: \(item.name ?? "")")
                    self.context.delete(item)
                }
            }
            
            self.save()
            print("Sync completed")
            completion()
        }
    }
    
    func existsToDoItem(name: String, createdAt: Date, itemID: String) -> Bool {
        let fetchRequest: NSFetchRequest<ToDoAppItem> = ToDoAppItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "itemID == %@", itemID)
        fetchRequest.fetchLimit = 1
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking existence: \(error)")
            return false
        }
    }
    
    func fetchAllToDoItems(for uid: String) -> [ToDoAppItem] {
        let fetchRequest: NSFetchRequest<ToDoAppItem> = ToDoAppItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userID == %@", uid)
        do {
            let items = try context.fetch(fetchRequest)
            print("Fetched \(items.count) items from Core Data")
            return items
        } catch {
            print("Error fetching data: \(error)")
            return []
        }
    }
    
    func updateToDoItem(_ item: ToDoAppItem, name: String) {
        
        let uid = Auth.auth().currentUser?.uid ?? ""
        print("Updating item: \(item.name ?? "") -> \(name)")
        
        item.name = name
        save()
        
        guard let itemID = item.itemID else {
            print("No itemID found for update")
            return
        }
        
        db.collection("users").document(uid).collection("todos").document(itemID)
            .updateData(["name": name]) { error in
                if let error = error {
                    print("Error updating Firebase: \(error)")
                } else {
                    print("Firebase updated successfully")
                }
            }
    }

    func toggleIsDone(_ item: ToDoAppItem) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        print("Toggling isDone for: \(item.name ?? "")")
        
        item.isDone.toggle()
        save()
        
        guard let itemID = item.itemID else {
            print("No itemID found for toggle")
            return
        }
        
        db.collection("users").document(uid).collection("todos").document(itemID)
            .updateData(["isDone": item.isDone]) { error in
                if let error = error {
                    print("Error updating Firebase isDone: \(error)")
                } else {
                    print("Firebase isDone updated successfully")
                }
            }
    }

    func deleteToDoItem(_ item: ToDoAppItem, completion: (() -> Void)? = nil) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        print("Deleting item: \(item.name ?? "")")
        
        guard let itemID = item.itemID else {
            print("No itemID found for deletion")
            return
        }
        
        context.delete(item)
        save()
        print("Item deleted from Core Data")
        
        db.collection("users").document(uid).collection("todos").document(itemID).delete { error in
            if let error = error {
                print("Error deleting from Firebase: \(error)")
            } else {
                print("Document successfully deleted from Firebase: \(itemID)")
                completion?()
            }
        }
    }
}
