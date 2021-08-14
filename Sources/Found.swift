import Foundation

public struct Found: Comparable {
    public let path: Path
    public let breadcrumbs: String
    public let content: String
    private let rating: Int
    
    init?(path: Path, breadcrumbs: String, content: String, components: [String]) {
        rating = content.rating(components: components)
        guard rating > 0 else { return nil }
        self.path = path
        self.breadcrumbs = breadcrumbs
        self.content = content
    }
    
    public static func < (lhs: Found, rhs: Found) -> Bool {
        lhs.rating == rhs.rating
            ? lhs.content.localizedCaseInsensitiveCompare(rhs.content) == .orderedAscending
            : lhs.rating > rhs.rating
    }
}

private extension String {   
    func rating(components: [String]) -> Int {
        components
            .filter(localizedCaseInsensitiveContains)
            .count
    }
}
