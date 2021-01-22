import Foundation
import Combine

extension FileManager {
    static var user: Data? { try? .init(contentsOf: _user) }

    
    static func delete(_ board: Board) {
//        queue.async {
//            try? instance.removeItem(at: folder.appendingPathComponent(page.id.uuidString))
//        }
    }
    
    static func save(_ board: Board) {
//        queue.async {
//            var url = folder
//            if !instance.fileExists(atPath: url.path) {
//                var resources = URLResourceValues()
//                resources.isExcludedFromBackup = true
//                try? url.setResourceValues(resources)
//                try? instance.createDirectory(at: url, withIntermediateDirectories: true)
//            }
//            try? JSONEncoder().encode(board).write(to: url.appendingPathComponent(.init(board.id)), options: .atomic)
//        }
    }
    
    private static let _root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private static let _user = _root.appendingPathComponent("user")
    private static let _folder = _root.appendingPathComponent("boards")
}