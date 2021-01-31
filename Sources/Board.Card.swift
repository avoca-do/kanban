import Foundation

extension Board {
    struct Card: Hashable {
        var content: String
        let id: UUID
        
        init() {
            content = ""
            id = .init()
        }
        
        public func hash(into: inout Hasher) {
            into.combine(content)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.content == rhs.content
        }
    }
}
