import Foundation

extension Date {
    init(timestamp: UInt32) {
        self.init(timeIntervalSince1970: .init(timestamp))
    }
    
    var timestamp: UInt32 {
        .init(timeIntervalSince1970)
    }
}
