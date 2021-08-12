import Foundation
import Archivable

public struct Board: Property, Pather, PatherItem {
    public let name: String
    
    public var items: [Column] {
        snaps.last!.items
    }
    
    public var data: Data {
        Data()
            .adding(name)
            .adding(UInt16(snaps.count))
            .adding(snaps.map(\.state).flatMap(\.data))
    }
    
    public var date: Date {
        snaps
            .last
            .map(\.state.date)
            ?? .distantPast
    }
    
    public var progress: Progress {
        {
            Progress(cards: $0, done: $1, percentage: $0 > 0 ? .init($1) / .init($0) : 0)
        } (items
            .map(\.count)
            .reduce(0, +), items.last?.count ?? 0)
    }
    
    let snaps: [Snap]
    
    public init() {
        name = ""
        snaps = ([Snap]()).adding(action: .create)
    }
    
    public init(data: inout Data) {
        name = data.string()
        snaps = (0 ..< .init(data.uInt16())).reduce(into: []) { list, _ in
            list.append(Snap(data: &data, after: list.last))
        }
    }
    
    private init(name: String, snaps: [Snap]) {
        self.name = name
        self.snaps = snaps
    }
    
    public func activity(period: Period) -> [Double] {
        snaps
            .map(\.state.date.timeIntervalSince1970)
            .plot(period: period)
    }
    
    func with(name: String) -> Self {
        .init(name: name, snaps: snaps)
    }
    
    func with(snaps: [Snap]) -> Self {
        .init(name: name, snaps: snaps)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.items == rhs.items
    }
}
