import Foundation
import Archivable

extension Cloud where A == Archive {
    public func newBoard() {
        mutating {
            $0.items.insert(.init(), at: 0)
        }
    }
    
    public func purschase() {
        mutating {
            $0.capacity += 1
        }
    }
}
