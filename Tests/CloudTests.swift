import XCTest
import Combine
import Archivable
@testable import Kanban

final class CloudTests: XCTestCase {
    private var cloud: Cloud<Archive>!
    private var subs: Set<AnyCancellable>!
    
    override func setUp() {
        cloud = .init(manifest: nil)
        subs = []
    }
    
    func testIndexOutOfBounds() {
        XCTAssertNotNil(cloud.archive.value[3])
    }
    
    func testNewBoard() {
        let expect = expectation(description: "")
        let date = Date()
        XCTAssertTrue(cloud.archive.value.isEmpty)
        XCTAssertEqual(0, cloud.archive.value.count)
        cloud
            .archive
            .dropFirst()
            .sink {
                XCTAssertEqual(1, $0.count)
                XCTAssertFalse($0.isEmpty)
                XCTAssertEqual(1, $0[0].snaps.first!.state.actions.count)
                XCTAssertEqual(.create, $0[0].snaps.first!.state.actions.first!)
                XCTAssertGreaterThanOrEqual($0[0].snaps.first!.state.date, date)
                XCTAssertGreaterThanOrEqual($0.date, date)
                XCTAssertFalse($0[0].isEmpty)
                XCTAssertTrue($0[0][0].isEmpty)
                XCTAssertEqual("Lol", $0[0].name)
                
                XCTAssertEqual(3, $0[0].count)
                XCTAssertEqual(0, $0[0][0].count)
                XCTAssertEqual("DO", $0[0][0].name)
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.new(board: "Lol ", completion: { })
        waitForExpectations(timeout: 1)
    }
    
    func testSaveCapacity() {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst()
            .sink {
                XCTAssertEqual(2, $0.capacity)
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.purschase()
        waitForExpectations(timeout: 1)
    }
    
    func testDelete() {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst(2)
            .sink {
                XCTAssertTrue($0.isEmpty)
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.new(board: "", completion: { })
        cloud.delete(board: 0)
        waitForExpectations(timeout: 1)
    }
    
    func testBoardName() {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst(2)
            .sink {
                XCTAssertEqual("hello world", $0[0].name)
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.new(board: "", completion: { })
        cloud.rename(board: 0, name: "hello world")
        waitForExpectations(timeout: 1)
    }
    
    func testAddColumn() {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst(2)
            .sink {
                XCTAssertEqual(4, $0[0].count)
                XCTAssertEqual("Avo", $0[0][3].name)
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.new(board: "", completion: { })
        cloud.add(board: 0, column: "Avo ")
        waitForExpectations(timeout: 1)
    }
    
    func testColumnName() {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst(2)
            .sink {
                XCTAssertEqual("hello world", $0[0][0].name)
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.new(board: "", completion: { })
        cloud.rename(board: 0, column: 0, name: "hello world")
        waitForExpectations(timeout: 1)
    }
    
    func testAddCard() {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst(2)
            .sink {
                XCTAssertEqual(1, $0[0][0].count)
                XCTAssertEqual("Lol", $0[0][0][0].content)
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.new(board: "", completion: { })
        cloud.add(board: 0, card: "Lol ")
        waitForExpectations(timeout: 1)
    }
    
    func testAddSecondCard() {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst(3)
            .sink {
                XCTAssertEqual("Mop", $0[0][0][0].content)
                XCTAssertEqual("Lol", $0[0][0][1].content)
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.new(board: "", completion: { })
        cloud.add(board: 0, card: "Lol ")
        cloud.add(board: 0, card: " Mop ")
        waitForExpectations(timeout: 1)
    }
    
    func testContent() {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst(6)
            .sink {
                XCTAssertEqual("hello world", $0[0][0][2].content)
                XCTAssertEqual(9, $0[0].snaps.last!.state.actions.count)
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.new(board: "", completion: { })
        cloud.add(board: 0, card: "")
        cloud.add(board: 0, card: "")
        cloud.add(board: 0, card: "")
        cloud.add(board: 0, card: "")
        cloud.update(board: 0, column: 0, card: 2, content: "hello world")
        waitForExpectations(timeout: 1)
    }
    
    func testMoveVertical() {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst(5)
            .sink {
                XCTAssertEqual("hello world", $0[0][0][0].content)
                XCTAssertEqual(6, $0[0].snaps.last!.state.actions.count)
                XCTAssertEqual(2, $0[0][0].count)
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.new(board: "", completion: { })
        cloud.add(board: 0, card: "")
        cloud.update(board: 0, column: 0, card: 0, content: "hello world")
        cloud.add(board: 0, card: "")
        cloud.move(board: 0, column: 0, card: 1, vertical: 0)
        waitForExpectations(timeout: 1)
    }
    
    func testMoveVerticalSameIndex() {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst(4)
            .sink {
                XCTAssertEqual("hello world", $0[0][0][1].content)
                XCTAssertEqual(5, $0[0].snaps.last!.state.actions.count)
                XCTAssertEqual(2, $0[0][0].count)
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.new(board: "", completion: { })
        cloud.add(board: 0, card: "")
        cloud.update(board: 0, column: 0, card: 0, content: "hello world")
        cloud.add(board: 0, card: "")
        cloud.move(board: 0, column: 0, card: 1, vertical: 1)
        waitForExpectations(timeout: 1)
    }
    
    func testMoveHorizontal() {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst(3)
            .sink {
                XCTAssertEqual(4, $0[0].snaps.last!.state.actions.count)
                XCTAssertTrue($0[0][0].isEmpty)
                XCTAssertFalse($0[0][1].isEmpty)
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.new(board: "", completion: { })
        cloud.add(board: 0, card: "")
        cloud.move(board: 0, column: 0, card: 0, horizontal: 1)
        waitForExpectations(timeout: 1)
    }
    
    func testMoveHorizontalSameIndex() {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst(2)
            .sink {
                XCTAssertEqual(3, $0[0].snaps.last!.state.actions.count)
                XCTAssertFalse($0[0][0].isEmpty)
                XCTAssertTrue($0[0][1].isEmpty)
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.new(board: "", completion: { })
        cloud.add(board: 0, card: "")
        cloud.move(board: 0, column: 0, card: 0, horizontal: 0)
        waitForExpectations(timeout: 1)
    }
    
    func testDeleteCard() {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst(3)
            .sink {
                XCTAssertTrue($0[0][0].isEmpty)
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.new(board: "", completion: { })
        cloud.add(board: 0, card: "")
        cloud.delete(board: 0, column: 0, card: 0)
        waitForExpectations(timeout: 1)
    }
    
    func testDeleteColumn() {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst(2)
            .sink {
                XCTAssertEqual(2, $0[0].count)
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.new(board: "", completion: { })
        cloud.delete(board: 0, column: 1)
        waitForExpectations(timeout: 1)
    }
}
