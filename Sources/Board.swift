import Foundation

public struct Board: Codable, Identifiable, Hashable {
    public var name: String
    public var columns = [Column(name: "DO"), .init(name: "DOING"), .init(name: "DONE")]
    public let id: String
    
    public init(name: String) {
        self.name = name
        id = UUID().uuidString
    }
}
