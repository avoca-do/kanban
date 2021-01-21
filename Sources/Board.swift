import Foundation

public struct Board: Codable, Identifiable {
    public var name: String
    public var columns = [Column(name: "Do"), .init(name: "Doing"), .init(name: "Done")]
    public let id: String
    
    public init(name: String) {
        self.name = name
        id = UUID().uuidString
    }
}
