import CloudKit
import Network
import Combine

public final class Memory {
    public static internal(set) var shared = Memory()
    private static let type = "Archive"
    private static let asset = "asset"
    public let archive = PassthroughSubject<Archive, Never>()
    public let save = PassthroughSubject<Archive, Never>()
    var subs = Set<AnyCancellable>()
    private let store = PassthroughSubject<Archive, Never>()
    private let local = PassthroughSubject<Archive?, Never>()
    private let remote = PassthroughSubject<Archive?, Never>()
    private let pull = PassthroughSubject<Date, Never>()
    private let push = PassthroughSubject<Void, Never>()
    private let record = PassthroughSubject<CKRecord.ID?, Never>()
    private let subscription = PassthroughSubject<CKSubscription.ID?, Never>()
    private let queue = DispatchQueue(label: "", qos: .utility)
    
    private var container: CKContainer {
        .init(identifier: "iCloud.avoca.do")
    }
    
    init() {
        save
            .debounce(for: .seconds(1), scheduler: queue)
            .removeDuplicates()
            .sink { [weak self] in
                self?.store.send($0)
                self?.push.send()
            }
            .store(in: &subs)
        
        local
            .compactMap { $0 }
            .removeDuplicates()
            .merge(with: remote
                            .compactMap { $0 }
                            .removeDuplicates())
            .scan(nil) { previous, next in
                guard let previous = previous else { return next }
                return next > previous ? next : nil
            }
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.archive.send($0)
            }
            .store(in: &subs)
        
        pull
            .combineLatest(record)
            .filter {
                $1 == nil
            }
            .sink { [weak self] _, _ in
                self?.container.accountStatus { status, _ in
                    if status == .available {
                        self?.container.fetchUserRecordID { user, _ in
                            user.map {
                                self?.record.send(.init(recordName: "archive_" + $0.recordName))
                            }
                        }
                    }
                }
            }.store(in: &subs)
        
        record
            .compactMap { $0 }
            .combineLatest(pull)
            .removeDuplicates {
                Calendar.current.dateComponents([.second], from: $0.1, to: $1.1).second! < 6
            }
            .sink { [weak self] id, _ in
                let operation = CKFetchRecordsOperation(recordIDs: [id])
                operation.qualityOfService = .userInitiated
                operation.configuration.timeoutIntervalForRequest = 10
                operation.configuration.timeoutIntervalForResource = 10
                operation.fetchRecordsCompletionBlock = { [weak self] records, _ in
                    self?.remote.send(records?.values.first.flatMap {
                        ($0[Self.asset] as? CKAsset).flatMap {
                            $0.fileURL.flatMap {
                                (try? Data(contentsOf: $0)).map {
                                    $0.mutating(transform: Archive.init(data:))
                                }
                            }
                        }
                    })
                }
                self?.container.publicCloudDatabase.add(operation)
            }
            .store(in: &subs)
        
        record
            .compactMap { $0 }
            .sink { [weak self] id in
                let subscription = CKQuerySubscription(
                    recordType: Self.type,
                    predicate: .init(format: "recordID = %@", id),
                    options: [.firesOnRecordUpdate])
                subscription.notificationInfo = .init(alertLocalizationKey: "Avocado")
                
                self?.container.publicCloudDatabase.save(subscription) { [weak self] subscription, _ in
                    subscription.map {
                        self?.subscription.send($0.subscriptionID)
                    }
                }
            }
            .store(in: &subs)
        
        subscription
            .scan(nil) {
                guard $0 != nil else { return nil }
                return $1
            }
            .compactMap {
                $0
            }
            .sink { [weak self] in
                self?.container.publicCloudDatabase.delete(withSubscriptionID: $0) { _, _ in }
            }
            .store(in: &subs)
        
        record
            .compactMap { $0 }
            .combineLatest(push)
            .debounce(for: .seconds(2), scheduler: queue)
            .sink { [weak self] id, _ in
                let record = CKRecord(recordType: Self.type, recordID: id)
                record[Self.asset] = CKAsset(fileURL: FileManager.url)
                let operation = CKModifyRecordsOperation(recordsToSave: [record])
                operation.qualityOfService = .userInitiated
                operation.configuration.timeoutIntervalForRequest = 10
                operation.configuration.timeoutIntervalForResource = 10
                operation.savePolicy = .allKeys
                self?.container.publicCloudDatabase.add(operation)
            }
            .store(in: &subs)
        
        local
            .combineLatest(remote
                            .compactMap { $0 }
                            .removeDuplicates())
            .filter { $0.0 == nil ? true : $0.0! < $0.1 }
            .map { $1 }
            .sink { [weak self] in
                self?.store.send($0)
            }
            .store(in: &subs)
        
        remote
            .combineLatest(local
                            .compactMap { $0 }
                            .removeDuplicates())
            .filter { $0.0 == nil ? true : $0.0! < $0.1 }
            .sink { [weak self] _, _ in
                self?.push.send()
            }
            .store(in: &subs)
        
        store
            .removeDuplicates {
                $1 <= $0
            }
            .sink {
                FileManager.archive = $0
            }
            .store(in: &subs)
    }
    
    public func load() {
        local.send(FileManager.archive)
        record.send(nil)
    }
    
    public func fetch() {
        pull.send(.init())
    }
}
