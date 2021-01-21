import Foundation

public struct Board: Codable, Identifiable {
    public var columns = [Column(name: "Do"), .init(name: "Doing"), .init(name: "Done")]
    public let id: String
    
    public init() {
        id = UUID().uuidString
    }
}
