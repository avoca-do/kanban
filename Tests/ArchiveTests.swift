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
    
    func testSave() {
        let expect = expectation(description: "")
        let date = Date()
        Memory.shared.save.sink {
            XCTAssertGreaterThanOrEqual($0.date, date)
            expect.fulfill()
        }
        .store(in: &subs)
        archive.boards = [.init()]
        
        waitForExpectations(timeout: 1)
    }
    
    func testAdd() {
        let date = Date()
        archive.add()
        
        XCTAssertEqual(1, archive.boards.count)
        XCTAssertEqual(1, archive.boards.first!.snaps.first!.state.actions.count)
        XCTAssertEqual(.create, archive.boards.first!.snaps.first!.state.actions.first!)
        XCTAssertGreaterThanOrEqual(archive.boards.first!.snaps.first!.state.date, date)
        XCTAssertGreaterThanOrEqual(archive.date, date)
    }
    
    func testDelete() {
        archive.add()
        archive.delete(board: 0)
        
        XCTAssertTrue(archive.boards.isEmpty)
    }
    
    func testEmpty() {
        XCTAssertEqual(true, archive[.empty])
        archive.add()
        XCTAssertEqual(false, archive[.board(0)])
        XCTAssertEqual(true, archive[.column(.board(0), 0)])
    }
    
    func testCount() {
        XCTAssertEqual(0, archive[.empty])
        archive.add()
        XCTAssertEqual(3, archive[.board(0)])
        XCTAssertEqual(0, archive[.column(.board(0), 0)])
    }
    
    func testDate() {
        XCTAssertEqual(.distantPast, archive[.empty])
        archive.add()
        XCTAssertEqual(archive.boards.first!.date, archive[.board(0)])
        XCTAssertEqual(archive.boards.first!.date, archive[.column(.board(0), 0)])
    }
    
    func testName() {
        archive.add()
        archive.boards[0].name = "hello world"
        XCTAssertEqual("hello world", archive[name: .board(0)])
        XCTAssertEqual("DO", archive[title: .column(.board(0), 0)])
    }
    
    func testIndexOutOfBounds() {
        XCTAssertEqual(true, archive[.board(0)])
        XCTAssertEqual(0, archive[.board(0)])
        XCTAssertEqual(.distantPast, archive[.board(0)])
        XCTAssertEqual(.init(cards: 0, done: 0, percentage: 0), archive[.board(0)])
        XCTAssertEqual("", archive[.board(0)])
        XCTAssertEqual("", archive[name: .board(0)])
        XCTAssertEqual("", archive[title: .column(.board(0), 0)])
    }
}
