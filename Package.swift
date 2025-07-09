// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DogTVPlus",
    defaultLocalization: "en",
    platforms: [
        .tvOS(.v17),
        .iOS(.v17),
        .macOS(.v14), // Updated for better development support
        .watchOS(.v10), // Added watchOS support for future expansion
        .visionOS(.v1) // Added visionOS support
    ],
    
    // MARK: - Products
    products: [
        .library(name: "DogTVCore", targets: ["DogTVCore"]),
        .library(name: "DogTVUI", targets: ["DogTVUI"]),
        .library(name: "DogTVAudio", targets: ["DogTVAudio"]),
        .library(name: "DogTVVision", targets: ["DogTVVision"]),
        .library(name: "DogTVData", targets: ["DogTVData"]),
    ],
    
    // MARK: - Dependencies
    dependencies: [
        // Documentation
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
        
        // Testing Framework
        .package(url: "https://github.com/Quick/Nimble", exact: "13.0.0"),
        .package(url: "https://github.com/Quick/Quick", exact: "7.0.0"),
        
        // Code Quality & Linting
        .package(url: "https://github.com/realm/SwiftLint", exact: "0.55.1"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.52.0"),
        
        // Performance & Monitoring
        // .package(url: "https://github.com/uber/ios-snapshot-test-case", from: "8.0.0"),
        
        // Async & Utilities
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.0"),
        
        // Security & Cryptography
        .package(url: "https://github.com/apple/swift-crypto", from: "3.0.0"),
        
        // Logging & Analytics
        .package(url: "https://github.com/apple/swift-log", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-metrics", from: "2.4.0"),
    ],
    // MARK: - Targets
    targets: [
        // MARK: - Core Module
        .target(
            name: "DogTVCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Crypto", package: "swift-crypto"),
                "DogTVData"
            ],
            path: "Sources/DogTVCore",
            resources: [.process("Resources")],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableExperimentalFeature("AccessLevelOnImport"),
                .define("DOGTV_CORE_MODULE"),
                .define("SWIFT_PACKAGE", .when(configuration: .release))
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("Combine"),
                .linkedFramework("OSLog")
            ]
        ),
        
        // MARK: - UI Module
        .target(
            name: "DogTVUI",
            dependencies: [
                "DogTVCore",
                "DogTVVision",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ],
            path: "Sources/DogTVUI",
            resources: [.process("Resources")],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .define("DOGTV_UI_MODULE"),
                .define("METAL_ENABLED", .when(platforms: [.tvOS, .iOS, .macOS]))
            ],
            linkerSettings: [
                .linkedFramework("SwiftUI"),
                .linkedFramework("UIKit", .when(platforms: [.iOS, .tvOS])),
                .linkedFramework("AppKit", .when(platforms: [.macOS])),
                .linkedFramework("Metal"),
                .linkedFramework("MetalKit")
            ]
        ),
        
        // MARK: - Audio Module
        .target(
            name: "DogTVAudio",
            dependencies: [
                "DogTVCore",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ],
            path: "Sources/DogTVAudio",
            resources: [.process("Resources")],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .define("DOGTV_AUDIO_MODULE"),
                .define("CANINE_OPTIMIZED_AUDIO"),
                .define("ACCELERATE_ENABLED", .when(platforms: [.tvOS, .iOS, .macOS]))
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("AudioToolbox"),
                .linkedFramework("Accelerate"),
                .linkedFramework("CoreAudio"),
                .linkedFramework("MediaPlayer", .when(platforms: [.iOS, .tvOS]))
            ]
        ),
        
        // MARK: - Vision Module
        .target(
            name: "DogTVVision",
            dependencies: [
                "DogTVCore",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ],
            path: "Sources/DogTVVision",
            resources: [
                .process("Shaders"),
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .define("DOGTV_VISION_MODULE"),
                .define("METAL_SHADERS_ENABLED"),
                .define("PROCEDURAL_CONTENT_GENERATION")
            ],
            linkerSettings: [
                .linkedFramework("Metal"),
                .linkedFramework("MetalKit"),
                .linkedFramework("MetalPerformanceShaders"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("CoreImage"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("simd")
            ]
        ),
        
        // MARK: - Data Module
        .target(
            name: "DogTVData",
            dependencies: [
                // "DogTVCore", // Remove this dependency to break the cycle
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Crypto", package: "swift-crypto")
            ],
            path: "Sources/DogTVData",
            resources: [.process("Resources")],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .define("DOGTV_DATA_MODULE"),
                .define("SECURE_STORAGE_ENABLED"),
                .define("CORE_DATA_ENABLED", .when(platforms: [.tvOS, .iOS, .macOS]))
            ],
            linkerSettings: [
                .linkedFramework("CoreData"),
                .linkedFramework("CloudKit"),
                .linkedFramework("Security"),
                .linkedFramework("LocalAuthentication")
            ]
        ),
        
        // MARK: - Test Targets
        .testTarget(
            name: "DogTVCoreTests",
            dependencies: [
                "DogTVCore",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble")
            ],
            path: "Tests/DogTVCoreTests",
            resources: [.process("TestResources")],
            swiftSettings: [
                .define("ENABLE_TEST_COVERAGE"),
                .define("TESTING_ENVIRONMENT"),
                .define("MOCK_SERVICES_ENABLED")
            ]
        ),
        .testTarget(
            name: "DogTVUITests",
            dependencies: [
                "DogTVUI",
                "DogTVCore",
                "DogTVVision",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble")
                // .product(name: "iOSSnapshotTestCase", package: "ios-snapshot-test-case")
            ],
            path: "Tests/DogTVUITests",
            resources: [.process("TestResources")],
            swiftSettings: [
                .define("ENABLE_TEST_COVERAGE"),
                .define("UI_TESTING_ENABLED"),
                .define("SNAPSHOT_TESTING_ENABLED")
            ]
        ),
        .testTarget(
            name: "DogTVAudioTests",
            dependencies: [
                "DogTVAudio",
                "DogTVCore",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble")
            ],
            path: "Tests/DogTVAudioTests",
            resources: [.process("TestResources")],
            swiftSettings: [
                .define("ENABLE_TEST_COVERAGE"),
                .define("AUDIO_TESTING_ENABLED"),
                .define("PERFORMANCE_TESTING_ENABLED")
            ]
        ),
        .testTarget(
            name: "DogTVVisionTests",
            dependencies: [
                "DogTVVision",
                "DogTVCore",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble")
            ],
            path: "Tests/DogTVVisionTests",
            resources: [.process("TestResources")],
            swiftSettings: [
                .define("ENABLE_TEST_COVERAGE"),
                .define("METAL_TESTING_ENABLED"),
                .define("SHADER_TESTING_ENABLED")
            ]
        ),
        .testTarget(
            name: "DogTVDataTests",
            dependencies: [
                "DogTVData",
                "DogTVCore",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble")
            ],
            path: "Tests/DogTVDataTests",
            resources: [.process("TestResources")],
            swiftSettings: [
                .define("ENABLE_TEST_COVERAGE"),
                .define("DATA_TESTING_ENABLED"),
                .define("SECURITY_TESTING_ENABLED")
            ]
        ),
        .testTarget(
            name: "DogTVIntegrationTests",
            dependencies: [
                "DogTVCore",
                "DogTVUI",
                "DogTVAudio",
                "DogTVVision",
                "DogTVData",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble")
            ],
            path: "Tests/DogTVIntegrationTests",
            resources: [.process("TestResources")],
            swiftSettings: [
                .define("ENABLE_TEST_COVERAGE"),
                .define("INTEGRATION_TESTING_ENABLED"),
                .define("END_TO_END_TESTING_ENABLED")
            ]
        ),
        
        // MARK: - Performance Test Target
        .testTarget(
            name: "DogTVPerformanceTests",
            dependencies: [
                "DogTVCore",
                "DogTVAudio",
                "DogTVVision"
            ],
            path: "Tests/DogTVPerformanceTests",
            swiftSettings: [
                .define("PERFORMANCE_TESTING_ENABLED"),
                .define("BENCHMARK_TESTING_ENABLED")
            ]
        )
    ]
)

// MARK: - Development Tools
#if canImport(PackagePlugin)
import PackagePlugin

// SwiftLint plugin for code quality
extension Package {
    mutating func addSwiftLintPlugin() {
        plugins = [
            .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
        ]
    }
}
#endif