import CloudKit
import Network
import Combine

public final class Memory {
    public let archive = CurrentValueSubject<Archive?, Never>(nil)
    static var shared = Memory()
    var subs = Set<AnyCancellable>()
    let save = PassthroughSubject<Archive, Never>()
    private var network = true
    private let local = PassthroughSubject<Archive?, Never>()
    private let remote = PassthroughSubject<Archive?, Never>()
    private let fetch = PassthroughSubject<Void, Never>()
    private let record = CurrentValueSubject<CKRecord.ID?, Never>(nil)
    private let queue = DispatchQueue(label: "", qos: .utility)
    private let monitor = NWPathMonitor()
    private let container = CKContainer(identifier: "iCloud.avoca.do")
    
    init() {
        save.debounce(for: .seconds(3), scheduler: queue).sink {
            FileManager.archive = $0
        }.store(in: &subs)
        
        local.combineLatest(remote) {
            guard let local = $0 else { return $1 }
            guard let remote = $1 else { return nil }
            return local.date > remote.date ? local : remote
        }
        .map {
            $0 ?? .init()
        }
        .sink(receiveValue: archive.send)
        .store(in: &subs)
        
        record.combineLatest(fetch).sink { [weak self] id, _ in
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
        
        monitor.start(queue: .init(label: "", qos: .utility))
        monitor.pathUpdateHandler = { [weak self] in
            self?.network = $0.status == .satisfied
        }
    }
    
    func refresh() {
        remote.send(FileManager.archive)
        guard network else {
            remote.send(nil)
            return
        }
        auth()
        fetch.send()
    }
    
    private func auth() {
        if record.value == nil {
            container.fetchUserRecordID { [weak self] user, _ in
                self?.record.value = user
            }
        }
    }
    /*
    var archive: Future<Archive, Never> {
        .init { [weak self] result in
            self?.queue.async {
                
                
                
                
                guard instance.fileExists(atPath: folder.path) else { return result(.success([])) }
                result(
                    .success(
                        (try? instance.contentsOfDirectory(at: folder, includingPropertiesForKeys: [], options: .skipsHiddenFiles))
                            .map {
                                $0.compactMap {
                                    try? JSONDecoder().decode(Page.self, from: .init(contentsOf: $0))
                                }
                            }?.sorted { $0.date > $1.date } ?? []
                    )
                )
            }
        }
    }
    
    */
/*
    import CloudKit
    

    class Shared {
        private var network = false
        private let monitor = NWPathMonitor()
        
        func prepare() {
            monitor.start(queue: .init(label: "", qos: .utility))
            validate(monitor.currentPath)
            monitor.pathUpdateHandler = validate(_:)
        }
        
        func load(_ ids: [String], session: Session, error: @escaping () -> Void, result: @escaping ([URL]) -> Void) {
            if session.user.isEmpty {
                CKContainer(identifier: "iCloud.holbox").fetchUserRecordID {
                    guard let user = $0, $1 == nil else { return error() }
                    session.update(user.recordName)
                    self.load(ids, user: user.recordName, error: error, result: result)
                }
            } else {
                guard network else { return error() }
                load(ids, user: session.user, error: error, result: result)
            }
        }
        
        func save(_ ids: [String : URL], session: Session) {
            guard network else { return }
            if session.user.isEmpty {
                CKContainer(identifier: "iCloud.holbox").fetchUserRecordID {
                    guard let user = $0, $1 == nil else { return }
                    session.update(user.recordName)
                    self.save(ids, user: user.recordName)
                }
            } else {
                save(ids, user: session.user)
            }
        }
        
        private func load(_ ids: [String], user: String, error: @escaping () -> Void, result: @escaping ([URL]) -> Void) {
            let ids = ids.map { $0 + user }
            let operation = CKFetchRecordsOperation(recordIDs: ids.map(CKRecord.ID.init(recordName:)))
            operation.configuration.timeoutIntervalForRequest = 20
            operation.configuration.timeoutIntervalForResource = 25
            operation.fetchRecordsCompletionBlock = {
                guard let records = $0, $1 == nil else { return error() }
                result(ids.map { id in (records.values.first { $0.recordID.recordName == id }!["asset"] as! CKAsset).fileURL! })
            }
            CKContainer(identifier: "iCloud.holbox").publicCloudDatabase.add(operation)
        }
        
        private func save(_ ids: [String : URL], user: String) {
            let operation = CKModifyRecordsOperation(recordsToSave: ids.compactMap {
                let record = CKRecord(recordType: "Record", recordID: .init(recordName: $0.0 + user))
                record["asset"] = CKAsset(fileURL: $0.1)
                guard let data = try? Data(contentsOf: $0.1), !data.isEmpty else { return nil }
                return record
            })
            operation.configuration.timeoutIntervalForRequest = 20
            operation.configuration.timeoutIntervalForResource = 25
            operation.savePolicy = .allKeys
            CKContainer(identifier: "iCloud.holbox").publicCloudDatabase.add(operation)
        }
        
        private func validate(_ path: NWPath) {
            network = path.status == .satisfied
    #if os(watchOS)
            network = true
    #endif
        }
    }*/
}
