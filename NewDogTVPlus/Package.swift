// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DogTVPlus",
    platforms: [
        .tvOS(.v17),
        .iOS(.v17), // For development/testing
        .macOS(.v13) // For development/testing
    ],
    products: [
        .library(name: "DogTVPlusCore", targets: ["DogTVPlusCore"]),
        .library(name: "DogTVPlusUI", targets: ["DogTVPlusUI"]),
        .library(name: "DogTVPlusAudio", targets: ["DogTVPlusAudio"]),
        .library(name: "DogTVPlusVision", targets: ["DogTVPlusVision"]),
        .library(name: "DogTVPlusData", targets: ["DogTVPlusData"]),
    ],
    dependencies: [
        // Documentation
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
        // Testing
        .package(url: "https://github.com/Quick/Nimble", from: "13.0.0"),
        .package(url: "https://github.com/Quick/Quick", from: "7.0.0"),
        // Utilities
        .package(url: "https://github.com/realm/SwiftLint", from: "0.55.1")
    ],
    targets: [
        // MARK: - Core Module (Foundation)
        .target(
            name: "DogTVPlusCore",
            dependencies: [],
            path: "Sources/DogTVPlusCore",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        
        // MARK: - Data Module
        .target(
            name: "DogTVPlusData",
            dependencies: ["DogTVPlusCore"],
            path: "Sources/DogTVPlusData"
        ),
        
        // MARK: - Audio Module
        .target(
            name: "DogTVPlusAudio",
            dependencies: ["DogTVPlusCore"],
            path: "Sources/DogTVPlusAudio"
        ),
        
        // MARK: - Vision Module
        .target(
            name: "DogTVPlusVision",
            dependencies: ["DogTVPlusCore"],
            path: "Sources/DogTVPlusVision",
            resources: [.process("Resources")],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .unsafeFlags(["-warnings-as-errors"])
            ],
            plugins: [.plugin(name: "SwiftLintBuildTool", package: "SwiftLint")]
        ),
        
        // MARK: - UI Module
        .target(
            name: "DogTVPlusUI",
            dependencies: ["DogTVPlusCore"],
            path: "Sources/DogTVPlusUI",
            resources: [.process("Resources")],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .unsafeFlags(["-warnings-as-errors"])
            ],
            plugins: [.plugin(name: "SwiftLintBuildTool", package: "SwiftLint")]
        ),
        
        // MARK: - Test Targets
        .testTarget(
            name: "DogTVPlusCoreTests",
            dependencies: ["DogTVPlusCore", "Quick", "Nimble"],
            path: "Tests/DogTVPlusCoreTests",
            swiftSettings: [
                .define("ENABLE_TEST_COVERAGE")
            ]
        ),
        .testTarget(
            name: "DogTVPlusAudioTests",
            dependencies: ["DogTVPlusAudio"],
            path: "Tests/DogTVPlusAudioTests"
        ),
        .testTarget(
            name: "DogTVPlusVisionTests",
            dependencies: ["DogTVPlusVision", "Quick", "Nimble"],
            path: "Tests/DogTVPlusVisionTests",
            swiftSettings: [
                .define("ENABLE_TEST_COVERAGE")
            ]
        ),
        .testTarget(
            name: "DogTVPlusUITests",
            dependencies: ["DogTVPlusUI"],
            path: "Tests/DogTVPlusUITests"
        ),
        .testTarget(
            name: "DogTVPlusDataTests",
            dependencies: ["DogTVPlusData"],
            path: "Tests/DogTVPlusDataTests"
        )
    ]
)
