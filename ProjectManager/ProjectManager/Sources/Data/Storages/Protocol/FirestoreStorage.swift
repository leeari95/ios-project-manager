import Foundation
import RxSwift

protocol FirestoreStorage {
    @discardableResult
    func create(_ item: Project) -> Completable
    @discardableResult
    func delete(_ item: Project) -> Completable
    func fetch() -> Single<[Project]>
}
