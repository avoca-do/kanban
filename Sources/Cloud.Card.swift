import Foundation
import Archivable

extension Cloud where A == Archive {
    public mutating func update(board: Int, column: Int, card: Int, content: String) {
        let content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        mutating {
            guard $0[board][column][card].content != content else { return }
            $0
                .items
                .mutate(index: board) {
                    $0
                        .with(snaps: $0
                                .snaps
                                .adding(action: .content($0[column][card].id, content)))
                }
        }
    }
    
    public mutating func move(board: Int, column: Int, card: Int, vertical: Int) {
        guard card != vertical else { return }
        mutating {
            $0
                .items
                .mutate(index: board) {
                    $0
                        .with(snaps: $0
                                .snaps
                                .adding(action: .vertical($0[column][card].id, vertical)))
                }
        }
    }
    
    public mutating func move(board: Int, column: Int, card: Int, horizontal: Int) {
        guard column != horizontal else { return }
        mutating {
            $0
                .items
                .mutate(index: board) {
                    $0
                        .with(snaps: $0
                                .snaps
                                .adding(action: .horizontal($0[column][card].id, horizontal)))
                }
        }
    }
    
    public mutating func delete(board: Int, column: Int, card: Int) {
        mutating {
            guard
                $0.count > board,
                $0[board].count > column,
                $0[board][column].count > card
            else { return }
            $0
                .items
                .mutate(index: board) {
                    $0
                        .with(snaps: $0
                                .snaps
                                .adding(action: .remove($0[column][card].id)))
                }
        }
    }
    
    
    mutating func remove(_ path: Path) {
//        guard snap.path(self[path][path].id) != nil else { return }
//        add(.remove(self[path][path].id))
    }
    
    /*
     subscript(content path: Path) -> String {
         get {
             self[path][path].content
         }
         set {
             let content = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
             guard
                 !content.isEmpty,
                 content != self[path][path].content
             else { return }
             add(.content(self[path][path].id, content))
         }
     }
     
     subscript(title path: Path) -> String {
         get {
             self[path].title
         }
         set {
             let title = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
             guard
                 !title.isEmpty,
                 title != self[path].title
             else { return }
             add(.title(path._column, title))
         }
     }
     
     */
    
    
    
//    public func browse(_ search: String, browse: Int?, completion: @escaping (Int, Page.Access) -> Void) {
//        mutating {
//            $0.browse(search, browse: browse)
//        } completion: {
//            completion($0.browse, $0.access)
//        }
//    }
//
//    public func navigate(_ url: URL, completion: @escaping (Int, Page.Access) -> Void) {
//        mutating {
//            let access = Page.Access(url: url)
//            return ($0.add(access), access)
//        } completion: { (browse: Int, access: Page.Access) in
//            completion(browse, access)
//        }
//    }
//
//    public func revisit(_ browse: Int) {
//        mutating {
//            guard let browse = $0.browses.remove(where: { $0.id == browse })?.revisit else { return }
//            $0.browses.insert(browse, at: 0)
//        }
//    }
//
//    public func update(_ browse: Int, title: String) {
//        mutating {
//            guard let page = $0.browses.remove(where: { $0.id == browse })?
//                    .with(title: title.trimmingCharacters(in: .whitespacesAndNewlines)) else { return }
//            $0.browses.insert(page, at: 0)
//        }
//    }
//
//    public func update(_ browse: Int, url: URL) {
//        mutating {
//            guard let page = $0.browses.remove(where: { $0.id == browse })?
//                    .with(access: .init(url: url)) else { return }
//            $0.browses.insert(page, at: 0)
//        }
//    }
//
//    public func open(_ bookmark: Int, completion: @escaping (Int) -> Void) {
//        mutating(transform: { archive in
//            guard bookmark < archive.bookmarks.count else { return nil }
//            return archive.add(archive.bookmarks[bookmark].access)
//        }, completion: completion)
//    }
}
