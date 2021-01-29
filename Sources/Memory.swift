import CloudKit
import Network
import Combine

public final class Memory {
    public static internal(set) var shared = Memory()
    public let archive = PassthroughSubject<Archive, Never>()
    var subs = Set<AnyCancellable>()
    let save = PassthroughSubject<Archive, Never>()
    private let local = PassthroughSubject<Archive, Never>()
    private let remote = PassthroughSubject<Archive, Never>()
    private let pull = PassthroughSubject<Void, Never>()
    private let push = PassthroughSubject<Void, Never>()
    private let record = PassthroughSubject<CKRecord.ID, Never>()
    private let queue = DispatchQueue(label: "", qos: .utility)
    
    private var container: CKContainer {
        .init(identifier: "iCloud.avoca.do")
    }
    
    init() {
        save.debounce(for: .seconds(1), scheduler: queue).sink { [weak self] in
            FileManager.archive = $0
            self?.push.send()
        }
        .store(in: &subs)
        
        local.merge(with: remote).scan(nil) {
            guard let previous = $0 else { return $1 }
            return $1.date > previous.date ? $1 : nil
        }
        .compactMap {
            $0
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
            self?.archive.send($0)
        }
        .store(in: &subs)
        
        record.combineLatest(pull).sink { [weak self] id, _ in
            let operation = CKFetchRecordsOperation(recordIDs: [id])
            operation.configuration.timeoutIntervalForRequest = 15
            operation.configuration.timeoutIntervalForResource = 20
            operation.fetchRecordsCompletionBlock = { [weak self] records, _ in
                guard let value = records?.values.first else { return }
                self?.remote.send((try! Data(contentsOf: (value["asset"] as! CKAsset).fileURL!)).mutating(transform: Archive.init(data:)))
            }
            self?.container.publicCloudDatabase.add(operation)
        }
        .store(in: &subs)
        
        record.combineLatest(push).debounce(for: .seconds(3), scheduler: queue).sink { [weak self] id, _ in
            let record = CKRecord(recordType: "Archive", recordID: id)
            record["asset"] = CKAsset(fileURL: FileManager.url)
            let operation = CKModifyRecordsOperation(recordsToSave: [record])
            operation.configuration.timeoutIntervalForRequest = 20
            operation.configuration.timeoutIntervalForResource = 25
            operation.savePolicy = .allKeys
            self?.container.publicCloudDatabase.add(operation)
        }
        .store(in: &subs)
    }
    
    public func refresh() {
        FileManager.archive.map(local.send)
        container.fetchUserRecordID { [weak self] user, _ in
            user.map {
                self?.record.send(.init(recordName: "archive_" + $0.recordName))
            }
        }
        pull.send()
    }
}
