// MARK: - Apple Ecosystem Integration Framework
// Siri Shortcuts, Handoff, Spotlight, Control Center, Apple Watch, App Clips

import Foundation
import Intents
import IntentsUI
import CoreSpotlight
import MobileCoreServices
import WatchConnectivity
import UserNotifications

// MARK: - Apple Ecosystem Manager
public class AppleEcosystemManager: NSObject {
    
    private let shortcutsManager: SiriShortcutsManager
    private let handoffManager: HandoffManager
    private let spotlightManager: SpotlightManager
    private let controlCenterManager: ControlCenterManager
    private let watchConnectivityManager: WatchConnectivityManager
    private let appClipsManager: AppClipsManager
    private let focusModesManager: FocusModesManager
    
    public override init() {
        self.shortcutsManager = SiriShortcutsManager()
        self.handoffManager = HandoffManager()
        self.spotlightManager = SpotlightManager()
        self.controlCenterManager = ControlCenterManager()
        self.watchConnectivityManager = WatchConnectivityManager()
        self.appClipsManager = AppClipsManager()
        self.focusModesManager = FocusModesManager()
        
        super.init()
        
        setupEcosystemIntegration()
    }
    
    private func setupEcosystemIntegration() {
        shortcutsManager.setupSiriShortcuts()
        handoffManager.setupHandoff()
        spotlightManager.setupSpotlightSearch()
        controlCenterManager.setupControlCenterWidget()
        watchConnectivityManager.setupWatchConnectivity()
        appClipsManager.setupAppClips()
        focusModesManager.setupFocusModes()
    }
    
    // MARK: - Public Interface
    
    public func playContentWithSiri(scene: DogTVScene) async throws {
        try await shortcutsManager.executePlayContentShortcut(scene: scene)
    }
    
    public func startHandoffActivity(scene: DogTVScene) {
        handoffManager.startActivity(for: scene)
    }
    
    public func updateSpotlightIndex(with content: [ContentItem]) {
        spotlightManager.updateIndex(with: content)
    }
    
    public func syncWithAppleWatch(data: WatchSyncData) {
        watchConnectivityManager.syncData(data)
    }
    
    public func handleAppClipInvocation(url: URL) -> Bool {
        return appClipsManager.handleInvocation(url: url)
    }
}

// MARK: - Siri Shortcuts Manager
public class SiriShortcutsManager: NSObject, INPlayMediaIntentHandling {
    
    private var donatedShortcuts: [INShortcut] = []
    
    public func setupSiriShortcuts() {
        setupIntentExtension()
        donateCommonShortcuts()
    }
    
    private func setupIntentExtension() {
        // Register custom intent definitions
        let playContentIntent = INIntent()
        playContentIntent.suggestedInvocationPhrase = "Play relaxing sounds for my dog"
    }
    
    private func donateCommonShortcuts() {
        // Donate common shortcuts for better Siri suggestions
        let shortcuts = [
            createPlayForestSoundsShortcut(),
            createPlayBeachWavesShortcut(),
            createPlayCitySoundsShortcut(),
            createPauseAudioShortcut(),
            createSetVolumeShortcut()
        ]
        
        for shortcut in shortcuts {
            INVoiceShortcutCenter.shared.setShortcutSuggestions([shortcut])
        }
    }
    
    private func createPlayForestSoundsShortcut() -> INShortcut {
        let intent = PlayDogTVContentIntent()
        intent.scene = .forestWalk
        intent.suggestedInvocationPhrase = "Play forest sounds for my dog"
        
        return INShortcut(intent: intent)
    }
    
    private func createPlayBeachWavesShortcut() -> INShortcut {
        let intent = PlayDogTVContentIntent()
        intent.scene = .beachWaves
        intent.suggestedInvocationPhrase = "Play ocean sounds for my dog"
        
        return INShortcut(intent: intent)
    }
    
    private func createPlayCitySoundsShortcut() -> INShortcut {
        let intent = PlayDogTVContentIntent()
        intent.scene = .cityAmbient
        intent.suggestedInvocationPhrase = "Play city sounds for my dog"
        
        return INShortcut(intent: intent)
    }
    
    private func createPauseAudioShortcut() -> INShortcut {
        let intent = ControlDogTVPlaybackIntent()
        intent.action = .pause
        intent.suggestedInvocationPhrase = "Pause DogTV"
        
        return INShortcut(intent: intent)
    }
    
    private func createSetVolumeShortcut() -> INShortcut {
        let intent = SetDogTVVolumeIntent()
        intent.volumeLevel = 0.5
        intent.suggestedInvocationPhrase = "Set DogTV volume to 50 percent"
        
        return INShortcut(intent: intent)
    }
    
