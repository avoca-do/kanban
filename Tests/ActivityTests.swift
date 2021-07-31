import XCTest
@testable import Kanban

final class ActivityTests: XCTestCase {
    private var archive: Archive!
    
    override func setUp() {
        archive = .new
    }
    
    func testEmpty() {
        XCTAssertEqual([], archive[activity: .week])
    }
    
    func testWeek() {
        archive.items = [.init(), .init(), .init()]
        
        var data0 = Data()
            .adding(Date(timeIntervalSinceNow: -60 * 60 * 24 * 6).timestamp)
            .adding(UInt8(archive.items[0].snaps[0].state.actions.count))
            .adding(archive.items[0].snaps[0].state.actions.flatMap(\.data))
        var data1 = Data()
            .adding(Date(timeIntervalSinceNow: -60 * 60 * 24 * 5).timestamp)
            .adding(UInt8(0))
        archive
            .items
            .mutate(index: 0) {
                $0
                    .with(snaps: [.init(data: &data0, after: nil)])
            }
        archive
            .items
            .mutate(index: 0) {
                $0.with(snaps: $0
                                .snaps
                                .adding(action: .card))
            }
        archive
            .items
            .mutate(index: 0) {
                $0
                    .with(snaps: [$0.snaps[0], .init(data: &data1, after: nil)])
            }
        
        data0 = Data()
            .adding(Date(timeIntervalSinceNow: -60 * 60 * 24 * 3).timestamp)
            .adding(UInt8(archive.items[1].snaps[0].state.actions.count))
            .adding(archive.items[1].snaps[0].state.actions.flatMap(\.data))
        data1 = Data()
            .adding(Date(timeIntervalSinceNow: -60 * 60 * 24 * 2).timestamp)
            .adding(UInt8(0))
        archive
            .items
            .mutate(index: 1) {
                $0
                    .with(snaps: [.init(data: &data0, after: nil)])
            }
        archive
            .items
            .mutate(index: 1) {
                $0.with(snaps: $0
                                .snaps
                                .adding(action: .card))
            }
        archive
            .items
            .mutate(index: 1) {
                $0
                    .with(snaps: [$0.snaps[0], .init(data: &data1, after: nil)])
            }
        
        XCTAssertEqual([
                        [1, 1, 0, 0, 0],
                        [0, 0, 1, 1, 0],
                        [0, 0, 0, 0, 1]], archive[activity: .week])
    }
    
    func testIgnoreOlder() {
        archive.items = [.init()]
        
        var data = Data()
            .adding(Date(timeIntervalSinceNow: -60 * 60 * 24 * 2).timestamp)
            .adding(UInt8(archive.items[0].snaps[0].state.actions.count))
            .adding(archive.items[0].snaps[0].state.actions.flatMap(\.data))
        archive
            .items
            .mutate(index: 0) {
                $0
                    .with(snaps: [.init(data: &data, after: nil)])
            }
        
        XCTAssertEqual([[0, 0, 0, 0, 0]], archive[activity: .day])
    }
}
