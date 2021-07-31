import Foundation
import Archivable

public struct Archive: Archived, Pather {
    public static let new = Self()
    
    public var date: Date {
        get {
            items
                .compactMap(\.snaps.last)
                .map(\.state.date)
                .max()
                ?? .distantPast
        }
        set {
            
        }
    }
    
    public var available: Bool {
        capacity > items.count
    }
    
    public internal(set) var capacity = 1
    
    public var data: Data {
        Data()
            .adding(UInt8(items.count))
            .adding(items.flatMap(\.data))
            .adding(UInt16(capacity))
            .compressed
    }
    
    public var items: [Board]
    
    private init() {
        items = []
    }
    
    public init(data: inout Data) {
        data.decompress()
        items = (0 ..< .init(data.removeFirst())).map { _ in
            .init(data: &data)
        }
        capacity = .init(data.uInt16())
    }
    
    public subscript(activity period: Period) -> [[Double]] {
        let start = period.date.timeIntervalSince1970
        let interval = (Date().timeIntervalSince1970 - start) / .init(Period.divisions)
        let ranges = (0 ..< Period.divisions).map {
            (.init($0) * interval) + start
        }
        
        let array = items.map {
            $0.snaps
                .map(\.state.date.timeIntervalSince1970)
                .reduce(into: (Array(repeating: Double(), count: Period.divisions), 0)) {
                    while $0.1 < Period.divisions - 1 && ranges[$0.1 + 1] < $1 {
                        $0.1 += 1
                    }
                    if $1 >= ranges[$0.1] {
                        $0.0[$0.1] += 1
                    }
                }.0
        }
        
        let maximum = max(array.map {
            $0.max() ?? 1
        }.max() ?? 1, 1)
        
        return array.map {
            $0.map {
                $0 / maximum
            }
        }
    }
    
    public static func < (lhs: Archive, rhs: Archive) -> Bool {
        lhs.date < rhs.date || lhs.capacity < rhs.capacity
    }
}
