import XCTest
import Combine
@testable import Kanban

final class ArchiveTests: XCTestCase {
    private var archive: Archive!
    private var subs: Set<AnyCancellable>!
    
    override func setUp() {
        archive = .init()
        subs = .init()
        Memory.shared = .init()
        Memory.shared.subs = .init()
    }
    
    func testSaveBoards() {
        let expect = expectation(description: "")
        let date = Date()
        Memory.shared.save.sink {
            XCTAssertGreaterThanOrEqual($0.date(.archive), date)
            XCTAssertFalse($0.boards.isEmpty)
            expect.fulfill()
        }
        .store(in: &subs)
        archive.boards = [.init()]
        
        waitForExpectations(timeout: 1)
    }
    
    func testSaveCapacity() {
        let expect = expectation(description: "")
        let date = Date()
        Memory.shared.save.sink {
            XCTAssertGreaterThanOrEqual($0.date(.archive), date)
            XCTAssertEqual(3, $0.capacity)
            expect.fulfill()
        }
        .store(in: &subs)
        archive.capacity = 3
        
        waitForExpectations(timeout: 1)
    }
    
    func testAdd() {
        let date = Date()
        archive.add()
        
        XCTAssertEqual(1, archive.count(.archive))
        XCTAssertEqual(1, archive[.board(0)].snaps.first!.state.actions.count)
        XCTAssertEqual(.create, archive[.board(0)].snaps.first!.state.actions.first!)
        XCTAssertGreaterThanOrEqual(archive[.board(0)].snaps.first!.state.date, date)
        XCTAssertGreaterThanOrEqual(archive.date(.archive), date)
    }
    
    func testDelete() {
        archive.add()
        archive.delete(.board(0))
        
        XCTAssertTrue(archive.isEmpty(.archive))
    }
    
    func testEmpty() {
        XCTAssertEqual(true, archive.isEmpty(.archive))
        archive.add()
        XCTAssertEqual(false, archive.isEmpty(.board(0)))
        XCTAssertEqual(true, archive.isEmpty(.column(.board(0), 0)))
    }
    
    func testCount() {
        XCTAssertEqual(0, archive.count(.archive))
        archive.add()
        XCTAssertEqual(3, archive.count(.board(0)))
        XCTAssertEqual(0, archive.count(.column(.board(0), 0)))
    }
    
    func testName() {
        archive.add()
        archive.boards[0].name = "hello world"
        XCTAssertEqual("hello world", archive[name: .board(0)])
        XCTAssertEqual("DO", archive[title: .column(.board(0), 0)])
    }
    
    func testIndexOutOfBounds() {
        XCTAssertNotNil(archive[.board(0)])
    }
}
