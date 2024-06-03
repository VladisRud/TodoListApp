//
//  StorageManager.swift
//  TodoListApp
//
//  Created by Влад Руденко on 01.06.2024.
//

import Foundation
import CoreData

class StorageManager {
    
    static let delegate = StorageManager()
    
    private let context: NSManagedObjectContext
    
    private init() {
        context = persistentContainer.viewContext
    }
    
    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodoListApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - Create
    func create(taskWithName taskName: String) -> TodoTask {
        let task = TodoTask(context: context)
        task.title = taskName
        saveContext()
        return task
    }
    
    //MARK: - Fetch (Read)
    func fetchData(completion: (Result<[TodoTask], Error>) -> Void) {
        let fetchRequest = TodoTask.fetchRequest()
        
        do {
            let taskList = try context.fetch(fetchRequest)
            completion(.success(taskList))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    //MARK: - Update
    func update(task: TodoTask, withNewName taskName: String) {
        task.title = taskName
        saveContext()
    }
    
    //MARK: - Delete
    func delete(task: TodoTask) {
        context.delete(task)
        saveContext()
    }
    
}
