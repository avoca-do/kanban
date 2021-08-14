import Foundation

public struct Found: Comparable {
    public let path: Path
    public let breadcrumbs: String
    public let content: String
    let rating: Int
    
    public static func < (lhs: Found, rhs: Found) -> Bool {
        lhs.rating == rhs.rating
            ? lhs.content.localizedCaseInsensitiveCompare(rhs.content) == .orderedAscending
            : lhs.rating > rhs.rating
    }
}
