import Foundation
import Combine

final class Memory {
    static let shared = Memory()
    let save = PassthroughSubject<Board, Never>()
    private let queue = DispatchQueue(label: "", qos: .utility)
    private let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("boards")
    
    
    
    
    static var pages: Future<[Page], Never> {
        .init { result in
            queue.async {
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
    
    static func page(_ id: String) -> Future<Page, Never> {
        .init { result in
            queue.async {
                (try? JSONDecoder().decode(Page.self, from: .init(contentsOf: folder.appendingPathComponent(id))))
                    .map {
                        result(.success($0))
                    }
            }
        }
    }
    
    static func delete(_ page: Page) {
        queue.async {
            try? instance.removeItem(at: folder.appendingPathComponent(page.id.uuidString))
        }
    }
    
    static func forget() {
        queue.async {
            try? instance.removeItem(at: folder)
        }
    }
    
    static func save(_ page: Page) {
        queue.async {
            var url = folder
            if !instance.fileExists(atPath: url.path) {
                var resources = URLResourceValues()
                resources.isExcludedFromBackup = true
                try? url.setResourceValues(resources)
                try? instance.createDirectory(at: url, withIntermediateDirectories: true)
            }
            try? JSONEncoder().encode(page).write(to: url.appendingPathComponent(page.id.uuidString), options: .atomic)
        }
    }
}
