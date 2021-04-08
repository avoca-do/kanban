import CloudKit
import Combine

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
        let store = PassthroughSubject<Archive, Never>()
        let remote = PassthroughSubject<Archive?, Never>()
        let push = PassthroughSubject<Void, Never>()
        let subscription = PassthroughSubject<CKSubscription.ID?, Never>()
        let record = CurrentValueSubject<CKRecord.ID?, Never>(nil)
        let type = "Archive"
        let asset = "asset"
        
        ;{
            $0.subscribe(store)
                .store(in: &subs)
            $0.map { _ in }
                .subscribe(push)
                .store(in: &subs)
        } (save
            .debounce(for: .seconds(1), scheduler: queue)
            .removeDuplicates()
            .share())
        
        local
            .compactMap {
                $0
            }
            .merge(with: remote
                            .compactMap { $0 })
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
                Calendar.current.dateComponents([.second], from: $0.1, to: $1.1).second! < 2
            }
            .map {
                $0.0
            }
            .sink {
                let operation = CKFetchRecordsOperation(recordIDs: [$0])
                operation.qualityOfService = .userInitiated
                operation.configuration.timeoutIntervalForRequest = 20
                operation.configuration.timeoutIntervalForResource = 20
                operation.fetchRecordsCompletionBlock = { records, _ in
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
                let query = CKQuerySubscription(
                    recordType: type,
                    predicate: .init(format: "recordID = %@", $0),
                    options: [.firesOnRecordUpdate])
                query.notificationInfo = .init(alertLocalizationKey: "Avocado")
                
                Self.container.publicCloudDatabase.save(query) { result, _ in
                    result.map {
                        subscription.send($0.subscriptionID)
                    }
                }
            }
            .store(in: &subs)
        
        record
            .compactMap {
                $0
            }
            .combineLatest(push)
            .sink { id, _ in
                let record = CKRecord(recordType: type, recordID: id)
                record[asset] = CKAsset(fileURL: FileManager.url)
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
            .receive(on: queue)
            .sink {
                FileManager.archive = $0
            }
            .store(in: &subs)
    }
    
    public var receipt: Future<Bool, Never> {
        let archive = self.archive
        let pull = self.pull
        let queue = self.queue
        return .init { promise in
            var sub: AnyCancellable?
            sub = archive
                    .map { _ in }
                    .timeout(.seconds(15), scheduler: queue)
                    .sink { _ in
                        sub?.cancel()
                        promise(.success(false))
                    } receiveValue: {
                        sub?.cancel()
                        promise(.success(true))
                    }
            pull.send()
        }
    }
    
    public func load() {
        local.send(FileManager.archive)
    }
}
