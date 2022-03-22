import Foundation
import Archivable

extension Cloud where A == Archive {
    public func find(search: String, completion: @escaping ([Found]) -> Void) {
        transform(transforming: { archive in
            search
                .components { components in
                    archive
                        .find(components: components)
                        .sorted()
                }
        }, completion: completion)
    }
}

private extension Archive {
    func find(components: [String]) -> [Found] {
        elements(parent: nil, breadcrumbs: "") { board in
            .init(path: board.path,
                  breadcrumbs: board.breadcrumbs,
                  content: board.item.name,
                  components: components)
                + board.item.elements(parent: board.path, breadcrumbs: board.item.name + " :") { column in
                    .init(path: column.path,
                          breadcrumbs: column.breadcrumbs,
                          content: column.item.name,
                          components: components)
                        + column.item.elements(parent: column.path, breadcrumbs: column.breadcrumbs + " " + column.item.name + " :") { card in
                            .init(path: card.path,
                                  breadcrumbs: card.breadcrumbs,
                                  content: card.item.content,
                                  components: components)
                        }
                }
        }
    }
}

private extension Array where Element == Found? {
    static func + (lhs: Found?, rhs: Self) -> [Found] {
        var array = rhs
        array.append(lhs)
        return array
            .compactMap {
                $0
            }
    }
}

private extension Pather {
    func elements<T>(parent: Path?, breadcrumbs: String, transform: ((path: Path, breadcrumbs: String, item: Item)) -> [T]) -> [T] {
        describe(parent: parent, breadcrumbs: breadcrumbs)
            .flatMap(transform)
    }
    
    func elements<T>(parent: Path?, breadcrumbs: String, transform: ((path: Path, breadcrumbs: String, item: Item)) -> T) -> [T] {
        describe(parent: parent, breadcrumbs: breadcrumbs)
            .map(transform)
    }
    
    private func describe(parent: Path?, breadcrumbs: String) -> [(path: Path, breadcrumbs: String, item: Item)] {
        items
            .enumerated()
            .map {
                (path: parent == nil ? .board($0.0) : parent!.child(index: $0.0), breadcrumbs: breadcrumbs, item: $0.1)
            }
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
}
