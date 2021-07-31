import Foundation

extension Board {
    public struct Card: PatherItem {
        let id: Int
        let content: String
        
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
