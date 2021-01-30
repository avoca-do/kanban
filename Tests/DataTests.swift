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
            .add(UInt8(boardA.snaps[0].actions.count))
            .add(boardA.snaps[0].actions.flatMap(\.data))
        boardA.snaps[0] = Board.Snap(data: &data).with(state: [])
        
        var boardB = Board()
        data = Data()
            .add(Date(timeIntervalSince1970: 500).timestamp)
            .add(UInt8(boardB.snaps[0].actions.count))
            .add(boardB.snaps[0].actions.flatMap(\.data))
        boardB.snaps[0] = Board.Snap(data: &data).with(state: [])
        boardB.name = "total recall"
        boardB.card()
        boardB.content(card: .init(column: 0, order: 0), text: "hello world")
        
        var archive = Archive()
        archive.boards = [boardB, boardA]
        
        let archived = archive.data.mutating(transform: Archive.init(data:))
        
        XCTAssertEqual(2, archived.boards.count)
        XCTAssertEqual(1, archived[0][0].count)
        XCTAssertTrue(archived[1][0].isEmpty)
        XCTAssertEqual("hello world", archived[0][0][0])
        
        XCTAssertEqual(2, archived[0].snaps.count)
        XCTAssertEqual(1, archived[0].snaps.first!.actions.count)
        XCTAssertEqual(.create, archived[0].snaps.first!.actions.first!)
        XCTAssertEqual(2, archived[0].snaps.last!.actions.count)
        XCTAssertEqual(500, Int(archived[0].snaps.first!.date.timeIntervalSince1970))
        XCTAssertEqual(.init(boardB.snaps[1].date.timeIntervalSince1970), Int(archived[0].snaps.last!.date.timeIntervalSince1970))
        XCTAssertEqual("total recall", archived[0].name)
        
        XCTAssertEqual(.card, archived[0].snaps.last!.actions.first)
        
        if case let .content(card, text) = archived[0].snaps.last!.actions.last {
            XCTAssertEqual("hello world", text)
            XCTAssertEqual(.init(column: 0, order: 0), card)
        } else {
            XCTFail()
        }

        XCTAssertEqual(1, archived[1].snaps.count)
        XCTAssertEqual(1, archived[1].snaps.first!.actions.count)
        XCTAssertEqual(.create, archived[1].snaps.first!.actions.first!)
        XCTAssertEqual(300, Int(archived[1].snaps.first!.date.timeIntervalSince1970))
        XCTAssertEqual(.init(boardA.snaps[0].date.timeIntervalSince1970), Int(archived[1].snaps.last!.date.timeIntervalSince1970))
        
        XCTAssertEqual(3, archived[0].count)
        XCTAssertEqual("DO", archived[0][0].title)
        XCTAssertEqual("DOING", archived[0][1].title)
        XCTAssertEqual("DONE", archived[0][2].title)
    }
    
    func testVertical() {
        var column = Board.Column()
        column.cards = [.init(), .init()]
        var snap = Board.Snap(state: [column])
        snap.add(.vertical(.init(column: 0, order: 0), 1))
        XCTAssertEqual(snap, snap.data.mutating(transform: Board.Snap.init(data:)))
    }
}
