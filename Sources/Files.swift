import Foundation
import Combine

public extension FileManager {

    
    static func delete(_ board: Board) {
//        queue.async {
//            try? instance.removeItem(at: folder.appendingPathComponent(page.id.uuidString))
//        }
    }
    
    static func save(_ board: Board) {
        queue.async {
            var url = folder
            if !instance.fileExists(atPath: url.path) {
                var resources = URLResourceValues()
                resources.isExcludedFromBackup = true
                try? url.setResourceValues(resources)
                try? instance.createDirectory(at: url, withIntermediateDirectories: true)
            }
            try? JSONEncoder().encode(board).write(to: url.appendingPathComponent(board.id), options: .atomic)
        }
    }
    
    private static let queue = DispatchQueue(label: "", qos: .utility)
    private static let instance = `default`
    private static let root = instance.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private static let folder = root.appendingPathComponent("boards")
}
