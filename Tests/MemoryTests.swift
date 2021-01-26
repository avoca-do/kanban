import XCTest
@testable import Kanban

final class MemoryTests: XCTestCase {
    override func setUp() {
        Memory.shared = .init()
        Memory.shared.subs = .init()
    }
    
    func testLoad() {
        
    }
}
