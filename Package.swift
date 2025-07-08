// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DogTVPlus",
    platforms: [
        .tvOS(.v17),
        .iOS(.v17)
    ],
    products: [
        .library(name: "DogTVCore", targets: ["DogTVCore"]),
        .library(name: "DogTVUI", targets: ["DogTVUI"]),
        .library(name: "DogTVAudio", targets: ["DogTVAudio"]),
        .library(name: "DogTVVision", targets: ["DogTVVision"]),
        .library(name: "DogTVBehavior", targets: ["DogTVBehavior"]),
        .library(name: "DogTVData", targets: ["DogTVData"]),
        .library(name: "DogTVSecurity", targets: ["DogTVSecurity"]),
        .library(name: "DogTVAnalytics", targets: ["DogTVAnalytics"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        // Core business logic
        .target(
            name: "DogTVCore",
            dependencies: [],
            path: "Sources/DogTVCore"
        ),
        
        // UI components
        .target(
            name: "DogTVUI",
            dependencies: ["DogTVCore", "DogTVVision"],
            path: "Sources/DogTVUI"
        ),
        
        // Audio processing
        .target(
            name: "DogTVAudio",
            dependencies: ["DogTVCore"],
            path: "Sources/DogTVAudio"
        ),
        
        // Visual rendering
        .target(
            name: "DogTVVision",
            dependencies: ["DogTVCore"],
            path: "Sources/DogTVVision",
            exclude: ["Shaders.metal"],
            resources: [.process("CanineOptimizedShaders.metal")]
        ),
        
        // Behavior analysis
        .target(
            name: "DogTVBehavior",
            dependencies: ["DogTVCore", "DogTVData"],
            path: "Sources/DogTVBehavior"
        ),
        
        // Data management
        .target(
            name: "DogTVData",
            dependencies: ["DogTVCore"],
            path: "Sources/DogTVData"
        ),
        
        // Security & privacy
        .target(
            name: "DogTVSecurity",
            dependencies: ["DogTVCore"],
            path: "Sources/DogTVSecurity"
        ),
        
        // Analytics & monitoring
        .target(
            name: "DogTVAnalytics",
            dependencies: ["DogTVCore", "DogTVData"],
            path: "Sources/DogTVAnalytics"
        ),
        
        // Tests
        .testTarget(
            name: "DogTVCoreTests",
            dependencies: ["DogTVCore"],
            path: "Tests/DogTVCoreTests"
        ),
        .testTarget(
            name: "DogTVUITests",
            dependencies: ["DogTVUI"],
            path: "Tests/DogTVUITests"
        ),
        .testTarget(
            name: "DogTVVisionTests",
            dependencies: ["DogTVVision"],
            path: "Tests/DogTVVisionTests"
        ),
        .testTarget(
            name: "DogTVDataTests",
            dependencies: ["DogTVData"],
            path: "Tests/DogTVDataTests"
        ),
        .testTarget(
            name: "DogTVSecurityTests",
            dependencies: ["DogTVSecurity"],
            path: "Tests/DogTVSecurityTests"
        )
    ]
) 