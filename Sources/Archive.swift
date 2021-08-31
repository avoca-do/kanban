import Foundation
import Archivable

public struct Archive: Archived, Pather {
    public static let new = Self()
    public var timestamp: UInt32
    
    public var available: Bool {
        capacity > items.count
    }
    
    public internal(set) var capacity = 1
    
    public var data: Data {
        Data()
            .adding(UInt8(items.count))
            .adding(items.flatMap(\.data))
            .adding(UInt16(capacity))
            .adding(timestamp)
            .compressed
    }
    
    public internal(set) var items: [Board]
    
    private init() {
        items = []
        timestamp = Date().timestamp
    }
    
    public init(data: inout Data) {
        data.decompress()
        items = (0 ..< .init(data.removeFirst())).map { _ in
            .init(data: &data)
        }
        capacity = .init(data.uInt16())
        if data.isEmpty {
            timestamp = items
                .map(\.date.timestamp)
                .max()
                ?? 0
        } else {
            timestamp = data.uInt32()
        }
    }
    
    public func activity(period: Period) -> [Double] {
        items
            .flatMap(\.snaps)
            .map(\.state.date.timeIntervalSince1970)
            .plot(period: period)
    }
}
