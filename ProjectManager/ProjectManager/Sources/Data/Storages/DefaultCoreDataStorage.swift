import Foundation
import CoreData

final class DefaultCoreDataStorage {
    static let shared = DefaultCoreDataStorage()
    private init() {}
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
            let container = NSPersistentCloudKitContainer(name: "ProjectEntity")
            container.loadPersistentStores(completionHandler: { (_, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
        
        func saveContext() {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    
    func setup() -> [Project] {
        guard let data = fetch() else {
            return []
        }
        var projects = [Project]()
        data.forEach { projectEntity in
            let project = Project(
                id: projectEntity.id,
                title: projectEntity.title ?? "",
                description: projectEntity.body ?? "",
                date: projectEntity.date ?? Date(),
                status: ProjectState(rawValue: Int(projectEntity.status)) ?? .todo
            )
            projects.append(project)
        }
        return projects
    }
}

// MARK: - CRUD
extension DefaultCoreDataStorage {
    func insert(entityName: String = "ProjectEntity", items: [String: Any]) {
        let context = persistentContainer.viewContext
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        update(managedObject, items: items)
    }
    
    @discardableResult
    func fetch(
        entityName: String = "ProjectEntity",
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: "date", ascending: false)]
    ) -> [ProjectEntity]? {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = sortDescriptors
        guard let newData = try? context.fetch(request) as? [ProjectEntity] else {
            return nil
        }
        return newData
    }
    
    private func update(_ managedObject: NSManagedObject, items: [String: Any]) {
        let keys = managedObject.entity.attributesByName.keys
        for key in keys {
            if let value = items[key] {
                managedObject.setValue(value, forKey: key)
            }
        }
        saveContext()
    }
    
    func delete(_ item: ProjectEntity) {
        let context = persistentContainer.viewContext
        let project = item as NSManagedObject
        context.delete(project)
        saveContext()
    }

    func updateProject(
        entityName: String = "ProjectEntity",
        items: [String: Any]
    ) {
        items["id"]
            .flatMap { $0 as? UUID as CVarArg? }
            .flatMap { fetch(entityName: entityName, predicate: NSPredicate(format: "id == %@", $0))?.first }
            .flatMap { $0 as NSManagedObject }
            .flatMap { update($0, items: items) }
    }
}
