import Foundation

extension Board {
    struct Card: Equatable {
        let id: Int
        let content: String
        
        init(id: Int) {
            self.id = id
            content = ""
        }
        
        private init(id: Int, content: String) {
            self.id = id
            self.content = content
        }
        
        func with(content: String) -> Self {
            .init(id: id, content: content)
        }
    }
}
