#!/usr/bin/env swift

import Foundation

/// Advanced performance profiler for DogTV+ build system optimization
struct PerformanceProfiler {
    
    struct BuildMetrics {
        let configuration: String
        let startTime: Date
        let endTime: Date
        let duration: TimeInterval
        let targetCount: Int
        let warningCount: Int
        let errorCount: Int
        let codeSize: Int64
        let memoryUsage: Int64
        
        var durationFormatted: String {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .abbreviated
            return formatter.string(from: duration) ?? "\(Int(duration))s"
        }
        
        var codeSizeFormatted: String {
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useMB, .useKB]
            formatter.countStyle = .file
            return formatter.string(fromByteCount: codeSize)
        }
    }
    
    static func profileBuild(configuration: String = "Debug") -> BuildMetrics {
        let startTime = Date()
        
        print("🔍 Starting performance profiling for \(configuration) configuration...")
        
        // Execute build and capture metrics
        let result = executeShellCommand("swift build --configuration \(configuration.lowercased()) --verbose")
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Parse build output for metrics
        let warningCount = countOccurrences(in: result.output, of: "warning:")
        let errorCount = countOccurrences(in: result.output, of: "error:")
        
        // Calculate code size
        let codeSize = calculateCodeSize()
        
        // Estimate memory usage
        let memoryUsage = estimateMemoryUsage()
        
        let metrics = BuildMetrics(
            configuration: configuration,
            startTime: startTime,
            endTime: endTime,
            duration: duration,
            targetCount: countSwiftFiles(),
            warningCount: warningCount,
            errorCount: errorCount,
            codeSize: codeSize,
            memoryUsage: memoryUsage
        )
        
        generatePerformanceReport(metrics: metrics)
        
        return metrics
    }
    
    static func profileAllConfigurations() {
        let configurations = ["Debug", "Release", "Testing"]
        var allMetrics: [BuildMetrics] = []
        
        print("🚀 Profiling all build configurations...")
        
        for config in configurations {
            let metrics = profileBuild(configuration: config)
            allMetrics.append(metrics)
        }
        
        generateComparativeReport(metrics: allMetrics)
    }
    
    private static func executeShellCommand(_ command: String) -> (output: String, exitCode: Int32) {
        let process = Process()
        let pipe = Pipe()
        
        process.standardOutput = pipe
        process.standardError = pipe
        process.arguments = ["-c", command]
        process.launchPath = "/bin/bash"
        
        process.launch()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        return (output, process.terminationStatus)
    }
    
    private static func countOccurrences(in text: String, of substring: String) -> Int {
        return text.components(separatedBy: substring).count - 1
    }
    
    private static func countSwiftFiles() -> Int {
        let result = executeShellCommand("find Sources -name '*.swift' | wc -l")
        return Int(result.output.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
    }
    
    private static func calculateCodeSize() -> Int64 {
        let result = executeShellCommand("find .build -name '*.o' -exec ls -l {} + | awk '{sum += $5} END {print sum}'")
        return Int64(result.output.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
    }
    
    private static func estimateMemoryUsage() -> Int64 {
        // Simplified memory usage estimation
        let result = executeShellCommand("du -sk .build | cut -f1")
        let kilobytes = Int64(result.output.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        return kilobytes * 1024
    }
    
    private static func generatePerformanceReport(metrics: BuildMetrics) {
        let report = """
        
        📊 BUILD PERFORMANCE REPORT - \(metrics.configuration)
        ════════════════════════════════════════════════════
        
        ⏱️  Build Duration: \(metrics.durationFormatted)
        📁  Targets Built: \(metrics.targetCount)
        ⚠️   Warnings: \(metrics.warningCount)
        ❌  Errors: \(metrics.errorCount)
        📦  Code Size: \(metrics.codeSizeFormatted)
        🧠  Memory Usage: \(ByteCountFormatter().string(fromByteCount: metrics.memoryUsage))
        
        Performance Grade: \(calculatePerformanceGrade(metrics))
        
        ════════════════════════════════════════════════════
        
        """
        
        print(report)
        
        // Save to file
        let fileName = "build_performance_\(metrics.configuration.lowercased())_\(dateFormatter.string(from: Date())).txt"
        try? report.write(toFile: fileName, atomically: true, encoding: .utf8)
    }
    
    private static func generateComparativeReport(metrics: [BuildMetrics]) {
        let report = """
        
        📈 COMPARATIVE BUILD PERFORMANCE ANALYSIS
        ════════════════════════════════════════════════════
        
        \(metrics.map { formatMetricsSummary($0) }.joined(separator: "\n"))
        
        🏆 FASTEST BUILD: \(metrics.min { $0.duration < $1.duration }?.configuration ?? "N/A")
        📦 SMALLEST SIZE: \(metrics.min { $0.codeSize < $1.codeSize }?.configuration ?? "N/A")
        🧠 LEAST MEMORY: \(metrics.min { $0.memoryUsage < $1.memoryUsage }?.configuration ?? "N/A")
        
        ════════════════════════════════════════════════════
        
        """
        
        print(report)
        
        // Save comparative report
        let fileName = "build_performance_comparison_\(dateFormatter.string(from: Date())).txt"
        try? report.write(toFile: fileName, atomically: true, encoding: .utf8)
    }
    
    private static func formatMetricsSummary(_ metrics: BuildMetrics) -> String {
        return """
        \(metrics.configuration.uppercased())
        └─ Duration: \(metrics.durationFormatted) | Size: \(metrics.codeSizeFormatted) | Grade: \(calculatePerformanceGrade(metrics))
        """
    }
    
    private static func calculatePerformanceGrade(_ metrics: BuildMetrics) -> String {
        var score = 100
        
        // Deduct points for build time
        if metrics.duration > 120 { score -= 30 }
        else if metrics.duration > 60 { score -= 15 }
        else if metrics.duration > 30 { score -= 5 }
        
        // Deduct points for warnings/errors
        score -= (metrics.warningCount * 2)
        score -= (metrics.errorCount * 10)
        
        // Deduct points for code size (if excessive)
        if metrics.codeSize > 50_000_000 { score -= 20 }
        else if metrics.codeSize > 25_000_000 { score -= 10 }
        
        switch score {
        case 95...100: return "A+ 🌟"
        case 90..<95: return "A 🎯"
        case 85..<90: return "B+ 👍"
        case 80..<85: return "B 📈"
        case 75..<80: return "C+ ⚡"
        case 70..<75: return "C 🔧"
        default: return "D ⚠️"
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
}

// Execute performance profiling
let arguments = CommandLine.arguments
if arguments.count > 1 && arguments[1] == "--all" {
    PerformanceProfiler.profileAllConfigurations()
} else {
    let config = arguments.count > 1 ? arguments[1] : "Debug"
    _ = PerformanceProfiler.profileBuild(configuration: config)
}