// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BehaviorAnalysisPackage",
    platforms: [.tvOS(.v17)],
    products: [
        .library(
            name: "BehaviorAnalysisPackage",
            targets: ["BehaviorAnalysisPackage"]
        ),
    ],
    targets: [
        .target(
            name: "BehaviorAnalysisPackage",
            path: "Sources/BehaviorAnalysisPackage"
        ),
        .testTarget(
            name: "BehaviorAnalysisPackageTests",
            dependencies: ["BehaviorAnalysisPackage"],
            path: "Tests/BehaviorAnalysisPackageTests"
        ),
    ]
) 