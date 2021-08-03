import Foundation

extension Board {
    public struct Card: PatherItem {
        public let content: String
        let id: Int
        
        public init() {
            self.init(id: 0)
        }
        
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
