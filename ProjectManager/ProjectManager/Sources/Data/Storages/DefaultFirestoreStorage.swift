import Foundation
import RxSwift
import Firebase

final class DefaultFirestoreStorage: FirestoreStorage {
    private let database = Firestore.firestore()
    
    func create(_ item: Project) -> Completable {
        return Completable.create { completable in
            self.database.collection("project").document(item.id.uuidString).setData(item.dictionary) { error in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }

    func delete(_ item: Project) -> Completable {
        return Completable.create { completable in
            self.database.collection("project").document(item.id.uuidString).delete { error in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
    
    func fetch() -> Single<[Project]> {
        return Single.create { single in
            self.database.collection("project").getDocuments { querySnapshot, error in
                if let error = error {
                    single(.failure(error))
                } else {
                    guard let querySnapshot = querySnapshot else {
                        single(.success([]))
                        return
                    }
                    let projects = querySnapshot.documents.compactMap { Project(data: $0.data()) }
                    single(.success(projects))
                }
            }
            return Disposables.create()
        }
    }
}

extension Project {
    init?(data: [String: Any]) {
        guard let id = data["id"] as? String,
              let uuid = UUID(uuidString: id),
              let title = data["title"] as? String,
              let body = data["body"] as? String,
              let date = data["date"] as? Timestamp,
              let state = data["status"] as? Int,
              let status = ProjectState(rawValue: state)
        else {
            return nil
        }
        self.id = uuid
        self.title = title
        self.description = body
        self.date = date.dateValue()
        self.status = status
    }
}
