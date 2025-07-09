import Foundation
import AVFoundation
import DogTVCore

@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
class AudioFileLoader {
    private let bundle = Bundle.main
    private var fileCache: [String: AVAudioFile] = [:]

    func loadAudioFile(named name: String, withExtension ext: String) throws -> AVAudioFile {
        let cacheKey = "\(name).\(ext)"
        if let cachedFile = fileCache[cacheKey] {
            return cachedFile
        }

        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            throw AudioError.fileNotFound
        }

        // Validate file before loading
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw AudioError.fileNotFound
        }

        let audioFile = try AVAudioFile(forReading: url)
        fileCache[cacheKey] = audioFile
        return audioFile
    }

    func loadAudioFiles(for scene: SceneType) throws -> [AVAudioFile] {
        switch scene {
        case .ocean:
            return [
                try loadAudioFile(named: "ocean_waves", withExtension: "mp3"),
                try loadAudioFile(named: "ocean_ambient", withExtension: "mp3")
            ]
        case .forest:
            return [
                try loadAudioFile(named: "forest_birds", withExtension: "mp3"),
                try loadAudioFile(named: "forest_wind", withExtension: "mp3")
            ]
        case .fireflies:
            return [
                try loadAudioFile(named: "night_ambient", withExtension: "mp3"),
                try loadAudioFile(named: "cricket_sounds", withExtension: "mp3")
            ]
        case .rain:
            return [
                try loadAudioFile(named: "rain_gentle", withExtension: "mp3"),
                try loadAudioFile(named: "thunder_distant", withExtension: "mp3")
            ]
        case .sunset:
            return [
                try loadAudioFile(named: "sunset_ambient", withExtension: "mp3"),
                try loadAudioFile(named: "evening_birds", withExtension: "mp3")
            ]
        case .stars:
            return [
                try loadAudioFile(named: "night_wind", withExtension: "mp3"),
                try loadAudioFile(named: "owl_sounds", withExtension: "mp3")
            ]
        }
    }
}
