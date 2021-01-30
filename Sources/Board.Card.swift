import Foundation

extension Board {
    struct Card: Hashable {
        var content: String
        let id: UUID
        
        init() {
            content = ""
            id = .init()
        }
    }
}
