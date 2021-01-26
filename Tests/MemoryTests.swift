import XCTest
@testable import Kanban

final class MemoryTests: XCTestCase {
    override func setUp() {
        Memory.shared = .init()
        Memory.shared.sub = nil
    }
    
    func testLoad() {
        
    }
}
