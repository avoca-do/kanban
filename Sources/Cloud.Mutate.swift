import Foundation
import Archivable

extension Cloud where A == Archive {
    public func new(board: String) {
        mutating {
            $0.items.insert(.init(), at: 0)
            $0
                .items
                .mutate(index: 0) {
                    $0.with(name: board)
                }
        }
    }
    
    public func delete(board: Int) {
        mutating {
            $0
                .items
                .remove(at: board)
        }
    }
    
    public func purschase() {
        mutating {
            $0.capacity += 1
        }
    }
}
