import Foundation

private let divisions = 10

extension Array where Element == TimeInterval {
    func plot(period: Period) -> [Double] {
        let start = period.date.timeIntervalSince1970
        let interval = (Date().timeIntervalSince1970 - start) / .init(divisions)
        let ranges = (0 ..< divisions)
            .map {
                (.init($0) * interval) + start
            }
        var index = 0
        let array = filter {
            $0 >= start
        }
        .reduce(into: Array(repeating: .init(), count: divisions)) {
            while index < divisions - 1 && ranges[index + 1] < $1 {
                index += 1
            }
            $0[index] += 1
        }
        
        let top = Swift.max(array.max()!, 1)
        return array
            .map {
                $0 / top
            }
    }
}
