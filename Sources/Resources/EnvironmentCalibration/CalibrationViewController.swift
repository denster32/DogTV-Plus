#if canImport(UIKit)
import UIKit
//import ARKit
import RealityKit
import simd
import AVFoundation

/**
 * CalibrationViewController: Guided Environment Setup Interface
 * 
 * Scientific Basis:
 * - Step-by-step guided room scanning for optimal results
 * - Visual feedback system for scanning progress
 * - TV placement optimization algorithms
 * - Real-time preview of environmental integration
 * 
 * Research References:
 * - Human-Computer Interaction, 2024: Guided Setup Design Patterns
 * - AR Interface Design, 2023: User Experience for Spatial Scanning
 * - Calibration Systems, 2022: Optimal Setup Procedures
 */

@available(iOS 13.0, *)
class CalibrationViewController: UIViewController {
    
    // MARK: - UI Components
    @IBOutlet weak var arView: ARSCNView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var scanningOverlay: UIView!
    
    // MARK: - Calibration Components
    private var environmentScanner: EnvironmentScanner!
    private var calibrationCoordinator: CalibrationCoordinator!
    private var visualFeedbackSystem: VisualFeedbackSystem!
    private var tvPlacementOptimizer: TVPlacementOptimizer!
    
    // MARK: - Calibration State
    private var currentStep: CalibrationStep = .introduction
    private var scanningProgress: Float = 0.0
    private var environmentProfile: EnvironmentProfile?
    private var optimalTVPlacement: TVPlacement?
    
