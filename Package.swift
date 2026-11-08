// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Rapihin",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "Rapihin",
            path: "Sources/Rapihin"
        ),
        .testTarget(
            name: "RapihinTests",
            dependencies: ["Rapihin"],
            path: "Tests/RapihinTests"
        ),
    ]
)
