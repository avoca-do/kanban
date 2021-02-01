import XCTest
@testable import Kanban

final class DataTests: XCTestCase {
    override func setUp() {
        Memory.shared = .init()
        Memory.shared.subs = .init()
    }
    
    func testArchive() {
        var boardA = Board()
        var data = Data()
            .add(Date(timeIntervalSince1970: 300).timestamp)
            .add(UInt8(boardA.snaps[0].state.actions.count))
            .add(boardA.snaps[0].state.actions.flatMap(\.data))
        boardA.snaps[0] = Board.Snap(data: &data, after: nil)
        
        var boardB = Board()
        data = Data()
            .add(Date(timeIntervalSince1970: 500).timestamp)
            .add(UInt8(boardB.snaps[0].state.actions.count))
            .add(boardB.snaps[0].state.actions.flatMap(\.data))
        boardB.snaps[0] = Board.Snap(data: &data, after: nil)
        boardB.name = "total recall"
        boardB.card()
        boardB[0, 0] = "hello world"
        
        var archive = Archive()
        archive.boards = [boardB, boardA]
        
        let archived = archive.data.mutating(transform: Archive.init(data:))
        
        XCTAssertEqual(2, archived.boards.count)
        XCTAssertEqual(1, archived[0][0].count)
        XCTAssertTrue(archived[1][0].isEmpty)
        XCTAssertEqual("hello world", archived[0][0][0])
        
        XCTAssertEqual(2, archived[0].snaps.count)
        XCTAssertEqual(1, archived[0].snaps.first!.state.actions.count)
        XCTAssertEqual(.create, archived[0].snaps.first!.state.actions.first!)
        XCTAssertEqual(2, archived[0].snaps.last!.state.actions.count)
        XCTAssertEqual(500, Int(archived[0].snaps.first!.state.date.timeIntervalSince1970))
        XCTAssertEqual(.init(boardB.snaps[1].state.date.timeIntervalSince1970), Int(archived[0].snaps.last!.state.date.timeIntervalSince1970))
        XCTAssertEqual("total recall", archived[0].name)
        
        XCTAssertEqual(.card, archived[0].snaps.last!.state.actions.first)
        
        if case let .content(id, content) = archived[0].snaps.last!.state.actions.last {
            XCTAssertEqual("hello world", content)
            XCTAssertEqual(0, id)
        } else {
            XCTFail()
        }

        XCTAssertEqual(1, archived[1].snaps.count)
        XCTAssertEqual(1, archived[1].snaps.first!.state.actions.count)
        XCTAssertEqual(.create, archived[1].snaps.first!.state.actions.first!)
        XCTAssertEqual(300, Int(archived[1].snaps.first!.state.date.timeIntervalSince1970))
        XCTAssertEqual(.init(boardA.snaps[0].state.date.timeIntervalSince1970), Int(archived[1].snaps.last!.state.date.timeIntervalSince1970))
        
        XCTAssertEqual(3, archived[0].count)
        XCTAssertEqual("DO", archived[0][0].title)
        XCTAssertEqual("DOING", archived[0][1].title)
        XCTAssertEqual("DONE", archived[0][2].title)
    }
    
    func testVertical() {
        let action = Board.Action.vertical(19242, 29242)
        XCTAssertEqual(action, action.data.mutating(transform: Board.Action.init(data:)))
    }
}
