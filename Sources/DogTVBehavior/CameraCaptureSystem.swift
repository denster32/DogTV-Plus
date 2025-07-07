import AVFoundation
import Vision
import SwiftUI
import Combine

/// A comprehensive camera capture system for DogTV+ behavior analysis
public class CameraCaptureSystem: ObservableObject {
    @Published public var isCapturing: Bool = false
    @Published public var hasPermission: Bool = false
    @Published public var currentFrame: UIImage?
    @Published public var behaviorAnalysis: BehaviorAnalysis?
    @Published public var error: CameraError?
    @Published public var cameraPosition: AVCaptureDevice.Position = .back
    @Published public var isFlashEnabled: Bool = false
    
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var photoOutput: AVCapturePhotoOutput?
    private var videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated)
    private var cancellables = Set<AnyCancellable>()
    
    private let behaviorAnalyzer = CanineBehaviorAnalyzer()
    
    public init() {
        checkCameraPermission()
    }
    
    deinit {
        stopCameraCapture()
    }
    
    // MARK: - Public Methods
    
    /// Start camera capture for behavior analysis
    public func startCameraCapture() {
        guard hasPermission else {
            requestCameraPermission()
            return
        }
        
        setupCaptureSession()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
            
            DispatchQueue.main.async {
                self?.isCapturing = true
                self?.error = nil
            }
        }
    }
    
    /// Stop camera capture
    public func stopCameraCapture() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
            
            DispatchQueue.main.async {
                self?.isCapturing = false
            }
        }
    }
    
    /// Switch between front and back cameras
    public func switchCamera() {
        cameraPosition = cameraPosition == .back ? .front : .back
        setupCaptureSession()
    }
    
    /// Toggle flash
    public func toggleFlash() {
        isFlashEnabled.toggle()
        configureFlash()
    }
    
    /// Capture a photo for analysis
    public func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isFlashEnabled ? .on : .off
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    /// Process video frame for behavior analysis
    public func processVideoFrame(_ frame: CVPixelBuffer) {
        // Convert CVPixelBuffer to UIImage
        let ciImage = CIImage(cvPixelBuffer: frame)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let image = UIImage(cgImage: cgImage)
        
        DispatchQueue.main.async { [weak self] in
            self?.currentFrame = image
        }
        
        // Analyze behavior
        analyzeBehavior(from: image)
    }
    
    // MARK: - Private Methods
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            hasPermission = true
        case .notDetermined:
            requestCameraPermission()
        case .denied, .restricted:
            hasPermission = false
            error = .permissionDenied
        @unknown default:
            hasPermission = false
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.hasPermission = granted
                if granted {
                    self?.startCameraCapture()
                } else {
                    self?.error = .permissionDenied
                }
            }
        }
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession else { return }
        
        // Configure session quality
        captureSession.sessionPreset = .high
        
        // Setup video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            error = .deviceNotFound
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        // Setup video output
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput?.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        if let videoOutput = videoOutput, captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // Setup photo output
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        // Configure flash
        configureFlash()
    }
    
    private func configureFlash() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition) else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.hasFlash {
                device.flashMode = isFlashEnabled ? .on : .off
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Failed to configure flash: \(error)")
        }
    }
    
    private func analyzeBehavior(from image: UIImage) {
        // Use the existing CanineBehaviorAnalyzer
        behaviorAnalyzer.analyzeImage(image) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let analysis):
                    self?.behaviorAnalysis = analysis
                case .failure(let error):
                    print("Behavior analysis failed: \(error)")
                }
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraCaptureSystem: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        processVideoFrame(pixelBuffer)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraCaptureSystem: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            self.error = .captureFailed(error.localizedDescription)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            self.error = .captureFailed("Failed to create image from photo data")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.currentFrame = image
        }
        
        // Analyze the captured photo
        analyzeBehavior(from: image)
    }
}

// MARK: - Camera Error Types

public enum CameraError: Error, LocalizedError {
    case permissionDenied
    case deviceNotFound
    case captureFailed(String)
    case configurationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Camera permission is required for behavior analysis"
        case .deviceNotFound:
            return "Camera device not found"
        case .captureFailed(let message):
            return "Photo capture failed: \(message)"
        case .configurationFailed(let message):
            return "Camera configuration failed: \(message)"
        }
    }
}

// MARK: - Camera Preview View

public struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var cameraSystem: CameraCaptureSystem
    
    public init(cameraSystem: CameraCaptureSystem) {
        self.cameraSystem = cameraSystem
    }
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        // Add camera preview layer
        if let captureSession = cameraSystem.captureSession {
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        // Update preview layer frame if needed
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

// MARK: - Behavior Analysis View

public struct BehaviorAnalysisView: View {
    @ObservedObject var cameraSystem: CameraCaptureSystem
    
    public init(cameraSystem: CameraCaptureSystem) {
        self.cameraSystem = cameraSystem
    }
    
    public var body: some View {
        VStack {
            if let currentFrame = cameraSystem.currentFrame {
                Image(uiImage: currentFrame)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .padding()
            } else {
                Rectangle()
                    .fill(Color.black)
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            Text("Camera Preview")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    )
                    .cornerRadius(12)
                    .padding()
            }
            
            if let analysis = cameraSystem.behaviorAnalysis {
                BehaviorAnalysisResultView(analysis: analysis)
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    cameraSystem.switchCamera()
                }) {
                    Image(systemName: "camera.rotate")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    cameraSystem.toggleFlash()
                }) {
                    Image(systemName: cameraSystem.isFlashEnabled ? "bolt.fill" : "bolt.slash")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(cameraSystem.isFlashEnabled ? Color.yellow : Color.gray)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    cameraSystem.capturePhoto()
                }) {
                    Image(systemName: "camera")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .onAppear {
            cameraSystem.startCameraCapture()
        }
        .onDisappear {
            cameraSystem.stopCameraCapture()
        }
    }
}

// MARK: - Behavior Analysis Result View

struct BehaviorAnalysisResultView: View {
    let analysis: BehaviorAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Behavior Analysis")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Text("Attention Level:")
                Spacer()
                Text("\(Int(analysis.attentionLevel * 100))%")
                    .foregroundColor(.blue)
            }
            
            HStack {
                Text("Calmness Level:")
                Spacer()
                Text("\(Int(analysis.calmnessLevel * 100))%")
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Engagement Level:")
                Spacer()
                Text("\(Int(analysis.engagementLevel * 100))%")
                    .foregroundColor(.orange)
            }
            
            if !analysis.detectedBehaviors.isEmpty {
                Text("Detected Behaviors:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ForEach(analysis.detectedBehaviors, id: \.self) { behavior in
                    Text("• \(behavior)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
} 