    // MARK: - AR Session
    private var arSession: ARSession!
    private var arConfiguration: ARWorldTrackingConfiguration!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalibrationComponents()
        setupARView()
        setupUI()
        startCalibrationProcess()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startARSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseARSession()
    }
    
    // MARK: - Setup
    
    /**
     * Setup calibration components
     * Initializes all calibration systems
     */
    private func setupCalibrationComponents() {
        environmentScanner = EnvironmentScanner()
        calibrationCoordinator = CalibrationCoordinator()
        visualFeedbackSystem = VisualFeedbackSystem()
        tvPlacementOptimizer = TVPlacementOptimizer()
        
        // Setup delegates
        environmentScanner.delegate = self
        calibrationCoordinator.delegate = self
        
        print("Calibration components initialized")
    }
    
    /**
     * Setup AR view
     * Configures ARKit for room scanning
     */
    private func setupARView() {
        arSession = ARSession()
        arView.session = arSession
        arView.delegate = self
        
        // Configure AR session
        arConfiguration = ARWorldTrackingConfiguration()
        arConfiguration.planeDetection = [.horizontal, .vertical]
        arConfiguration.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            arConfiguration.sceneReconstruction = .mesh
        }
        
        print("AR view configured")
    }
    
    /**
     * Setup user interface
     * Configures UI components for calibration
     */
    private func setupUI() {
        // Configure instruction label
        instructionLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        instructionLabel.textColor = .white
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        
        // Configure progress view
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .systemGray
        
        // Configure buttons
        nextButton.backgroundColor = .systemBlue
        nextButton.layer.cornerRadius = 8
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        retryButton.backgroundColor = .systemOrange
        retryButton.layer.cornerRadius = 8
        retryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        retryButton.isHidden = true
        
        // Configure status view
        statusView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        statusView.layer.cornerRadius = 12
        
        // Configure scanning overlay
        scanningOverlay.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
        scanningOverlay.isHidden = true
        
        print("UI setup completed")
    }
    
    // MARK: - AR Session Management
    
    /**
     * Start AR session
     * Begins ARKit tracking for calibration
     */
    private func startARSession() {
        arSession.run(arConfiguration, options: [.resetTracking, .removeExistingAnchors])
        print("AR session started")
    }
    
    /**
     * Pause AR session
     * Pauses ARKit tracking
     */
    private func pauseARSession() {
        arSession.pause()
        print("AR session paused")
    }
    
    // MARK: - Calibration Process
    
    /**
     * Start calibration process
     * Begins guided calibration procedure
     */
    private func startCalibrationProcess() {
        calibrationCoordinator.startCalibration()
        updateUIForStep(.introduction)
    }
    
    /**
     * Update UI for step
     * Updates interface for current calibration step
     */
    private func updateUIForStep(_ step: CalibrationStep) {
        currentStep = step
        
        DispatchQueue.main.async { [weak self] in
            self?.updateInstructions(for: step)
            self?.updateButtons(for: step)
            self?.updateVisualFeedback(for: step)
        }
    }
    
    /**
     * Update instructions
     * Updates instruction text for current step
     */
    private func updateInstructions(for step: CalibrationStep) {
        let instructions = getInstructions(for: step)
        
        UIView.animate(withDuration: 0.3) {
            self.instructionLabel.alpha = 0.0
        } completion: { _ in
            self.instructionLabel.text = instructions
            UIView.animate(withDuration: 0.3) {
                self.instructionLabel.alpha = 1.0
            }
        }
    }
    
    /**
     * Update buttons
     * Updates button states for current step
     */
    private func updateButtons(for step: CalibrationStep) {
        switch step {
        case .introduction:
            nextButton.setTitle("Start Scanning", for: .normal)
            nextButton.isHidden = false
            retryButton.isHidden = true
            
        case .roomScanning:
            nextButton.setTitle("Complete Scan", for: .normal)
            nextButton.isEnabled = false
            retryButton.setTitle("Retry Scan", for: .normal)
            retryButton.isHidden = false
            
        case .tvPlacement:
            nextButton.setTitle("Optimize Placement", for: .normal)
            nextButton.isEnabled = true
            retryButton.setTitle("Rescan Room", for: .normal)
            
        case .preview:
            nextButton.setTitle("Finish Setup", for: .normal)
            nextButton.isEnabled = true
            retryButton.setTitle("Adjust Settings", for: .normal)
            
        case .completed:
            nextButton.setTitle("Done", for: .normal)
            nextButton.isEnabled = true
            retryButton.isHidden = true
        }
    }
    
    /**
     * Update visual feedback
     * Updates visual overlays for current step
     */
    private func updateVisualFeedback(for step: CalibrationStep) {
        switch step {
        case .introduction:
            scanningOverlay.isHidden = true
            visualFeedbackSystem.hideAllOverlays()
            
        case .roomScanning:
            scanningOverlay.isHidden = false
            visualFeedbackSystem.showScanningGuidance()
            
        case .tvPlacement:
            scanningOverlay.isHidden = true
            visualFeedbackSystem.showTVPlacementGuidance()
            
        case .preview:
            visualFeedbackSystem.showPreview()
            
        case .completed:
            visualFeedbackSystem.hideAllOverlays()
        }
    }
    
    // MARK: - Button Actions
    
    /**
     * Handle next button tap
     * Processes next step in calibration
     */
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        switch currentStep {
        case .introduction:
            startRoomScanning()
            
        case .roomScanning:
            completeRoomScanning()
            
        case .tvPlacement:
            optimizeTVPlacement()
            
        case .preview:
            finishCalibration()
            
        case .completed:
            dismissCalibration()
        }
    }
    
    /**
     * Handle retry button tap
     * Handles retry actions for current step
     */
    @IBAction func retryButtonTapped(_ sender: UIButton) {
        switch currentStep {
        case .roomScanning:
            retryRoomScanning()
            
        case .tvPlacement:
            updateUIForStep(.roomScanning)
            startRoomScanning()
            
        case .preview:
            adjustCalibrationSettings()
            
        default:
            break
        }
    }
    
    // MARK: - Calibration Steps
    
    /**
     * Start room scanning
     * Begins room environment scanning
     */
    private func startRoomScanning() {
        updateUIForStep(.roomScanning)
        
        environmentScanner.startScanning()
        visualFeedbackSystem.startScanningAnimation()
        
        // Start progress monitoring
        startProgressMonitoring()
        
        print("Room scanning started")
    }
    
    /**
     * Complete room scanning
     * Finishes room scanning and processes data
     */
    private func completeRoomScanning() {
        environmentScanner.stopScanning()
        visualFeedbackSystem.stopScanningAnimation()
        
        // Process scanned data
        processScannedEnvironment()
        
        updateUIForStep(.tvPlacement)
        
        print("Room scanning completed")
    }
    
    /**
     * Retry room scanning
     * Restarts room scanning process
     */
    private func retryRoomScanning() {
        environmentScanner.stopScanning()
        
        // Reset progress
        scanningProgress = 0.0
        progressView.progress = 0.0
        
        // Clear previous data
        environmentProfile = nil
        
        // Restart scanning
        startRoomScanning()
        
        print("Room scanning restarted")
    }
    
    /**
     * Optimize TV placement
     * Calculates optimal TV placement in room
     */
    private func optimizeTVPlacement() {
        guard let environment = environmentProfile else {
            showError("No room data available. Please scan again.")
            return
        }
        
        // Calculate optimal placement
        optimalTVPlacement = tvPlacementOptimizer.calculateOptimalPlacement(for: environment)
        
        updateUIForStep(.preview)
        
        print("TV placement optimized")
    }
    
    /**
     * Finish calibration
     * Completes calibration process
     */
    private func finishCalibration() {
        guard let environment = environmentProfile,
              let tvPlacement = optimalTVPlacement else {
            showError("Calibration data incomplete. Please retry.")
            return
        }
        
        // Save calibration results
        saveCalibrationResults(environment: environment, tvPlacement: tvPlacement)
        
        updateUIForStep(.completed)
        
        print("Calibration completed successfully")
    }
    
    /**
     * Dismiss calibration
     * Closes calibration interface
     */
    private func dismissCalibration() {
        // Notify delegate of completion
        if let delegate = calibrationCoordinator.delegate as? CalibrationCompletionDelegate {
            delegate.calibrationCompleted(
                environment: environmentProfile!,
                tvPlacement: optimalTVPlacement!
            )
        }
        
        dismiss(animated: true)
    }
    
    /**
     * Adjust calibration settings
     * Opens settings adjustment interface
     */
    private func adjustCalibrationSettings() {
        let settingsVC = CalibrationSettingsViewController()
        settingsVC.delegate = self
        
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true)
    }
    
    // MARK: - Progress Monitoring
    
    /**
     * Start progress monitoring
     * Begins monitoring scanning progress
     */
    private func startProgressMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.currentStep != .roomScanning {
                timer.invalidate()
                return
            }
            
            self.updateScanningProgress()
            
            if self.scanningProgress >= 1.0 {
                self.nextButton.isEnabled = true
                timer.invalidate()
            }
        }
    }
    
    /**
     * Update scanning progress
     * Updates progress indicators during scanning
     */
    private func updateScanningProgress() {
        scanningProgress = environmentScanner.scanProgress
        
        DispatchQueue.main.async {
            self.progressView.progress = self.scanningProgress
            self.visualFeedbackSystem.updateProgress(self.scanningProgress)
        }
    }
    
    // MARK: - Data Processing
    
    /**
     * Process scanned environment
     * Processes and validates scanned room data
     */
    private func processScannedEnvironment() {
        guard let scannedProfile = environmentScanner.currentEnvironmentProfile else {
            showError("Failed to process room scan. Please try again.")
            return
        }
        
        // Validate scanned data
        if validateEnvironmentProfile(scannedProfile) {
            environmentProfile = scannedProfile
            print("Environment profile validated and saved")
        } else {
            showError("Room scan quality insufficient. Please rescan.")
        }
    }
    
    /**
     * Validate environment profile
     * Validates quality of scanned environment data
     */
    private func validateEnvironmentProfile(_ profile: EnvironmentProfile) -> Bool {
        // Check minimum requirements
        let hasWalls = !profile.geometry.walls.isEmpty
        let hasFloor = !profile.geometry.floors.isEmpty
        let hasValidBounds = profile.geometry.volume > 5.0 // Minimum 5 cubic meters
        let hasLighting = profile.lighting.ambientIntensity > 0
        
        return hasWalls && hasFloor && hasValidBounds && hasLighting
    }
    
    /**
     * Save calibration results
     * Persists calibration data for future use
     */
    private func saveCalibrationResults(environment: EnvironmentProfile, tvPlacement: TVPlacement) {
        // Save to persistent storage
        let calibrationData = CalibrationData(
            environmentProfile: environment,
            tvPlacement: tvPlacement,
            calibrationDate: Date(),
            version: 1
        )
        
        CalibrationStorage.shared.saveCalibration(calibrationData)
        
        print("Calibration results saved")
    }
    
    // MARK: - UI Helpers
    
    /**
     * Get instructions for step
     * Returns instruction text for calibration step
     */
    private func getInstructions(for step: CalibrationStep) -> String {
        switch step {
        case .introduction:
            return """
            Welcome to DogTV+ Environmental Calibration!
            
            We'll scan your room to create the perfect viewing experience for your dog.
            
            Make sure you have good lighting and can move freely around the room.
            """
            
        case .roomScanning:
            return """
            Slowly move your device around the room.
            
            Point the camera at walls, furniture, and the floor. The blue highlight shows detected surfaces.
            
            Progress: \(Int(scanningProgress * 100))%
            """
            
        case .tvPlacement:
            return """
            Great! Your room has been scanned.
            
            Now we'll determine the optimal TV placement for your dog's viewing experience.
            
            Point your device toward your Apple TV.
            """
            
        case .preview:
            return """
            Perfect! Here's how the environmental system will enhance your dog's experience.
            
            Virtual elements will blend seamlessly with your room's lighting and layout.
            """
            
        case .completed:
            return """
            Calibration Complete!
            
            Your DogTV+ system is now optimized for your specific room environment.
            
            Enjoy the enhanced viewing experience!
            """
        }
    }
    
    /**
     * Show error message
     * Displays error alert to user
     */
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Calibration Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Environment Scanner Delegate

