// swift-tools-version:5.7
import PackageDescription

let name = "MarkdownToJson"
let package = Package(
    name: name,
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: name,
            path: "",
            resources: []
        )
    ]
)
