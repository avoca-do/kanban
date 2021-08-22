import Archivable

extension Cloud where A == Archive {
    public static var new: Self {
        .init(manifest: .init(
                file: "avocado",
                container: "iCloud.avoca.do",
                prefix: "archive_"))
    }
}
