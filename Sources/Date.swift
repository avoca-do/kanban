import Foundation

extension Date {
    var timestamp: UInt32 {
        .init(timeIntervalSince1970)
    }
}
