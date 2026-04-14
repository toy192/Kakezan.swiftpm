// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Kakezan",
    platforms: [
        .iOS("16.0")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "Sources"
        )
    ]
)
