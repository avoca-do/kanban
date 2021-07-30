import Foundation
import Archivable

extension Cloud where A == Archive {
    public func purschase() {
        mutating {
            $0.capacity += 1
        }
    }
}
