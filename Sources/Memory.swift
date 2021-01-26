import CloudKit
import Network
import Combine

public final class Memory {
    public static internal(set) var shared = Memory()
    public let archive = PassthroughSubject<Archive, Never>()
    var subs = Set<AnyCancellable>()
    let save = PassthroughSubject<Archive, Never>()
    private var network = true
    private let local = PassthroughSubject<Archive?, Never>()
    private let remote = PassthroughSubject<Archive?, Never>()
    private let pull = PassthroughSubject<Void, Never>()
    private let push = PassthroughSubject<Void, Never>()
    private let record = CurrentValueSubject<CKRecord.ID?, Never>(nil)
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "", qos: .utility)
    
    private var container: CKContainer {
        .init(identifier: "iCloud.avoca.do")
    }
    
    init() {
        save.debounce(for: .seconds(1), scheduler: queue).sink { [weak self] in
            FileManager.archive = $0
            self?.auth()
            self?.push.send()
        }
        .store(in: &subs)
        
        local.combineLatest(remote) {
            guard let local = $0 else { return $1 }
            guard let remote = $1 else { return local }
            return local.date > remote.date ? local : remote
        }
        .map {
            $0 ?? .init()
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: archive.send)
        .store(in: &subs)
        
        record.combineLatest(pull).sink { [weak self] id, _ in
            guard let id = id else {
                self?.remote.send(nil)
                return
            }
            let operation = CKFetchRecordsOperation(recordIDs: [id])
            operation.configuration.timeoutIntervalForRequest = 15
            operation.configuration.timeoutIntervalForResource = 20
            operation.fetchRecordsCompletionBlock = { [weak self] records, _ in
                guard let value = records?.values.first else {
                    self?.remote.send(nil)
                    return
                }
                self?.remote.send((try! Data(contentsOf: (value["asset"] as! CKAsset).fileURL!)).mutating {
                    .init(data: &$0)
                })
            }
            self?.container.publicCloudDatabase.add(operation)
        }
        .store(in: &subs)
        
        record.combineLatest(push).debounce(for: .seconds(3), scheduler: queue).sink { [weak self] id, _ in
            guard let id = id else { return }
            let record = CKRecord(recordType: "Archive", recordID: id)
            record["asset"] = CKAsset(fileURL: FileManager.url)
            let operation = CKModifyRecordsOperation(recordsToSave: [record])
            operation.configuration.timeoutIntervalForRequest = 20
            operation.configuration.timeoutIntervalForResource = 25
            operation.savePolicy = .allKeys
            self?.container.publicCloudDatabase.add(operation)
        }
        .store(in: &subs)
        
        monitor.start(queue: .init(label: "", qos: .utility))
        monitor.pathUpdateHandler = { [weak self] in
            self?.network = $0.status == .satisfied
        }
    }
    
    public func refresh() {
        local.send(FileManager.archive)
        guard network else {
            remote.send(nil)
            return
        }
        auth()
        pull.send()
    }
    
    private func auth() {
        if record.value == nil {
            container.fetchUserRecordID { [weak self] user, _ in
                self?.record.value = user.map {
                    .init(recordName: "archive_" + $0.recordName)
                }
            }
        }
    }
}
