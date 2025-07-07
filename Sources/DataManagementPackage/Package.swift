// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DataManagementPackage",
    platforms: [.tvOS(.v17)],
    products: [
        .library(name: "DataMigrationManager", targets: ["DataMigrationManager"]),
        .library(name: "DataBackupManager", targets: ["DataBackupManager"]),
        .library(name: "DataExportManager", targets: ["DataExportManager"]),
        .library(name: "DataIntegrityTestResults", targets: ["DataIntegrityTestResults"]),
        .library(name: "AnalyticsAccuracyTestResults", targets: ["AnalyticsAccuracyTestResults"])
    ],
    targets: [
        .target(name: "DataMigrationManager", path: "Sources/DataMigrationManager"),
        .target(name: "DataBackupManager", path: "Sources/DataBackupManager"),
        .target(name: "DataExportManager", path: "Sources/DataExportManager"),
        .target(name: "DataIntegrityTestResults", path: "Sources/DataIntegrityTestResults"),
        .target(name: "AnalyticsAccuracyTestResults", path: "Sources/AnalyticsAccuracyTestResults")
    ]
) 