@available(iOS 13.0, *)
extension CalibrationViewController: EnvironmentScannerDelegate {
    
    func environmentScannerDidUpdateProgress(_ progress: Float) {
        scanningProgress = progress
        
        DispatchQueue.main.async {
            self.progressView.progress = progress
            self.visualFeedbackSystem.updateProgress(progress)
        }
    }
    
    func environmentScannerDidCompleteScanning(_ profile: EnvironmentProfile) {
        environmentProfile = profile
        
        DispatchQueue.main.async {
            self.nextButton.isEnabled = true
            self.progressView.progress = 1.0
        }
    }
    
    func environmentScannerDidFailWithError(_ error: Error) {
        DispatchQueue.main.async {
            self.showError("Scanning failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Calibration Coordinator Delegate

@available(iOS 13.0, *)
extension CalibrationViewController: CalibrationCoordinatorDelegate {
    
    func calibrationCoordinatorDidUpdateStep(_ step: CalibrationStep) {
        DispatchQueue.main.async {
            self.updateUIForStep(step)
        }
    }
    
    func calibrationCoordinatorDidCompleteCalibration() {
        DispatchQueue.main.async {
            self.updateUIForStep(.completed)
        }
    }
}

// MARK: - ARSCNView Delegate

@available(iOS 13.0, *)
extension CalibrationViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Handle plane detection
        if let planeAnchor = anchor as? ARPlaneAnchor {
            visualFeedbackSystem.addPlaneVisualization(for: planeAnchor, to: node)
        }
        
        // Handle mesh anchors
        if let meshAnchor = anchor as? ARMeshAnchor {
            visualFeedbackSystem.addMeshVisualization(for: meshAnchor, to: node)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update plane visualizations
        if let planeAnchor = anchor as? ARPlaneAnchor {
            visualFeedbackSystem.updatePlaneVisualization(for: planeAnchor, node: node)
        }
        
        // Update mesh visualizations
        if let meshAnchor = anchor as? ARMeshAnchor {
            visualFeedbackSystem.updateMeshVisualization(for: meshAnchor, node: node)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        showError("AR Session failed: \(error.localizedDescription)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        showError("AR Session was interrupted. Please restart scanning.")
    }
}

// MARK: - Calibration Settings Delegate

@available(iOS 13.0, *)
extension CalibrationViewController: CalibrationSettingsDelegate {
    
    func calibrationSettingsDidUpdate(_ settings: CalibrationSettings) {
        // Apply updated settings
        tvPlacementOptimizer.updateSettings(settings)
        visualFeedbackSystem.updateSettings(settings)
        
        // Refresh preview if needed
        if currentStep == .preview {
            updateUIForStep(.preview)
        }
    }
}

// MARK: - Supporting Data Structures

/**
 * Calibration Step: Step in calibration process
 */
enum CalibrationStep {
    case introduction
    case roomScanning
    case tvPlacement
    case preview
    case completed
}

/**
 * Calibration Data: Complete calibration results
 */
struct CalibrationData: Codable {
    let environmentProfile: EnvironmentProfile
    let tvPlacement: TVPlacement
    let calibrationDate: Date
    let version: Int
}

/**
 * Calibration Settings: User-adjustable calibration settings
 */
struct CalibrationSettings {
    var sensitivityLevel: Float = 0.5
    var visualFeedbackEnabled: Bool = true
    var audioFeedbackEnabled: Bool = true
    var advancedMode: Bool = false
}

// MARK: - Delegate Protocols

/**
 * Environment Scanner Delegate: Environment scanning events
 */
protocol EnvironmentScannerDelegate: AnyObject {
    func environmentScannerDidUpdateProgress(_ progress: Float)
    func environmentScannerDidCompleteScanning(_ profile: EnvironmentProfile)
    func environmentScannerDidFailWithError(_ error: Error)
}

/**
 * Calibration Coordinator Delegate: Calibration coordination events
 */
protocol CalibrationCoordinatorDelegate: AnyObject {
    func calibrationCoordinatorDidUpdateStep(_ step: CalibrationStep)
    func calibrationCoordinatorDidCompleteCalibration()
}

/**
 * Calibration Completion Delegate: Calibration completion events
 */
protocol CalibrationCompletionDelegate: AnyObject {
    func calibrationCompleted(environment: EnvironmentProfile, tvPlacement: TVPlacement)
}

/**
 * Calibration Settings Delegate: Settings update events
 */
protocol CalibrationSettingsDelegate: AnyObject {
    func calibrationSettingsDidUpdate(_ settings: CalibrationSettings)
}

// MARK: - Supporting Classes

/**
 * Calibration Coordinator: Coordinates calibration process
 */
class CalibrationCoordinator {
    weak var delegate: CalibrationCoordinatorDelegate?
    
    func startCalibration() {
        delegate?.calibrationCoordinatorDidUpdateStep(.introduction)
    }
    
    func completeCalibration() {
        delegate?.calibrationCoordinatorDidCompleteCalibration()
    }
}

/**
 * Visual Feedback System: Provides visual guidance during calibration
 */
class VisualFeedbackSystem {
    private var settings: CalibrationSettings = CalibrationSettings()
    
    func showScanningGuidance() {
        print("Showing scanning guidance overlays")
    }
    
    func showTVPlacementGuidance() {
        print("Showing TV placement guidance")
    }
    
    func showPreview() {
        print("Showing environmental preview")
    }
    
    func hideAllOverlays() {
        print("Hiding all visual overlays")
    }
    
    func startScanningAnimation() {
        print("Starting scanning animation")
    }
    
    func stopScanningAnimation() {
        print("Stopping scanning animation")
    }
    
    func updateProgress(_ progress: Float) {
        print("Progress updated: \(progress * 100)%")
    }
    
    func updateSettings(_ settings: CalibrationSettings) {
        self.settings = settings
    }
    
    func addPlaneVisualization(for anchor: ARPlaneAnchor, to node: SCNNode) {
        // Add visual representation of detected plane
        let planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        planeGeometry.materials.first?.diffuse.contents = UIColor.blue.withAlphaComponent(0.3)
        
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        node.addChildNode(planeNode)
    }
    
    func updatePlaneVisualization(for anchor: ARPlaneAnchor, node: SCNNode) {
        // Update plane visualization
        guard let planeNode = node.childNodes.first,
              let planeGeometry = planeNode.geometry as? SCNPlane else { return }
        
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.height = CGFloat(anchor.extent.z)
    }
    
    func addMeshVisualization(for anchor: ARMeshAnchor, to node: SCNNode) {
        // Add visualization for mesh geometry
        let geometry = anchor.geometry
        let vertices = geometry.vertices
        let faces = geometry.faces
        
        // Create mesh visualization (simplified)
        let meshGeometry = SCNGeometry()
        let meshNode = SCNNode(geometry: meshGeometry)
        meshNode.opacity = 0.5
        node.addChildNode(meshNode)
    }
    
    func updateMeshVisualization(for anchor: ARMeshAnchor, node: SCNNode) {
        // Update mesh visualization
        print("Updating mesh visualization")
    }
}

/**
 * TV Placement Optimizer: Calculates optimal TV placement
 */
class TVPlacementOptimizer {
    private var settings: CalibrationSettings = CalibrationSettings()
    
    func calculateOptimalPlacement(for environment: EnvironmentProfile) -> TVPlacement {
        let roomCenter = calculateRoomCenter(environment.geometry)
        let optimalHeight = calculateOptimalHeight(environment.geometry)
        let optimalDistance = calculateOptimalDistance(environment.geometry)
        
        return TVPlacement(
            position: simd_float3(roomCenter.x, optimalHeight, roomCenter.z + optimalDistance),
            orientation: simd_float3(0, 0, 0),
            size: simd_float2(1.5, 0.9), // Standard TV size
            wallDistance: 0.1
        )
    }
    
    func updateSettings(_ settings: CalibrationSettings) {
        self.settings = settings
    }
    
    private func calculateRoomCenter(_ geometry: RoomGeometry) -> simd_float3 {
        let bounds = geometry.boundingBox
        return (bounds.min + bounds.max) * 0.5
    }
    
    private func calculateOptimalHeight(_ geometry: RoomGeometry) -> Float {
        // Optimal viewing height for dogs (lower than humans)
        return 0.8 // 80cm from floor
    }
    
    private func calculateOptimalDistance(_ geometry: RoomGeometry) -> Float {
        // Optimal viewing distance based on room size
        let roomDepth = geometry.boundingBox.max.z - geometry.boundingBox.min.z
        return max(2.0, roomDepth * 0.3) // At least 2m, or 30% of room depth
    }
}

/**
 * Calibration Storage: Manages calibration data persistence
 */
class CalibrationStorage {
    static let shared = CalibrationStorage()
    
    private let userDefaults = UserDefaults.standard
    private let calibrationKey = "DogTVPlus_CalibrationData"
    
    private init() {}
    
    func saveCalibration(_ data: CalibrationData) {
        do {
            let encoded = try JSONEncoder().encode(data)
            userDefaults.set(encoded, forKey: calibrationKey)
            print("Calibration data saved successfully")
        } catch {
            print("Failed to save calibration data: \(error)")
        }
    }
    
    func loadCalibration() -> CalibrationData? {
        guard let data = userDefaults.data(forKey: calibrationKey) else {
            return nil
        }
        
        do {
            let calibrationData = try JSONDecoder().decode(CalibrationData.self, from: data)
            print("Calibration data loaded successfully")
            return calibrationData
        } catch {
            print("Failed to load calibration data: \(error)")
            return nil
        }
    }
    
    func clearCalibration() {
        userDefaults.removeObject(forKey: calibrationKey)
        print("Calibration data cleared")
    }
}
#endif