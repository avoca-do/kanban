import Foundation

public enum Period: Hashable {
    case
    year,
    month,
    week,
    day,
    custom(Date)
    
    public var date: Date {
        switch self {
        case .day:
            return Calendar.current.date(byAdding: .day, value: -1, to: .init())!
        case .week:
            return Calendar.current.date(byAdding: .day, value: -7, to: .init())!
        case .month:
            return Calendar.current.date(byAdding: .month, value: -1, to: .init())!
        case .year:
            return Calendar.current.date(byAdding: .year, value: -1, to: .init())!
        case let .custom(date):
            return date
        }
    }
}
