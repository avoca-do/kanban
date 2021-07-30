import Foundation
import Archivable

extension Cloud where A == Archive {
    public static var new: Self {
        .init(manifest: .init(
                file: file,
                container: "iCloud.avoca.do",
                prefix: "archive_",
                title: "Avocado"))
    }
}

#if DEBUG
    private let file = "avocado.debug.archive"
#else
    private let file = "avocado.archive"
#endif
