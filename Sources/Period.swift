import Foundation

public enum Period {
    case
    hour,
    day,
    week,
    month,
    year
    
    public var date: Date {
        switch self {
        case .hour: return Calendar.current.date(byAdding: .hour, value: -1, to: .init())!
        case .day: return Calendar.current.date(byAdding: .day, value: -1, to: .init())!
        case .week: return Calendar.current.date(byAdding: .day, value: -7, to: .init())!
        case .month: return Calendar.current.date(byAdding: .month, value: -1, to: .init())!
        case .year: return Calendar.current.date(byAdding: .year, value: -1, to: .init())!
        }
    }
    
    static let divisions = 6
}
