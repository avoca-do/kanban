import XCTest
@testable import Kanban

final class DataTests: XCTestCase {
    override func setUp() {
        Repository.override = .init()
    }
    
    func testArchive() {
        var boardA = Board()
        var data = Data()
            .adding(Date(timeIntervalSince1970: 300).timestamp)
            .adding(UInt8(boardA.snaps[0].state.actions.count))
            .adding(boardA.snaps[0].state.actions.flatMap(\.data))
        boardA.snaps[0] = Board.Snap(data: &data, after: nil)
        
        var boardB = Board()
        data = Data()
            .adding(Date(timeIntervalSince1970: 500).timestamp)
            .adding(UInt8(boardB.snaps[0].state.actions.count))
            .adding(boardB.snaps[0].state.actions.flatMap(\.data))
        boardB.snaps[0] = Board.Snap(data: &data, after: nil)
        boardB.name = "total recall"
        boardB.card()
        boardB[content: .card(.column(.archive, 0), 0)] = "hello world"
        
        var archive = Archive.new
        archive.boards = [boardB, boardA]
        
        let archived = archive.data.mutating(transform: Archive.init(data:))
        
        XCTAssertEqual(2, archived.boards.count)
        XCTAssertEqual(1, archived.count(.column(.board(0), 0)))
        XCTAssertTrue(archived.isEmpty(.column(.board(1), 0)))
        XCTAssertEqual("hello world", archived[content: .card(.column(.board(0), 0), 0)])
        
        XCTAssertEqual(2, archived.boards.first!.snaps.count)
        XCTAssertEqual(1, archived.boards.first!.snaps.first!.state.actions.count)
        XCTAssertEqual(.create, archived.boards.first!.snaps.first!.state.actions.first!)
        XCTAssertEqual(2, archived.boards.first!.snaps.last!.state.actions.count)
        XCTAssertEqual(500, Int(archived.boards.first!.snaps.first!.state.date.timeIntervalSince1970))
        XCTAssertEqual(.init(boardB.snaps[1].state.date.timeIntervalSince1970), Int(archived.boards.first!.snaps.last!.state.date.timeIntervalSince1970))
        XCTAssertEqual("total recall", archived.boards.first!.name)
        
        XCTAssertEqual(.card, archived.boards.first!.snaps.last!.state.actions.first)
        
        if case let .content(id, content) = archived.boards.first!.snaps.last!.state.actions.last {
            XCTAssertEqual("hello world", content)
            XCTAssertEqual(0, id)
        } else {
            XCTFail()
        }

        XCTAssertEqual(1, archived.boards[1].snaps.count)
        XCTAssertEqual(1, archived.boards[1].snaps.first!.state.actions.count)
        XCTAssertEqual(.create, archived.boards[1].snaps.first!.state.actions.first!)
        XCTAssertEqual(300, Int(archived.boards[1].snaps.first!.state.date.timeIntervalSince1970))
        XCTAssertEqual(.init(boardA.snaps[0].state.date.timeIntervalSince1970), Int(archived.boards[1].snaps.last!.state.date.timeIntervalSince1970))
        
        XCTAssertEqual(3, archived.boards[0].count)
        XCTAssertEqual("DO", archived[title: .column(.board(0), 0)])
        XCTAssertEqual("DOING", archived[title: .column(.board(0), 1)])
        XCTAssertEqual("DONE", archived[title: .column(.board(0), 2)])
    }
    
    func testVertical() {
        let action = Board.Action.vertical(19242, 29242)
        XCTAssertEqual(action, action.data.mutating(transform: Board.Action.init(data:)))
    }
    
    func testHorizontal() {
        let action = Board.Action.horizontal(19242, 244)
        XCTAssertEqual(action, action.data.mutating(transform: Board.Action.init(data:)))
    }
    
    func testRemove() {
        let action = Board.Action.remove(19242)
        XCTAssertEqual(action, action.data.mutating(transform: Board.Action.init(data:)))
    }
    
    func testDrop() {
        let action = Board.Action.drop(254)
        XCTAssertEqual(action, action.data.mutating(transform: Board.Action.init(data:)))
    }
    
    func testCapacity() {
        var archive = Archive.new
        archive.capacity = 300
        XCTAssertEqual(300, archive.data.mutating(transform: Archive.init(data:)).capacity)
    }
}
