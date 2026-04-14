// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "Kakezan",
    platforms: [
        .iOS("15.2")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "Sources"
        )
    ]
)
