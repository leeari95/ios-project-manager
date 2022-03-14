import Foundation
import RxSwift
import RxRelay

final class DetailViewModel {
    enum ViewMode {
        case add
        case read
        case edit
    }
    
    private var mode: ViewMode
    private var project: Project
    private let coordinator: DetailCoordinator
    private let useCase: ProjectListUseCase
    
    init(useCase: ProjectListUseCase, coordinator: DetailCoordinator, project: Project, mode: ViewMode) {
        self.useCase = useCase
        self.coordinator = coordinator
        self.project = project
        self.mode = mode
    }
    
    struct Input {
        let didTapRightBarButton: Observable<Void>
        let didTapLeftBarButton: Observable<Void>
        let didChangeTitleText: Observable<String?>
        let didChangeDatePicker: Observable<Date>
        let didChangeDescription: Observable<String?>
    }
    
    struct Output {
        let projectTitle: Observable<String>
        let projectDate: Observable<Date>
        let projectDescription: Observable<String>
        let isEditable: Observable<Bool>
        let leftBarButtonText: Observable<String>
        let navigationTitle: Observable<String>
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let isEditable = BehaviorRelay<Bool>(value: mode == .add ? true : false)
        let currentTitle = BehaviorRelay<String?>(value: nil)
        let currentDate = BehaviorRelay<Date?>(value: nil)
        let currentDescription = BehaviorRelay<String?>(value: nil)
        
        input.didChangeTitleText
            .subscribe(onNext: { title in
                currentTitle.accept(title)
            }).disposed(by: disposeBag)
        
        input.didChangeDatePicker
            .subscribe(onNext: { date in
                currentDate.accept(date)
            }).disposed(by: disposeBag)
        
        input.didChangeDescription
            .subscribe(onNext: { description in
                currentDescription.accept(description)
            }).disposed(by: disposeBag)
        
        input.didTapRightBarButton
            .subscribe(onNext: { _ in
                if isEditable.value {
                    let newProject = Project(
                        id: self.project.id,
                        title: currentTitle.value ?? self.project.title,
                        description: currentDescription.value ?? self.project.description,
                        date: currentDate.value ?? self.project.date,
                        status: self.project.status
                    )
                    let single = self.mode == .edit ? self.useCase.update(newProject) : self.useCase.create(newProject)
                    single.subscribe(onSuccess: { project in
                        self.project = project
                    }, onFailure: { error in
                        print(error.localizedDescription)
                    }).disposed(by: disposeBag)
                }
                self.coordinator.dismiss()
            }).disposed(by: disposeBag)
        
        input.didTapLeftBarButton
            .subscribe(onNext: { _ in
                switch self.mode {
                case .read:
                    self.mode = .edit
                    isEditable.accept(true)
                case .add:
                    self.coordinator.dismiss()
                case .edit:
                    self.mode = .read
                    isEditable.accept(false)
                }
            }).disposed(by: disposeBag)
        
        let output = Output(
            projectTitle: Observable.just(project.title),
            projectDate: Observable.just(project.date),
            projectDescription: Observable.just(project.description),
            isEditable: isEditable.asObservable(),
            leftBarButtonText: mode == .add ? Observable.just("Cancel") : Observable.just("Edit"),
            navigationTitle: Observable.just(project.status.rawValue)
        )
        
        return output
    }
}
