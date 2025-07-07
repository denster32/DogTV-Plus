import AVKit
import AVFoundation
import SwiftUI
import Combine

/// A comprehensive video playback system for DogTV+ with support for multiple formats and quality levels
public class VideoPlayerSystem: ObservableObject {
    @Published public var player: AVPlayer?
    @Published public var isPlaying: Bool = false
    @Published public var currentTime: Double = 0
    @Published public var duration: Double = 0
    @Published public var isLoading: Bool = false
    @Published public var bufferingProgress: Double = 0
    @Published public var videoQuality: VideoQuality = .auto
    @Published public var volume: Float = 1.0
    @Published public var isMuted: Bool = false
    @Published public var error: VideoPlayerError?
    
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    private var currentURL: URL?
    
    public enum VideoQuality: String, CaseIterable {
        case auto = "Auto"
        case p720 = "720p"
        case p1080 = "1080p"
        case p4k = "4K"
        
        var bitrate: Int {
            switch self {
            case .auto: return 0
            case .p720: return 2000000
            case .p1080: return 5000000
            case .p4k: return 15000000
            }
        }
    }
    
    public enum VideoPlayerError: Error, LocalizedError {
        case invalidURL
        case playbackFailed
        case networkError
        case unsupportedFormat
        case insufficientStorage
        
        public var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid video URL"
            case .playbackFailed:
                return "Video playback failed"
            case .networkError:
                return "Network connection error"
            case .unsupportedFormat:
                return "Unsupported video format"
            case .insufficientStorage:
                return "Insufficient storage space"
            }
        }
    }
    
    public init() {
        setupPlayer()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Public Methods
    
    /// Load and play a video from the given URL
    public func playVideo(url: URL) {
        guard url.isValid else {
            error = .invalidURL
            return
        }
        
        isLoading = true
        error = nil
        currentURL = url
        
        // Create new player item
        let playerItem = AVPlayerItem(url: url)
        
        // Configure quality settings
        configureQualitySettings(for: playerItem)
        
        // Create player if needed
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
        
        // Setup observers
        setupPlayerObservers()
        
        // Start playback
        playVideo()
    }
    
    /// Pause video playback
    public func pauseVideo() {
        player?.pause()
        isPlaying = false
    }
    
    /// Resume video playback
    public func playVideo() {
        player?.play()
        isPlaying = true
    }
    
    /// Seek to specific time in the video
    public func seekTo(time: Double) {
        let targetTime = CMTime(seconds: time, preferredTimescale: 1)
        player?.seek(to: targetTime) { [weak self] finished in
            if finished {
                self?.currentTime = time
            }
        }
    }
    
    /// Set video volume (0.0 to 1.0)
    public func setVolume(_ volume: Float) {
        self.volume = max(0.0, min(1.0, volume))
        player?.volume = self.volume
    }
    
    /// Toggle mute state
    public func toggleMute() {
        isMuted.toggle()
        player?.isMuted = isMuted
    }
    
    /// Change video quality
    public func setVideoQuality(_ quality: VideoQuality) {
        videoQuality = quality
        if let currentItem = player?.currentItem {
            configureQualitySettings(for: currentItem)
        }
    }
    
    /// Generate thumbnail for current video
    public func generateThumbnail(at time: Double = 0) -> UIImage? {
        guard let playerItem = player?.currentItem else { return nil }
        
        let asset = playerItem.asset
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: time, preferredTimescale: 1), actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }
    
    /// Cache video for offline playback
    public func cacheVideo(url: URL) async throws {
        // Implementation for video caching
        // This would download the video to local storage
    }
    
    // MARK: - Private Methods
    
    private func setupPlayer() {
        // Configure audio session for background playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    private func setupPlayerObservers() {
        guard let player = player else { return }
        
        // Time observer
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
        
        // Status observer
        player.currentItem?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .readyToPlay:
                    self?.isLoading = false
                    self?.duration = player.currentItem?.duration.seconds ?? 0
                case .failed:
                    self?.isLoading = false
                    self?.error = .playbackFailed
                case .unknown:
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // Buffering observer
        player.currentItem?.publisher(for: \.loadedTimeRanges)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ranges in
                self?.updateBufferingProgress(ranges: ranges)
            }
            .store(in: &cancellables)
    }
    
    private func updateBufferingProgress(ranges: [NSValue]) {
        guard let timeRange = ranges.first?.timeRangeValue else { return }
        let bufferedDuration = timeRange.duration.seconds
        let totalDuration = duration > 0 ? duration : 1
        bufferingProgress = min(bufferedDuration / totalDuration, 1.0)
    }
    
    private func configureQualitySettings(for playerItem: AVPlayerItem) {
        // Configure quality settings based on selected quality
        if videoQuality != .auto {
            // Set preferred peak bit rate
            playerItem.preferredPeakBitRate = Double(videoQuality.bitrate)
        }
        
        // Enable automatic switching for adaptive streaming
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
    }
    
    private func cleanup() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        cancellables.removeAll()
        player = nil
    }
}

