import Foundation
import RxSwift

final class DefaultProjectStorage {
    private(set) var projects: [Project] {
        didSet {
            projectStore.onNext(projects)
        }
    }
    private let projectStore: BehaviorSubject<[Project]>
    
    init(
        projects: [Project] = CoreDataStorage.shared.setup(),
        projectStore: BehaviorSubject<[Project]> = BehaviorSubject<[Project]>(value: CoreDataStorage.shared.setup())
    ) {
        self.projects = projects
        self.projectStore = projectStore
    }
}

extension DefaultProjectStorage: ProjectStorage {
    func create(_ item: Project) -> Single<Project> {
        let items: [String: Any] = [
            "id": item.id,
            "title": item.title,
            "body": item.description,
            "date": item.date,
            "status": item.status.rawValue
        ]
        CoreDataStorage.shared.insert(items: items)
        projects.append(item)
        return Single.just(item)
    }
    
    func update(_ item: Project?) -> Single<Project> {
        guard let item = item,
              let index = projects.firstIndex(where: { $0 == item }) else {
            return Single.create { observer in
                observer(.failure(StorageError.notFound))
                return Disposables.create()
            }
        }
        let items: [String: Any] = [
            "id": item.id,
            "title": item.title,
            "body": item.description,
            "date": item.date,
            "status": item.status.rawValue
        ]
        CoreDataStorage.shared.updateProject(items: items)
        projects[index] = item
        return Single.create { observer in
            observer(.success(item))
            return Disposables.create()
        }
    }
    
    func delete(_ item: Project?) -> Single<Project> {
        guard let item = item,
              let index = projects.firstIndex(where: { $0 == item }),
              let project = CoreDataStorage.shared.fetch(
                predicate: NSPredicate(format: "id == %@", item.id as CVarArg)
              )?.first else {
            return Single.create { observer in
                observer(.failure(StorageError.notFound))
                return Disposables.create()
            }
        }
        CoreDataStorage.shared.delete(project)
        projects.remove(at: index)
        return Single.create { observer in
            observer(.success(item))
            return Disposables.create()
        }
    }
    
    func fetch() -> BehaviorSubject<[Project]> {
        return projectStore
    }
    
    func fetch(id: UUID) -> Single<Project> {
        return Single.create { observer in
            guard let project = self.projects.first(where: { $0.id == id }) else {
                observer(.failure(StorageError.notFound))
                return Disposables.create()
            }
            observer(.success(project))
            return Disposables.create()
        }
    }
}

enum StorageError: LocalizedError {
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "존재하지 않는 Project 입니다."
        }
    }
}