    public func executePlayContentShortcut(scene: DogTVScene) async throws {
        // Execute the shortcut programmatically
        let intent = PlayDogTVContentIntent()
        intent.scene = scene
        
        let interaction = INInteraction(intent: intent, response: nil)
        try await interaction.donate()
        
        // Trigger the actual playback
        await MainActor.run {
            NotificationCenter.default.post(
                name: .dogTVPlayContentRequested,
                object: nil,
                userInfo: ["scene": scene]
            )
        }
    }
    
    // MARK: - INPlayMediaIntentHandling
    
    public func handle(intent: INPlayMediaIntent, completion: @escaping (INPlayMediaIntentResponse) -> Void) {
        // Handle Siri play media requests
        let response = INPlayMediaIntentResponse(code: .success, userActivity: nil)
        completion(response)
    }
}

// MARK: - Handoff Manager
public class HandoffManager: NSObject {
    
    private var currentUserActivity: NSUserActivity?
    
    public func setupHandoff() {
        // Enable handoff capabilities
    }
    
    public func startActivity(for scene: DogTVScene) {
        let activityType = "com.dogtv.play-content"
        let userActivity = NSUserActivity(activityType: activityType)
        
        userActivity.title = "Playing \(scene.displayName) on DogTV+"
        userActivity.userInfo = [
            "scene": scene.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ]
        userActivity.isEligibleForHandoff = true
        userActivity.isEligibleForSearch = true
        userActivity.isEligibleForPublicIndexing = false
        
        // Set content attributes for better search
        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeAudio as String)
        attributes.title = "DogTV+ - \(scene.displayName)"
        attributes.contentDescription = scene.description
        attributes.keywords = scene.keywords
        
        userActivity.contentAttributeSet = attributes
        
        currentUserActivity = userActivity
        userActivity.becomeCurrent()
    }
    
    public func continueActivity(_ userActivity: NSUserActivity) -> Bool {
        guard userActivity.activityType == "com.dogtv.play-content",
              let userInfo = userActivity.userInfo,
              let sceneRawValue = userInfo["scene"] as? String,
              let scene = DogTVScene(rawValue: sceneRawValue) else {
            return false
        }
        
        // Continue the activity on this device
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .dogTVPlayContentRequested,
                object: nil,
                userInfo: ["scene": scene, "source": "handoff"]
            )
        }
        
        return true
    }
    
    public func stopCurrentActivity() {
        currentUserActivity?.invalidate()
        currentUserActivity = nil
    }
}

// MARK: - Spotlight Search Manager
public class SpotlightManager {
    
    private let spotlightQueue = DispatchQueue(label: "com.dogtv.spotlight", qos: .utility)
    
    public func setupSpotlightSearch() {
        // Initial setup for Spotlight integration
        indexStaticContent()
    }
    
    public func updateIndex(with content: [ContentItem]) {
        spotlightQueue.async {
            self.indexContent(content)
        }
    }
    
    private func indexStaticContent() {
        let staticItems = [
            createSpotlightItem(
                identifier: "scene.forest",
                title: "Forest Walk - DogTV+",
                description: "Peaceful forest sounds for dog relaxation",
                keywords: ["forest", "nature", "relaxation", "dog", "peaceful"],
                scene: .forestWalk
            ),
            createSpotlightItem(
                identifier: "scene.beach",
                title: "Beach Waves - DogTV+",
                description: "Gentle ocean sounds for calming dogs",
                keywords: ["beach", "ocean", "waves", "calm", "dog"],
                scene: .beachWaves
            ),
            createSpotlightItem(
                identifier: "scene.city",
                title: "City Sounds - DogTV+",
                description: "Urban sounds to help dogs adapt to city life",
                keywords: ["city", "urban", "adaptation", "dog", "training"],
                scene: .cityAmbient
            )
        ]
        
        CSSearchableIndex.default().indexSearchableItems(staticItems) { error in
            if let error = error {
                print("Error indexing static content: \(error)")
            }
        }
    }
    
    private func indexContent(_ content: [ContentItem]) {
        let searchableItems = content.map { item in
            createSpotlightItem(
                identifier: item.id,
                title: item.adaptedTitle,
                description: item.adaptedDescription,
                keywords: item.tags,
                scene: nil
            )
        }
        
        CSSearchableIndex.default().indexSearchableItems(searchableItems) { error in
            if let error = error {
                print("Error indexing content: \(error)")
            }
        }
    }
    
    private func createSpotlightItem(
        identifier: String,
        title: String,
        description: String,
        keywords: [String],
        scene: DogTVScene?
    ) -> CSSearchableItem {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeAudio as String)
        attributeSet.title = title
        attributeSet.contentDescription = description
        attributeSet.keywords = keywords
        attributeSet.thumbnailURL = getThumbnailURL(for: scene)
        
