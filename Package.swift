// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WarmShift",
    platforms: [.macOS(.v14)],
    targets: [
        // Pure schedule math, no AppKit, so it can be unit tested.
        .target(name: "WarmShiftCore", path: "Sources/WarmShiftCore"),
        .executableTarget(
            name: "WarmShift",
            dependencies: ["WarmShiftCore"],
            path: "Sources/WarmShift"
        ),
        .testTarget(
            name: "WarmShiftCoreTests",
            dependencies: ["WarmShiftCore"],
            path: "Tests/WarmShiftCoreTests"
        ),
    ]
)
