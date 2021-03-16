// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Kanban",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "Kanban",
            targets: ["Kanban"]),
    ],
    dependencies: [
        .package(name: "Archivable", url: "https://github.com/archivable/package.git", .branch("main"))
    ],
    targets: [
        .target(
            name: "Kanban",
            dependencies: ["Archivable"],
            path: "Sources"),
        .testTarget(
            name: "Tests",
            dependencies: ["Kanban"],
            path: "Tests"),
    ]
)