// MARK: - Extensions

extension URL {
    var isValid: Bool {
        return self.absoluteString.hasPrefix("http") || self.absoluteString.hasPrefix("file")
    }
}

// MARK: - Video Player View

public struct VideoPlayerView: View {
    @ObservedObject var videoPlayer: VideoPlayerSystem
    @State private var showControls = false
    @State private var controlsTimer: Timer?
    
    public init(videoPlayer: VideoPlayerSystem) {
        self.videoPlayer = videoPlayer
    }
    
    public var body: some View {
        ZStack {
            // Video player
            if let player = videoPlayer.player {
                AVPlayerControllerRepresentable(player: player)
                    .onTapGesture {
                        toggleControls()
                    }
            } else {
                // Placeholder
                Rectangle()
                    .fill(Color.black)
                    .overlay(
                        VStack {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                            Text("No Video")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    )
            }
            
            // Loading indicator
            if videoPlayer.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
            
            // Error view
            if let error = videoPlayer.error {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                    Text(error.localizedDescription)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            
            // Video controls
            if showControls {
                VideoControlsView(videoPlayer: videoPlayer)
                    .transition(.opacity)
            }
        }
        .onAppear {
            startControlsTimer()
        }
        .onDisappear {
            stopControlsTimer()
        }
    }
    
    private func toggleControls() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showControls.toggle()
        }
        startControlsTimer()
    }
    
    private func startControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                showControls = false
            }
        }
    }
    
    private func stopControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = nil
    }
}

// MARK: - AVPlayerController Representable

struct AVPlayerControllerRepresentable: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}

// MARK: - Video Controls View

struct VideoControlsView: View {
    @ObservedObject var videoPlayer: VideoPlayerSystem
    
    var body: some View {
        VStack {
            // Top controls
            HStack {
                Button(action: {
                    // Back button action
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Quality selector
                Menu {
                    ForEach(VideoPlayerSystem.VideoQuality.allCases, id: \.self) { quality in
                        Button(quality.rawValue) {
                            videoPlayer.setVideoQuality(quality)
                        }
                    }
                } label: {
                    Text(videoPlayer.videoQuality.rawValue)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                }
            }
            .padding()
            
            Spacer()
            
            // Center play/pause button
            Button(action: {
                if videoPlayer.isPlaying {
                    videoPlayer.pauseVideo()
                } else {
                    videoPlayer.playVideo()
                }
            }) {
                Image(systemName: videoPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Bottom controls
            VStack(spacing: 12) {
                // Progress bar
                ProgressView(value: videoPlayer.currentTime, total: videoPlayer.duration)
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .padding(.horizontal)
                
                HStack {
                    // Time labels
                    Text(formatTime(videoPlayer.currentTime))
                        .foregroundColor(.white)
                        .font(.caption)
                    
                    Spacer()
                    
                    // Volume and mute controls
                    HStack(spacing: 16) {
                        Button(action: {
                            videoPlayer.toggleMute()
                        }) {
                            Image(systemName: videoPlayer.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .foregroundColor(.white)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(videoPlayer.volume) },
                            set: { videoPlayer.setVolume(Float($0)) }
                        ), in: 0...1)
                        .frame(width: 100)
                    }
                    
                    Spacer()
                    
                    Text(formatTime(videoPlayer.duration))
                        .foregroundColor(.white)
                        .font(.caption)
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear, Color.black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
} 