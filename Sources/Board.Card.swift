import Foundation

extension Board {
    struct Card: Equatable {
        let id: Int
        let content: String
        
        init(id: Int) {
            self.id = id
            content = ""
        }
    }
}
