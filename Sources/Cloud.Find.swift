import Foundation
import Archivable

extension Cloud where A == Archive {
    public func find(search: String, completion: @escaping ([Found]) -> Void) {
        mutating(transform: { archive in
            search
                .components { components in
                    archive
                        .items
                        .enumerated()
                        .map {
                            .init(path: .board($0.0),
                                  breadcrumbs: "",
                                  content: $0.1.name,
                                  rating: $0.1.name.rating(components: components))
                        }
                        .filter {
                            $0.rating > 0
                        }
                        .sorted()
                }
        }, completion: completion)
    }
}

private extension String {
    func components<T>(transform: ([Self]) -> [T]) -> [T] {
        {
            $0.isEmpty ? [] : transform($0)
        } (trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: " ")
            .filter {
                !$0.isEmpty
            })
    }
    
    func rating(components: [String]) -> Int {
        components
            .filter(localizedCaseInsensitiveContains)
            .count
    }
}
