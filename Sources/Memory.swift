import CloudKit
import Combine

#if DEBUG
    private let URL = "avocado.debug.archive".file
#else
    private let URL = "avocado.archive".file
#endif

public struct Memory {
    private static let container = CKContainer(identifier: "iCloud.avoca.do")
    public static internal(set) var shared = Memory()
    public let archive = PassthroughSubject<Archive, Never>()
    public let save = PassthroughSubject<Archive, Never>()
    public let pull = PassthroughSubject<Void, Never>()
    var subs = Set<AnyCancellable>()
    private let local = PassthroughSubject<Archive?, Never>()
    private let queue = DispatchQueue(label: "", qos: .utility)
    
    init() {
        let push = PassthroughSubject<Void, Never>()
        let store = PassthroughSubject<Archive, Never>()
        let remote = PassthroughSubject<Archive?, Never>()
        let record = CurrentValueSubject<CKRecord.ID?, Never>(nil)
        let type = "Archive"
        let asset = "asset"
        
        save
            .subscribe(store)
            .store(in: &subs)
        
        save
            .removeDuplicates {
                $0 >= $1
            }
            .map { _ in }
            .subscribe(push)
            .store(in: &subs)
        
        local
            .compactMap {
                $0
            }
            .merge(with: remote
                            .compactMap {
                                $0
                            }
                            .map {
                                ($0, $0.date(.archive))
                            }
                            .merge(with: save
                                    .map { _ in
                                        (nil, .init())
                                    })
                            .removeDuplicates {
                                $0.1 >= $1.1
                            }
                            .compactMap {
                                $0.0
                            })
            .removeDuplicates {
                $0 >= $1
            }
            .receive(on: DispatchQueue.main)
            .subscribe(archive)
            .store(in: &subs)
        
        pull
            .merge(with: push)
            .combineLatest(record)
            .filter {
                $1 == nil
            }
            .map { _, _ in }
            .sink {
                Self.container.accountStatus { status, _ in
                    if status == .available {
                        Self.container.fetchUserRecordID { user, _ in
                            user.map {
                                record.send(.init(recordName: "archive_" + $0.recordName))
                            }
                        }
                    }
                }
            }
            .store(in: &subs)
        
        record
            .compactMap {
                $0
            }
            .combineLatest(pull)
            .map {
                ($0.0, Date())
            }
            .removeDuplicates {
                NSLog("\(Calendar.current.dateComponents([.second], from: $0.1, to: $1.1).second!)")
                return Calendar.current.dateComponents([.second], from: $0.1, to: $1.1).second! < 2
            }
            .map {
                $0.0
            }
            .sink {
                NSLog("[kanban] pull operation")
                let operation = CKFetchRecordsOperation(recordIDs: [$0])
                operation.qualityOfService = .userInitiated
                operation.configuration.timeoutIntervalForRequest = 20
                operation.configuration.timeoutIntervalForResource = 20
                operation.fetchRecordsCompletionBlock = { records, _ in
                    NSLog("[kanban] pull received")
                    remote.send(records?.values.first.flatMap {
                        ($0[asset] as? CKAsset).flatMap {
                            $0.fileURL.flatMap {
                                (try? Data(contentsOf: $0)).map {
                                    $0.mutating(transform: Archive.init(data:))
                                }
                            }
                        }
                    })
                }
                Self.container.publicCloudDatabase.add(operation)
            }
            .store(in: &subs)
        
        record
            .compactMap {
                $0
            }
            .sink {
                let subscription = CKQuerySubscription(
                    recordType: type,
                    predicate: .init(format: "recordID = %@", $0),
                    options: [.firesOnRecordUpdate])
                let a = CKSubscription.NotificationInfo(alertLocalizationKey: "Avocado")
                a.shouldSendContentAvailable = true
                subscription.notificationInfo = a
                NSLog("[kanban] subscription starts")
                Self.container.publicCloudDatabase.save(subscription) { _, _ in }
            }
            .store(in: &subs)
        
        record
            .compactMap {
                $0
            }
            .combineLatest(push)
            .map { id, _ in
                id
            }
            .debounce(for: .seconds(2), scheduler: queue)
            .sink {
                NSLog("[kanban] push starts")
                let record = CKRecord(recordType: type, recordID: $0)
                record[asset] = CKAsset(fileURL: URL)
                let operation = CKModifyRecordsOperation(recordsToSave: [record])
                operation.qualityOfService = .userInitiated
                operation.configuration.timeoutIntervalForRequest = 20
                operation.configuration.timeoutIntervalForResource = 20
                operation.savePolicy = .allKeys
                Self.container.publicCloudDatabase.add(operation)
            }
            .store(in: &subs)
        
        local
            .combineLatest(remote
                            .compactMap {
                                $0
                            }
                            .removeDuplicates())
            .filter {
                $0.0 == nil ? true : $0.0! < $0.1
            }
            .map {
                $1
            }
            .subscribe(store)
            .store(in: &subs)
        
        remote
            .combineLatest(local
                            .compactMap {
                                $0
                            }
                            .removeDuplicates())
            .filter {
                $0.0 == nil ? true : $0.0! < $0.1
            }
            .map { _, _ in }
            .subscribe(push)
            .store(in: &subs)
        
        store
            .removeDuplicates {
                $0 >= $1
            }
            .debounce(for: .seconds(1), scheduler: queue)
            .map(\.data)
            .sink {
                try? $0.write(to: URL, options: .atomic)
            }
            .store(in: &subs)
    }
    
    public var receipt: Future<Bool, Never> {
        NSLog("[kanban] receipt starts")
        let archive = self.archive
        let pull = self.pull
        let queue = self.queue
        return .init { promise in
            NSLog("[kanban] promise starts")
            var sub: AnyCancellable?
            sub = archive
                    .map { _ in }
                    .timeout(.seconds(15), scheduler: queue)
                    .sink { _ in
                        NSLog("[kanban] sink ends")
                        sub?.cancel()
                        promise(.success(false))
                    } receiveValue: {
                        NSLog("[kanban] sink received")
                        sub?.cancel()
                        promise(.success(true))
                    }
            pull.send()
            NSLog("[kanban] pull sent")
        }
    }
    
    public func load() {
        local.send(try? Data(contentsOf: URL)
                    .mutating(transform: Archive
                                .init(data:)))
    }
}

private extension String {
    var file: URL {
        var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(self)
        var resources = URLResourceValues()
        resources.isExcludedFromBackup = true
        try? url.setResourceValues(resources)
        return url
    }
}
