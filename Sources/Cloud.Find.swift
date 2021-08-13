import Foundation
import Archivable

extension Cloud where A == Archive {
    public func find(search: String, completion: @escaping ([Found]) -> Void) {
        mutating(transform: { _ in
            []
        }, completion: completion)
    }
}


/*
 public func filter(_ string: String) -> [Filtered] {
     .init(self[string]
             .prefix(2))
 }
 
 subscript(_ string: String) -> [Filtered] {
     string
         .isEmpty
         ? map {
             .init(page: $0, matches: 0)
         }
         : Set({ components in
             map {
                 (page: $0, matches: $0
                     .matches(components))
             }
             .filter {
                 $0.matches > 0
             }
             .map {
                 .init(page: $0.page, matches: $0.matches)
             }
         } (string.components(separatedBy: " ")))
         .sorted()
 }
 */
