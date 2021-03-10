import CloudKit
import Network
import Combine

public final class Memory {
    public static internal(set) var shared = Memory()
    public let archive = PassthroughSubject<Archive, Never>()
    var subs = Set<AnyCancellable>()
    let save = PassthroughSubject<Archive, Never>()
    private var first = true
    private let store = PassthroughSubject<Archive, Never>()
    private let local = PassthroughSubject<Archive?, Never>()
    private let remote = PassthroughSubject<Archive?, Never>()
    private let pull = PassthroughSubject<Void, Never>()
    private let push = PassthroughSubject<Void, Never>()
    private let record = CurrentValueSubject<CKRecord.ID?, Never>(nil)
    private let queue = DispatchQueue(label: "", qos: .utility)
    
    private var container: CKContainer {
        .init(identifier: "iCloud.avoca.do")
    }
    
    init() {
        save
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
            .scan(nil) {
                guard let previous = $0 else { return $1 }
                return $1 > previous ? $1 : nil
            }
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.archive.send($0)
            }
            .store(in: &subs)
        
        record
            .compactMap { $0 }
            .combineLatest(pull)
            .sink { [weak self] id, _ in
                let operation = CKFetchRecordsOperation(recordIDs: [id])
                operation.qualityOfService = .userInitiated
                operation.configuration.timeoutIntervalForRequest = 15
                operation.configuration.timeoutIntervalForResource = 20
                operation.fetchRecordsCompletionBlock = { [weak self] records, _ in
                    self?.remote.send(records?.values.first.flatMap {
                        ($0["asset"] as? CKAsset).flatMap {
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
            .combineLatest(push)
            .debounce(for: .seconds(2), scheduler: queue)
            .sink { [weak self] id, _ in
                let record = CKRecord(recordType: "Archive", recordID: id)
                record["asset"] = CKAsset(fileURL: FileManager.url)
                let operation = CKModifyRecordsOperation(recordsToSave: [record])
                operation.qualityOfService = .userInitiated
                operation.configuration.timeoutIntervalForRequest = 15
                operation.configuration.timeoutIntervalForResource = 20
                operation.savePolicy = .allKeys
                self?.container.publicCloudDatabase.add(operation)
            }
            .store(in: &subs)
        
        local
            .combineLatest(remote
                            .compactMap { $0 }
                            .removeDuplicates())
            .filter {
                $0.0 == nil || $0.0! < $0.1
            }
            .map { $1 }
            .sink(receiveValue: store.send)
            .store(in: &subs)
        
        remote
            .combineLatest(local
                            .compactMap { $0 }
                            .removeDuplicates())
            .filter {
                $0.0 == nil || $0.0! < $0.1
            }
            .sink { [weak self] _, _ in
                self?.push.send()
            }
            .store(in: &subs)
        
        store
            .debounce(for: .seconds(1), scheduler: queue)
            .removeDuplicates()
            .sink {
                FileManager.archive = $0
            }
            .store(in: &subs)
    }
    
    public func refresh() {
        if first {
            first = false
            local.send(FileManager.archive)
        }
        if record.value == nil {
            container.fetchUserRecordID { [weak self] user, _ in
                user.map {
                    self?.record.value = .init(recordName: "archive_" + $0.recordName)
                }
            }
        }
        pull.send()
    }
}