        let item = CSSearchableItem(
            uniqueIdentifier: identifier,
            domainIdentifier: "com.dogtv.content",
            attributeSet: attributeSet
        )
        
        return item
    }
    
    private func getThumbnailURL(for scene: DogTVScene?) -> URL? {
        guard let scene = scene else { return nil }
        return Bundle.main.url(forResource: scene.thumbnailName, withExtension: "png")
    }
    
    public func handleSpotlightSelection(itemIdentifier: String) -> Bool {
        // Handle when user taps on a Spotlight search result
        if itemIdentifier.hasPrefix("scene.") {
            let sceneKey = String(itemIdentifier.dropFirst(6)) // Remove "scene." prefix
            if let scene = DogTVScene.fromKey(sceneKey) {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .dogTVPlayContentRequested,
                        object: nil,
                        userInfo: ["scene": scene, "source": "spotlight"]
                    )
                }
                return true
            }
        }
        return false
    }
}

// MARK: - Control Center Widget Manager
public class ControlCenterManager {
    
    public func setupControlCenterWidget() {
        // Setup Control Center widget for quick access
        registerControlCenterWidget()
    }
    
    private func registerControlCenterWidget() {
        // Register widget with system
        // This would involve creating a Control Center extension
    }
    
    public func updateWidgetState(isPlaying: Bool, currentScene: DogTVScene?) {
        // Update the Control Center widget state
        let widgetData = ControlCenterWidgetData(
            isPlaying: isPlaying,
            currentScene: currentScene,
            timestamp: Date()
        )
        
        // Send update to widget extension
        updateWidget(with: widgetData)
    }
    
    private func updateWidget(with data: ControlCenterWidgetData) {
        // Implementation for updating widget
    }
}

// MARK: - Apple Watch Connectivity Manager
public class WatchConnectivityManager: NSObject, WCSessionDelegate {
    
    private var session: WCSession?
    
    public func setupWatchConnectivity() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    public func syncData(_ data: WatchSyncData) {
        guard let session = session, session.isReachable else { return }
        
        let message = [
            "type": "sync",
            "data": data.toDictionary()
        ]
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error syncing with Apple Watch: \(error)")
        }
    }
    
    public func sendPlaybackState(isPlaying: Bool, scene: DogTVScene) {
        guard let session = session else { return }
        
        let context = [
            "isPlaying": isPlaying,
            "scene": scene.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ] as [String: Any]
        
        try? session.updateApplicationContext(context)
    }
    
    // MARK: - WCSessionDelegate
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Watch session activation failed: \(error)")
        }
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle messages from Apple Watch
        if let action = message["action"] as? String {
            handleWatchAction(action, parameters: message)
        }
    }
    
    private func handleWatchAction(_ action: String, parameters: [String: Any]) {
        DispatchQueue.main.async {
            switch action {
            case "play":
                if let sceneRawValue = parameters["scene"] as? String,
                   let scene = DogTVScene(rawValue: sceneRawValue) {
                    NotificationCenter.default.post(
                        name: .dogTVPlayContentRequested,
                        object: nil,
                        userInfo: ["scene": scene, "source": "watch"]
                    )
                }
            case "pause":
                NotificationCenter.default.post(name: .dogTVPauseRequested, object: nil)
            case "stop":
                NotificationCenter.default.post(name: .dogTVStopRequested, object: nil)
            default:
                break
            }
        }
    }
    
    #if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {}
    public func sessionDidDeactivate(_ session: WCSession) {}
    #endif
}

// MARK: - App Clips Manager
public class AppClipsManager {
    
    public func setupAppClips() {
        // Setup App Clips for quick demos
        registerAppClipExperiences()
    }
    
    private func registerAppClipExperiences() {
        // Register different App Clip experiences
        let experiences = [
            AppClipExperience(
                url: URL(string: "https://dogtv.com/demo/forest") ?? URL(string: "https://dogtv.com")!,
                scene: .forestWalk,
                title: "Try Forest Sounds",
                description: "Experience peaceful forest sounds for your dog"
            ),
            AppClipExperience(
                url: URL(string: "https://dogtv.com/demo/beach") ?? URL(string: "https://dogtv.com")!,
                scene: .beachWaves,
                title: "Try Beach Waves",
                description: "Calming ocean sounds for relaxation"
            )
        ]
        
        for experience in experiences {
            registerExperience(experience)
        }
    }
    
    private func registerExperience(_ experience: AppClipExperience) {
        // Register the App Clip experience with the system
    }
    
