import XCTest
import Archivable
@testable import Kanban

final class FindTests: XCTestCase {
    private var cloud: Cloud<Archive>!
    
    override func setUp() {
        cloud = .init(manifest: nil)
    }
    
    func testNew() {
        let expect = expectation(description: "")
        cloud
            .find(search: "hello") {
                XCTAssertTrue($0.isEmpty)
                expect.fulfill()
            }
        waitForExpectations(timeout: 1)
    }
    
    func testEmptySearch() {
        let expect = expectation(description: "")
        cloud.new(board: "hello world", completion: { })
        cloud.add(board: 0, card: "lorem ipsum")
        cloud
            .find(search: "") {
                XCTAssertTrue($0.isEmpty)
                expect.fulfill()
            }
        waitForExpectations(timeout: 1)
    }
    
    func testSpaceSearch() {
        let expect = expectation(description: "")
        cloud.new(board: "hello world", completion: { })
        cloud.add(board: 0, card: "lorem ipsum")
        cloud
            .find(search: " ") {
                XCTAssertTrue($0.isEmpty)
                expect.fulfill()
            }
        waitForExpectations(timeout: 1)
    }
    
    func testNotMatching() {
        let expect = expectation(description: "")
        cloud.new(board: "hello world", completion: { })
        cloud.add(board: 0, card: "lorem ipsum")
        cloud
            .find(search: "recall") {
                XCTAssertTrue($0.isEmpty)
                expect.fulfill()
            }
        waitForExpectations(timeout: 1)
    }
    
    func testBoard() {
        let expect = expectation(description: "")
        cloud.new(board: "hello world", completion: { })
        cloud.add(board: 0, card: "lorem ipsum")
        cloud
            .find(search: "hello world") {
                XCTAssertEqual("", $0.first?.breadcrumbs)
                XCTAssertEqual("hello world", $0.first?.content)
                XCTAssertEqual(.board(0), $0.first?.path)
                XCTAssertEqual(1, $0.count)
                expect.fulfill()
            }
        waitForExpectations(timeout: 1)
    }
    
    func test2Boards() {
        let expect = expectation(description: "")
        cloud.new(board: "hello world", completion: { })
        cloud.new(board: "Hello world 2", completion: { })
        cloud.new(board: "something else", completion: { })
        cloud.add(board: 0, card: "lorem ipsum")
        cloud
            .find(search: "hello world") {
                XCTAssertEqual("", $0.first?.breadcrumbs)
                XCTAssertEqual("", $0.last?.breadcrumbs)
                XCTAssertEqual("hello world", $0.first?.content)
                XCTAssertEqual("Hello world 2", $0.last?.content)
                XCTAssertEqual(.board(2), $0.first?.path)
                XCTAssertEqual(.board(1), $0.last?.path)
                XCTAssertEqual(2, $0.count)
                expect.fulfill()
            }
        waitForExpectations(timeout: 1)
    }
    
    func testPartialBoard() {
        let expect = expectation(description: "")
        cloud.new(board: "hello world", completion: { })
        cloud.new(board: "Hello world 2", completion: { })
        cloud.new(board: "something else", completion: { })
        cloud.new(board: "A Hello", completion: { })
        cloud.new(board: "a world", completion: { })
        cloud.add(board: 0, card: "lorem ipsum")
        cloud
            .find(search: "hello world") {
                XCTAssertEqual("hello world", $0[0].content)
                XCTAssertEqual("Hello world 2", $0[1].content)
                XCTAssertEqual("A Hello", $0[2].content)
                XCTAssertEqual("a world", $0[3].content)
                XCTAssertEqual(4, $0.count)
                expect.fulfill()
            }
        waitForExpectations(timeout: 1)
    }
}
