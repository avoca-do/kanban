import XCTest
import Combine
@testable import Kanban

final class CapacityMigrationTests: XCTestCase {
    private var archive: Archive!
    
    override func setUp() {
        Memory.shared = .init()
        Memory.shared.subs = .init()
    }
    
}
