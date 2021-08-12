import Foundation
import Archivable

public struct Archive: Archived, Pather {
    public static let new = Self()
    public var date: Date
    
    public var available: Bool {
        capacity > items.count
    }
    
    public internal(set) var capacity = 1
    
    public var data: Data {
        Data()
            .adding(UInt8(items.count))
            .adding(items.flatMap(\.data))
            .adding(UInt16(capacity))
            .adding(date)
            .compressed
    }
    
    public var items: [Board]
    
    private init() {
        items = []
        date = .init()
    }
    
    public init(data: inout Data) {
        data.decompress()
        items = (0 ..< .init(data.removeFirst())).map { _ in
            .init(data: &data)
        }
        capacity = .init(data.uInt16())
        if data.isEmpty {
            date = items
                .map(\.date)
                .max()
                ?? .distantPast
        } else {
            date = .init(timestamp: data.uInt32())
        }
    }
    
    public func activity(period: Period) -> [Double] {
        items
            .flatMap(\.snaps)
            .map(\.state.date.timeIntervalSince1970)
            .plot(period: period)
    }
}
