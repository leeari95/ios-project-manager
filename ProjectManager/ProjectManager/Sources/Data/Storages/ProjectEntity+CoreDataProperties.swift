import Foundation
import CoreData

extension ProjectEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProjectEntity> {
        return NSFetchRequest<ProjectEntity>(entityName: "ProjectEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var date: Date?
    @NSManaged public var status: Int16

}

extension ProjectEntity : Identifiable {

}
