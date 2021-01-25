import Foundation
import Combine

final class Memory {
    static var shared = Memory()
    let save = PassthroughSubject<Archive, Never>()
    private let queue = DispatchQueue(label: "", qos: .utility)
    
//    var user: Future<User, Never> {
//        .init { [weak self] result in
//            self?.queue.async {
//                guard instance.fileExists(atPath: folder.path) else { return result(.success([])) }
//                result(
//                    .success(
//                        (try? instance.contentsOfDirectory(at: folder, includingPropertiesForKeys: [], options: .skipsHiddenFiles))
//                            .map {
//                                $0.compactMap {
//                                    try? JSONDecoder().decode(Page.self, from: .init(contentsOf: $0))
//                                }
//                            }?.sorted { $0.date > $1.date } ?? []
//                    )
//                )
//            }
//        }
//    }
}