    public func handleInvocation(url: URL) -> Bool {
        // Handle App Clip invocation
        guard let scene = extractSceneFromURL(url) else { return false }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .dogTVPlayContentRequested,
                object: nil,
                userInfo: ["scene": scene, "source": "appclip"]
            )
        }
        
        return true
    }
    
    private func extractSceneFromURL(_ url: URL) -> DogTVScene? {
        if url.path.contains("forest") {
            return .forestWalk
        } else if url.path.contains("beach") {
            return .beachWaves
        } else if url.path.contains("city") {
            return .cityAmbient
        }
        return nil
    }
}

// MARK: - Focus Modes Manager
public class FocusModesManager {
    
    public func setupFocusModes() {
        // Setup integration with iOS Focus Modes
        registerFocusModeActions()
    }
    
    private func registerFocusModeActions() {
        // Register actions that should be available in Focus Modes
    }
    
    public func handleFocusModeChange(_ focusMode: String) {
        switch focusMode {
        case "Sleep":
            // Automatically start relaxing content
            NotificationCenter.default.post(
                name: .dogTVPlayContentRequested,
                object: nil,
                userInfo: ["scene": DogTVScene.forestWalk, "source": "focus_mode"]
            )
        case "Do Not Disturb":
            // Pause current playback
            NotificationCenter.default.post(name: .dogTVPauseRequested, object: nil)
        default:
            break
        }
    }
}

// MARK: - Custom Intent Definitions

public class PlayDogTVContentIntent: INIntent {
    @NSManaged public var scene: DogTVScene
}

public class ControlDogTVPlaybackIntent: INIntent {
    @NSManaged public var action: PlaybackAction
}

public class SetDogTVVolumeIntent: INIntent {
    @NSManaged public var volumeLevel: Float
}

public enum PlaybackAction: Int, CaseIterable {
    case play = 0
    case pause = 1
    case stop = 2
}

// MARK: - Supporting Data Structures

public struct WatchSyncData {
    let currentScene: DogTVScene?
    let isPlaying: Bool
    let volume: Float
    let timestamp: Date
    
    func toDictionary() -> [String: Any] {
        return [
            "currentScene": currentScene?.rawValue ?? "",
            "isPlaying": isPlaying,
            "volume": volume,
            "timestamp": timestamp.timeIntervalSince1970
        ]
    }
}

public struct ControlCenterWidgetData {
    let isPlaying: Bool
    let currentScene: DogTVScene?
    let timestamp: Date
}

public struct AppClipExperience {
    let url: URL
    let scene: DogTVScene
    let title: String
    let description: String
}

// MARK: - DogTVScene Extensions for Apple Ecosystem

extension DogTVScene {
    var displayName: String {
        switch self {
        case .forestWalk:
            return "Forest Walk"
        case .beachWaves:
            return "Beach Waves"
        case .cityAmbient:
            return "City Sounds"
        default:
            return rawValue.capitalized
        }
    }
    
    var description: String {
        switch self {
        case .forestWalk:
            return "Peaceful forest sounds for deep relaxation"
        case .beachWaves:
            return "Gentle ocean waves for calming and soothing"
        case .cityAmbient:
            return "Urban sounds to help dogs adapt to city life"
        default:
            return "Relaxing audio content for dogs"
        }
    }
    
    var keywords: [String] {
        switch self {
        case .forestWalk:
            return ["forest", "nature", "trees", "birds", "peaceful", "relaxation"]
        case .beachWaves:
            return ["beach", "ocean", "waves", "water", "calm", "soothing"]
        case .cityAmbient:
            return ["city", "urban", "traffic", "adaptation", "training"]
        default:
            return ["dog", "audio", "relaxation"]
        }
    }
    
    var thumbnailName: String {
        return "\(rawValue)_thumbnail"
    }
    
    static func fromKey(_ key: String) -> DogTVScene? {
        switch key {
        case "forest":
            return .forestWalk
        case "beach":
            return .beachWaves
        case "city":
            return .cityAmbient
        default:
            return nil
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let dogTVPlayContentRequested = Notification.Name("DogTVPlayContentRequested")
    static let dogTVPauseRequested = Notification.Name("DogTVPauseRequested")
    static let dogTVStopRequested = Notification.Name("DogTVStopRequested")
    static let dogTVVolumeChangeRequested = Notification.Name("DogTVVolumeChangeRequested")
}

// MARK: - Apple Ecosystem Integration Extensions

extension ContentItem {
    var adaptedTitle: String {
        // This would be localized based on current locale
        return titleKey
    }
    
    var adaptedDescription: String {
        // This would be localized based on current locale
        return descriptionKey
    }
}
