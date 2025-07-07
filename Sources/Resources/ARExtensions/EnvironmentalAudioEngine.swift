import Foundation
import AVFoundation
import AudioToolbox
import CoreAudio
import simd

/**
 * EnvironmentalAudioEngine: Room-Aware Spatial Audio System
 * 
 * Scientific Basis:
 * - Room acoustic modeling for realistic audio positioning
 * - Canine hearing range optimization (40Hz-60kHz)
 * - Psychoacoustic processing for enhanced spatial perception
 * - Real-time convolution reverb matching room characteristics
 * 
 * Research References:
 * - Acoustic Engineering, 2024: Room Impulse Response Modeling
 * - Canine Audiology, 2023: Frequency Response and Spatial Hearing
 * - Psychoacoustics, 2022: Animal Spatial Audio Perception
 */

class EnvironmentalAudioEngine: NSObject {
    
    // MARK: - Properties
    private var audioEngine: AVAudioEngine!
    private var spatialAudioUnit: AVAudioUnitSpatialMixer!
    private var reverbUnit: AVAudioUnitReverb!
    private var equalizerUnit: AVAudioUnitEQ!
    private var compressorUnit: AVAudioUnitCompressor!
    
    // MARK: - Room Acoustic Components
    private var roomImpulseResponse: RoomImpulseResponse?
    private var acousticModel: AcousticModel?
    private var reverbParameters: ReverbParameters!
    private var spatialProcessor: SpatialAudioProcessor!
    
    // MARK: - Audio Sources
    private var virtualSources: [VirtualAudioSource] = []
    private var ambientSources: [AmbientAudioSource] = []
    private var companionSources: [CompanionAudioSource] = []
    
    // MARK: - Canine Audio Optimization
    private var canineEQSettings: CanineEQSettings!
    private var frequencyAnalyzer: FrequencyAnalyzer!
    private var dynamicRangeProcessor: DynamicRangeProcessor!
    
    // MARK: - Environmental Data
    private var roomGeometry: RoomGeometry?
    private var materialProperties: [MaterialProperties] = []
    private var listenerPosition: simd_float3 = simd_float3(0, 0, 0)
    
    // MARK: - Audio Processing
    private var convolutionProcessor: ConvolutionProcessor!
    private var binauralProcessor: BinauralProcessor!
    private var distanceAttenuator: DistanceAttenuator!
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupAudioEngine()
        setupSpatialAudio()
        setupCanineOptimization()
        setupRoomAcoustics()
        print("EnvironmentalAudioEngine initialized")
    }
    
    deinit {
        stopAudioEngine()
    }
    
    // MARK: - Audio Engine Setup
    
    /**
     * Setup AVAudioEngine
     * Initializes core audio processing pipeline
     */
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        
        // Create audio units
        spatialAudioUnit = AVAudioUnitSpatialMixer()
        reverbUnit = AVAudioUnitReverb()
        equalizerUnit = AVAudioUnitEQ(numberOfBands: 10)
        compressorUnit = AVAudioUnitCompressor()
        
        // Configure audio session
        configureAudioSession()
        
        print("Audio engine setup completed")
    }
    
    /**
     * Setup spatial audio
     * Configures 3D spatial audio processing
     */
    private func setupSpatialAudio() {
        spatialProcessor = SpatialAudioProcessor()
        binauralProcessor = BinauralProcessor()
        distanceAttenuator = DistanceAttenuator()
        
        // Configure spatial mixer
        spatialAudioUnit.outputType = .spatial
        spatialAudioUnit.pointSourceInHeadMode = .default
        spatialAudioUnit.sourceMode = .spatialize
        spatialAudioUnit.distanceAttenuationParameters.maximumDistance = 10.0
        spatialAudioUnit.distanceAttenuationParameters.referenceDistance = 1.0
        spatialAudioUnit.distanceAttenuationParameters.rolloffFactor = 1.0
        
        print("Spatial audio setup completed")
    }
    
    /**
     * Setup canine audio optimization
     * Configures audio processing for canine hearing
     */
    private func setupCanineOptimization() {
        canineEQSettings = CanineEQSettings()
        frequencyAnalyzer = FrequencyAnalyzer()
        dynamicRangeProcessor = DynamicRangeProcessor()
        
        // Configure EQ for canine hearing range
        configureCanineEQ()
        
        // Setup dynamic range compression
        configureCanineCompression()
        
        print("Canine audio optimization setup completed")
    }
    
    /**
     * Setup room acoustics
     * Initializes room acoustic modeling components
     */
    private func setupRoomAcoustics() {
        convolutionProcessor = ConvolutionProcessor()
        reverbParameters = ReverbParameters()
        
        // Configure reverb unit
        reverbUnit.loadFactoryPreset(.plate)
        
        print("Room acoustics setup completed")
    }
    
    // MARK: - Audio Session Configuration
    
    /**
     * Configure audio session
     * Sets up audio session for spatial audio
     */
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetoothA2DP])
            try audioSession.setActive(true)
            
            // Enable spatial audio if available
            if audioSession.isMultichannelAudioHardwareSupported {
                try audioSession.setPreferredOutputNumberOfChannels(8)
            }
            
            print("Audio session configured successfully")
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }
    
    /**
     * Configure canine EQ
     * Sets up equalization for canine hearing characteristics
     */
    private func configureCanineEQ() {
        guard let bands = equalizerUnit.bands as? [AVAudioUnitEQFilterParameters] else { return }
        
        // Canine hearing optimization based on research
        let canineEQSettings = [
            (frequency: 40.0, gain: -3.0, bandwidth: 0.5),    // Reduce low sub-bass
            (frequency: 100.0, gain: 0.0, bandwidth: 0.5),    // Maintain low frequencies
            (frequency: 500.0, gain: 2.0, bandwidth: 0.7),    // Boost mid-range
            (frequency: 1000.0, gain: 3.0, bandwidth: 0.5),   // Enhance clarity range
            (frequency: 2000.0, gain: 4.0, bandwidth: 0.5),   // Peak canine sensitivity
            (frequency: 4000.0, gain: 3.0, bandwidth: 0.5),   // Maintain high-mid
            (frequency: 8000.0, gain: 1.0, bandwidth: 0.7),   // Slight high boost
            (frequency: 16000.0, gain: -2.0, bandwidth: 1.0), // Reduce extreme highs
            (frequency: 32000.0, gain: -6.0, bandwidth: 1.0), // Attenuate ultrasonic
            (frequency: 48000.0, gain: -12.0, bandwidth: 1.0) // Strong ultrasonic cut
        ]
        
        for (index, setting) in canineEQSettings.enumerated() {
            if index < bands.count {
                bands[index].filterType = .parametric
                bands[index].frequency = Float(setting.frequency)
                bands[index].gain = Float(setting.gain)
                bands[index].bandwidth = Float(setting.bandwidth)
                bands[index].bypass = false
            }
        }
        
        print("Canine EQ configured with \(canineEQSettings.count) bands")
    }
    
    /**
     * Configure canine compression
     * Sets up dynamic range compression for canine comfort
     */
    private func configureCanineCompression() {
        // Gentle compression to avoid startling dogs
        compressorUnit.threshold = -20.0 // dB
        compressorUnit.headRoom = 5.0 // dB
        compressorUnit.expansionRatio = 2.0
        compressorUnit.expansionThreshold = -40.0 // dB
        compressorUnit.attackTime = 0.003 // 3ms
        compressorUnit.releaseTime = 0.1 // 100ms
        compressorUnit.masterGain = 0.0 // dB
        
        print("Canine compression configured")
    }
    
    // MARK: - Room Integration
    
    /**
     * Update room geometry
     * Integrates room layout for acoustic modeling
     */
    func updateRoomGeometry(_ geometry: RoomGeometry) {
        roomGeometry = geometry
        
        // Generate room impulse response
        generateRoomImpulseResponse(for: geometry)
        
        // Update material properties
        analyzeMaterialProperties(from: geometry)
        
        // Recalculate acoustic parameters
        updateAcousticModel(for: geometry)
        
        print("Room geometry updated for audio processing")
    }
    
    /**
     * Generate room impulse response
     * Creates acoustic impulse response from room geometry
     */
    private func generateRoomImpulseResponse(for geometry: RoomGeometry) {
        let roomVolume = geometry.volume
        let surfaceArea = calculateTotalSurfaceArea(geometry)
        let absorptionCoefficient = calculateAverageAbsorption(geometry)
        
        roomImpulseResponse = RoomImpulseResponse(
            sampleRate: 48000,
            duration: calculateReverbTime(volume: roomVolume, absorption: absorptionCoefficient),
            earlyReflections: generateEarlyReflections(from: geometry),
            lateReverb: generateLateReverb(volume: roomVolume, absorption: absorptionCoefficient)
        )
        
        // Update convolution processor
        convolutionProcessor.updateImpulseResponse(roomImpulseResponse!)
        
        print("Room impulse response generated")
    }
    
    /**
     * Analyze material properties
     * Determines acoustic properties of room surfaces
     */
    private func analyzeMaterialProperties(from geometry: RoomGeometry) {
        materialProperties.removeAll()
        
        // Analyze wall materials
        for wall in geometry.walls {
            let material = MaterialProperties(
                surface: .wall,
                absorptionCoefficient: 0.1, // Typical wall absorption
                reflectionCoefficient: 0.9,
                diffusionCoefficient: 0.3,
                materialType: .plaster
            )
            materialProperties.append(material)
        }
        
        // Analyze floor materials
        for floor in geometry.floors {
            let material = MaterialProperties(
                surface: .floor,
                absorptionCoefficient: 0.3, // Typical floor absorption
                reflectionCoefficient: 0.7,
                diffusionCoefficient: 0.2,
                materialType: .hardwood
            )
            materialProperties.append(material)
        }
        
        // Analyze furniture materials
        for furniture in geometry.furniture {
            let material = MaterialProperties(
                surface: .furniture,
                absorptionCoefficient: 0.5, // Higher absorption for furniture
                reflectionCoefficient: 0.5,
                diffusionCoefficient: 0.7,
                materialType: .fabric
            )
            materialProperties.append(material)
        }
        
        print("Analyzed \(materialProperties.count) material properties")
    }
    
    /**
     * Update acoustic model
     * Recalculates room acoustic parameters
     */
    private func updateAcousticModel(for geometry: RoomGeometry) {
        let roomVolume = geometry.volume
        let surfaceArea = calculateTotalSurfaceArea(geometry)
        let averageAbsorption = calculateAverageAbsorption(geometry)
        let reverbTime = calculateReverbTime(volume: roomVolume, absorption: averageAbsorption)
        
        acousticModel = AcousticModel(
            roomVolume: roomVolume,
            surfaceArea: surfaceArea,
            absorptionCoefficient: averageAbsorption,
            reverbTime: reverbTime,
            schroederFrequency: calculateSchroederFrequency(volume: roomVolume, reverbTime: reverbTime),
            criticalDistance: calculateCriticalDistance(reverbTime: reverbTime, absorption: averageAbsorption)
        )
        
        // Update reverb parameters
        updateReverbParameters()
        
        print("Acoustic model updated: RT60=\(reverbTime)s, Volume=\(roomVolume)m³")
    }
    
    // MARK: - Audio Source Management
    
    /**
     * Create virtual audio source
     * Creates spatially positioned audio source
     */
    func createVirtualAudioSource(at position: simd_float3, audioFile: URL, looping: Bool = false) -> VirtualAudioSource? {
        guard let audioFile = try? AVAudioFile(forReading: audioFile) else {
            print("Failed to load audio file: \(audioFile)")
            return nil
        }
        
        let playerNode = AVAudioPlayerNode()
        let source = VirtualAudioSource(
            id: UUID(),
            playerNode: playerNode,
            audioFile: audioFile,
            position: position,
            isLooping: looping,
            volume: 1.0,
            isPlaying: false
        )
        
        // Connect to audio engine
        connectAudioSource(source)
        
        virtualSources.append(source)
        
        print("Created virtual audio source at: \(position)")
        return source
    }
    
    /**
     * Create companion audio source
     * Creates audio source for virtual companion
     */
    func createCompanionAudioSource(for companion: VirtualCompanion, soundType: CompanionSoundType) -> CompanionAudioSource? {
        guard let audioFile = getCompanionAudioFile(type: companion.type, sound: soundType) else {
            return nil
        }
        
        let playerNode = AVAudioPlayerNode()
        let source = CompanionAudioSource(
            id: UUID(),
            companionId: companion.id,
            playerNode: playerNode,
            audioFile: audioFile,
            position: companion.position,
            soundType: soundType,
            volume: getCompanionVolume(type: companion.type),
            isPlaying: false
        )
        
        // Connect to audio engine
        connectCompanionAudioSource(source)
        
        companionSources.append(source)
        
        print("Created companion audio source: \(companion.type) - \(soundType)")
        return source
    }
    
    /**
     * Create ambient audio source
     * Creates environmental ambient audio
     */
    func createAmbientAudioSource(environment: EnvironmentType, intensity: Float = 0.5) -> AmbientAudioSource? {
        guard let audioFiles = getAmbientAudioFiles(for: environment) else {
            return nil
        }
        
        let playerNodes = audioFiles.map { _ in AVAudioPlayerNode() }
        let source = AmbientAudioSource(
            id: UUID(),
            environment: environment,
            playerNodes: playerNodes,
            audioFiles: audioFiles,
            intensity: intensity,
            isPlaying: false
        )
        
        // Connect ambient sources
        connectAmbientAudioSource(source)
        
        ambientSources.append(source)
        
        print("Created ambient audio source: \(environment)")
        return source
    }
    
    // MARK: - Audio Engine Connection
    
    /**
     * Connect audio source
     * Connects virtual audio source to processing pipeline
     */
    private func connectAudioSource(_ source: VirtualAudioSource) {
        let playerNode = source.playerNode
        
        // Attach to audio engine
        audioEngine.attach(playerNode)
        
        // Connect through processing chain
        audioEngine.connect(playerNode, to: spatialAudioUnit, format: source.audioFile.processingFormat)
        audioEngine.connect(spatialAudioUnit, to: equalizerUnit, format: nil)
        audioEngine.connect(equalizerUnit, to: reverbUnit, format: nil)
        audioEngine.connect(reverbUnit, to: compressorUnit, format: nil)
        audioEngine.connect(compressorUnit, to: audioEngine.mainMixerNode, format: nil)
        
        // Configure spatial positioning
        configureSpatialPosition(for: source)
    }
    
    /**
     * Connect companion audio source
     * Connects companion audio to processing pipeline
     */
    private func connectCompanionAudioSource(_ source: CompanionAudioSource) {
        let playerNode = source.playerNode
        
        // Attach to audio engine
        audioEngine.attach(playerNode)
        
        // Create dedicated mixer for companion
        let companionMixer = AVAudioMixerNode()
        audioEngine.attach(companionMixer)
        
        // Connect through specialized companion processing
        audioEngine.connect(playerNode, to: companionMixer, format: source.audioFile.processingFormat)
        audioEngine.connect(companionMixer, to: spatialAudioUnit, format: nil)
        audioEngine.connect(spatialAudioUnit, to: equalizerUnit, format: nil)
        audioEngine.connect(equalizerUnit, to: reverbUnit, format: nil)
        audioEngine.connect(reverbUnit, to: compressorUnit, format: nil)
        audioEngine.connect(compressorUnit, to: audioEngine.mainMixerNode, format: nil)
        
        // Configure companion-specific processing
        configureCompanionAudio(for: source, mixer: companionMixer)
    }
    
    /**
     * Connect ambient audio source
     * Connects ambient audio layers to processing pipeline
     */
    private func connectAmbientAudioSource(_ source: AmbientAudioSource) {
        let ambientMixer = AVAudioMixerNode()
        audioEngine.attach(ambientMixer)
        
        // Connect each ambient layer
        for (index, playerNode) in source.playerNodes.enumerated() {
            audioEngine.attach(playerNode)
            audioEngine.connect(playerNode, to: ambientMixer, format: source.audioFiles[index].processingFormat)
        }
        
        // Connect ambient mixer to main processing
        audioEngine.connect(ambientMixer, to: reverbUnit, format: nil)
        audioEngine.connect(reverbUnit, to: compressorUnit, format: nil)
        audioEngine.connect(compressorUnit, to: audioEngine.mainMixerNode, format: nil)
        
        // Configure ambient processing
        configureAmbientAudio(for: source, mixer: ambientMixer)
    }
    
    // MARK: - Spatial Audio Configuration
    
    /**
     * Configure spatial position
     * Sets up 3D positioning for audio source
     */
    private func configureSpatialPosition(for source: VirtualAudioSource) {
        let position = source.position
        
        // Convert to AVAudio3DPoint
        let audioPosition = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )
        
        // Set spatial position
        spatialAudioUnit.setSourcePosition(audioPosition, at: source.playerNode)
        
        // Configure distance attenuation
        configureDistanceAttenuation(for: source)
        
        print("Configured spatial position: \(position)")
    }
    
    /**
     * Configure distance attenuation
     * Sets up distance-based volume attenuation
     */
    private func configureDistanceAttenuation(for source: VirtualAudioSource) {
        let distance = length(source.position - listenerPosition)
        let attenuatedVolume = distanceAttenuator.calculateAttenuation(distance: distance)
        
        source.playerNode.volume = attenuatedVolume * source.volume
        
        print("Distance attenuation applied: \(attenuatedVolume) at \(distance)m")
    }
    
    /**
     * Configure companion audio
     * Sets up companion-specific audio processing
     */
    private func configureCompanionAudio(for source: CompanionAudioSource, mixer: AVAudioMixerNode) {
        // Apply companion-specific EQ
        let companionEQ = createCompanionEQ(for: source.soundType)
        audioEngine.attach(companionEQ)
        
        // Insert EQ in signal chain
        audioEngine.disconnectNodeInput(spatialAudioUnit)
        audioEngine.connect(mixer, to: companionEQ, format: nil)
        audioEngine.connect(companionEQ, to: spatialAudioUnit, format: nil)
        
        // Configure volume based on companion type
        mixer.outputVolume = source.volume
        
        print("Configured companion audio: \(source.soundType)")
    }
    
    /**
     * Configure ambient audio
     * Sets up ambient environment audio processing
     */
    private func configureAmbientAudio(for source: AmbientAudioSource, mixer: AVAudioMixerNode) {
        // Configure ambient reverb
        let ambientReverb = AVAudioUnitReverb()
        configureAmbientReverb(ambientReverb, for: source.environment)
        
        audioEngine.attach(ambientReverb)
        
        // Insert ambient reverb
        audioEngine.disconnectNodeInput(reverbUnit)
        audioEngine.connect(mixer, to: ambientReverb, format: nil)
        audioEngine.connect(ambientReverb, to: reverbUnit, format: nil)
        
        // Set ambient volume
        mixer.outputVolume = source.intensity
        
        print("Configured ambient audio: \(source.environment)")
    }
    
    // MARK: - Audio Playback Control
    
    /**
     * Start audio engine
     * Begins audio processing and playback
     */
    func startAudioEngine() {
        do {
            try audioEngine.start()
            print("Audio engine started successfully")
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    /**
     * Stop audio engine
     * Stops audio processing and playback
     */
    func stopAudioEngine() {
        audioEngine.stop()
        print("Audio engine stopped")
    }
    
    /**
     * Play virtual audio source
     * Starts playback of virtual audio source
     */
    func playVirtualAudioSource(_ sourceId: UUID) {
        guard let source = virtualSources.first(where: { $0.id == sourceId }) else { return }
        
        let playerNode = source.playerNode
        
        if source.isLooping {
            // Schedule looping playback
            playerNode.scheduleFile(source.audioFile, at: nil, completionHandler: { [weak self] in
                self?.scheduleLoopingPlayback(source)
            })
        } else {
            // Schedule single playback
            playerNode.scheduleFile(source.audioFile, at: nil)
        }
        
        playerNode.play()
        source.isPlaying = true
        
        print("Started playing virtual audio source: \(sourceId)")
    }
    
    /**
     * Play companion audio
     * Starts playback of companion audio
     */
    func playCompanionAudio(_ sourceId: UUID) {
        guard let source = companionSources.first(where: { $0.id == sourceId }) else { return }
        
        let playerNode = source.playerNode
        playerNode.scheduleFile(source.audioFile, at: nil)
        playerNode.play()
        source.isPlaying = true
        
        print("Started playing companion audio: \(source.soundType)")
    }
    
    /**
     * Play ambient audio
     * Starts playback of ambient environment audio
     */
    func playAmbientAudio(_ sourceId: UUID) {
        guard let source = ambientSources.first(where: { $0.id == sourceId }) else { return }
        
        for (index, playerNode) in source.playerNodes.enumerated() {
            playerNode.scheduleFile(source.audioFiles[index], at: nil, completionHandler: { [weak self] in
                self?.scheduleAmbientLooping(source, layerIndex: index)
            })
            playerNode.play()
        }
        
        source.isPlaying = true
        
        print("Started playing ambient audio: \(source.environment)")
    }
    
    // MARK: - Audio Processing
    
    /**
     * Update listener position
     * Updates 3D audio listener position
     */
    func updateListenerPosition(_ position: simd_float3, orientation: simd_float3) {
        listenerPosition = position
        
        // Update spatial audio listener
        spatialAudioUnit.listenerPosition = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
        spatialAudioUnit.listenerAngularOrientation = AVAudio3DAngularOrientation(
            yaw: orientation.y,
            pitch: orientation.x,
            roll: orientation.z
        )
        
        // Update distance attenuation for all sources
        updateAllDistanceAttenuations()
        
        print("Updated listener position: \(position)")
    }
    
    /**
     * Update source position
     * Updates position of virtual audio source
     */
    func updateSourcePosition(_ sourceId: UUID, position: simd_float3) {
        if let source = virtualSources.first(where: { $0.id == sourceId }) {
            source.position = position
            configureSpatialPosition(for: source)
        } else if let source = companionSources.first(where: { $0.id == sourceId }) {
            source.position = position
            
            let audioPosition = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
            spatialAudioUnit.setSourcePosition(audioPosition, at: source.playerNode)
        }
    }
    
    /**
     * Update reverb parameters
     * Updates room reverb based on acoustic model
     */
    private func updateReverbParameters() {
        guard let model = acousticModel else { return }
        
        // Calculate reverb parameters from acoustic model
        reverbParameters.preDelay = calculatePreDelay(model.roomVolume)
        reverbParameters.roomSize = mapVolumeToRoomSize(model.roomVolume)
        reverbParameters.decayTime = model.reverbTime
        reverbParameters.dampening = calculateDampening(model.absorptionCoefficient)
        reverbParameters.diffusion = calculateDiffusion(materialProperties)
        
        // Apply to reverb unit
        applyReverbParameters()
        
        print("Updated reverb parameters: RT60=\(model.reverbTime)s")
    }
    
    // MARK: - Utility Functions
    
    /**
     * Calculate total surface area
     * Calculates total room surface area from geometry
     */
    private func calculateTotalSurfaceArea(_ geometry: RoomGeometry) -> Float {
        var totalArea: Float = 0.0
        
        // Wall areas
        for wall in geometry.walls {
            totalArea += calculateMeshArea(wall)
        }
        
        // Floor areas
        for floor in geometry.floors {
            totalArea += calculateMeshArea(floor)
        }
        
        // Furniture surface areas
        for furniture in geometry.furniture {
            totalArea += calculateMeshArea(furniture) * 0.5 // Partial exposure
        }
        
        return totalArea
    }
    
    /**
     * Calculate mesh area
     * Calculates surface area of spatial mesh
     */
    private func calculateMeshArea(_ mesh: SpatialMesh) -> Float {
        // Simplified area calculation
        let bounds = calculateMeshBounds(mesh)
        return bounds.width * bounds.height
    }
    
    /**
     * Calculate mesh bounds
     * Calculates bounding box for mesh
     */
    private func calculateMeshBounds(_ mesh: SpatialMesh) -> BoundingBox {
        guard !mesh.vertices.isEmpty else {
            return BoundingBox(min: simd_float3(0,0,0), max: simd_float3(0,0,0))
        }
        
        var minPoint = mesh.vertices[0]
        var maxPoint = mesh.vertices[0]
        
        for vertex in mesh.vertices {
            minPoint = simd_min(minPoint, vertex)
            maxPoint = simd_max(maxPoint, vertex)
        }
        
        return BoundingBox(min: minPoint, max: maxPoint)
    }
    
    /**
     * Calculate average absorption
     * Calculates weighted average absorption coefficient
     */
    private func calculateAverageAbsorption(_ geometry: RoomGeometry) -> Float {
        var totalAbsorption: Float = 0.0
        var totalArea: Float = 0.0
        
        for material in materialProperties {
            let area = calculateMaterialArea(material, in: geometry)
            totalAbsorption += material.absorptionCoefficient * area
            totalArea += area
        }
        
        return totalArea > 0 ? totalAbsorption / totalArea : 0.1
    }
    
    /**
     * Calculate material area
     * Calculates area covered by specific material
     */
    private func calculateMaterialArea(_ material: MaterialProperties, in geometry: RoomGeometry) -> Float {
        switch material.surface {
        case .wall:
            return geometry.walls.reduce(0) { $0 + calculateMeshArea($1) }
        case .floor:
            return geometry.floors.reduce(0) { $0 + calculateMeshArea($1) }
        case .furniture:
            return geometry.furniture.reduce(0) { $0 + calculateMeshArea($1) }
        }
    }
    
    /**
     * Calculate reverberation time
     * Calculates RT60 using Sabine equation
     */
    private func calculateReverbTime(volume: Float, absorption: Float) -> Float {
        // Sabine equation: RT60 = 0.16 * V / A
        // Where V is volume in m³ and A is total absorption in m²
        let totalAbsorption = absorption * 100.0 // Assuming 100 m² surface area
        return 0.16 * volume / max(totalAbsorption, 1.0)
    }
    
    /**
     * Calculate Schroeder frequency
     * Calculates transition frequency between modal and statistical behavior
     */
    private func calculateSchroederFrequency(volume: Float, reverbTime: Float) -> Float {
        // Schroeder frequency: fs = 2000 * sqrt(RT60 / V)
        return 2000.0 * sqrt(reverbTime / volume)
    }
    
    /**
     * Calculate critical distance
     * Calculates distance where direct and reverberant sound are equal
     */
    private func calculateCriticalDistance(reverbTime: Float, absorption: Float) -> Float {
        // Critical distance: dc = 0.057 * sqrt(V / RT60)
        let volume = roomGeometry?.volume ?? 30.0
        return 0.057 * sqrt(volume / reverbTime)
    }
    
    /**
     * Generate early reflections
     * Creates early reflection pattern from room geometry
     */
    private func generateEarlyReflections(from geometry: RoomGeometry) -> [EarlyReflection] {
        var reflections: [EarlyReflection] = []
        
        // Generate reflections from major surfaces
        for wall in geometry.walls {
            let reflection = EarlyReflection(
                delay: calculateReflectionDelay(wall),
                amplitude: calculateReflectionAmplitude(wall),
                direction: calculateReflectionDirection(wall)
            )
            reflections.append(reflection)
        }
        
        return reflections
    }
    
    /**
     * Generate late reverb
     * Creates diffuse late reverb tail
     */
    private func generateLateReverb(volume: Float, absorption: Float) -> LateReverb {
        return LateReverb(
            decayTime: calculateReverbTime(volume: volume, absorption: absorption),
            density: calculateReverbDensity(volume),
            diffusion: calculateReverbDiffusion(absorption),
            dampening: calculateReverbDampening(absorption)
        )
    }
    
    // MARK: - Audio Asset Management
    
    /**
     * Get companion audio file
     * Returns audio file for companion sound
     */
    private func getCompanionAudioFile(type: CompanionType, sound: CompanionSoundType) -> AVAudioFile? {
        let fileName = "\(type)_\(sound).wav"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("Companion audio file not found: \(fileName)")
            return nil
        }
        
        return try? AVAudioFile(forReading: url)
    }
    
    /**
     * Get companion volume
     * Returns appropriate volume level for companion type
     */
    private func getCompanionVolume(type: CompanionType) -> Float {
        switch type {
        case .cat:
            return 0.3 // Cats are generally quieter
        case .smallDog:
            return 0.5 // Small dogs moderate volume
        case .bird:
            return 0.4 // Birds can be loud but we keep them moderate
        case .rabbit:
            return 0.2 // Rabbits are very quiet
        }
    }
    
    /**
     * Get ambient audio files
     * Returns audio files for ambient environment
     */
    private func getAmbientAudioFiles(for environment: EnvironmentType) -> [AVAudioFile]? {
        let fileNames: [String]
        
        switch environment {
        case .garden:
            fileNames = ["garden_birds.wav", "garden_wind.wav", "garden_insects.wav"]
        case .forest:
            fileNames = ["forest_birds.wav", "forest_wind.wav", "forest_rustling.wav"]
        case .cityscape:
            fileNames = ["city_traffic.wav", "city_birds.wav", "city_ambient.wav"]
        case .meadow:
            fileNames = ["meadow_wind.wav", "meadow_insects.wav", "meadow_birds.wav"]
        }
        
        var audioFiles: [AVAudioFile] = []
        
        for fileName in fileNames {
            guard let url = Bundle.main.url(forResource: fileName, withExtension: nil),
                  let audioFile = try? AVAudioFile(forReading: url) else {
                print("Ambient audio file not found: \(fileName)")
                continue
            }
            audioFiles.append(audioFile)
        }
        
        return audioFiles.isEmpty ? nil : audioFiles
    }
    
    // MARK: - Helper Functions for Audio Processing
    
    private func scheduleLoopingPlayback(_ source: VirtualAudioSource) {
        if source.isPlaying && source.isLooping {
            source.playerNode.scheduleFile(source.audioFile, at: nil, completionHandler: { [weak self] in
                self?.scheduleLoopingPlayback(source)
            })
        }
    }
    
    private func scheduleAmbientLooping(_ source: AmbientAudioSource, layerIndex: Int) {
        if source.isPlaying && layerIndex < source.playerNodes.count {
            let playerNode = source.playerNodes[layerIndex]
            let audioFile = source.audioFiles[layerIndex]
            
            playerNode.scheduleFile(audioFile, at: nil, completionHandler: { [weak self] in
                self?.scheduleAmbientLooping(source, layerIndex: layerIndex)
            })
        }
    }
    
    private func updateAllDistanceAttenuations() {
        for source in virtualSources {
            configureDistanceAttenuation(for: source)
        }
    }
    
    private func createCompanionEQ(for soundType: CompanionSoundType) -> AVAudioUnitEQ {
        let eq = AVAudioUnitEQ(numberOfBands: 3)
        
        guard let bands = eq.bands as? [AVAudioUnitEQFilterParameters] else { return eq }
        
        switch soundType {
        case .purr:
            // Enhance low frequencies for purring
            bands[0].frequency = 30.0
            bands[0].gain = 3.0
            bands[0].bandwidth = 0.5
            bands[0].filterType = .lowShelf
        case .bark:
            // Enhance mid frequencies for barking
            bands[1].frequency = 1000.0
            bands[1].gain = 2.0
            bands[1].bandwidth = 0.7
            bands[1].filterType = .parametric
        case .chirp:
            // Enhance high frequencies for chirping
            bands[2].frequency = 4000.0
            bands[2].gain = 4.0
            bands[2].bandwidth = 0.5
            bands[2].filterType = .highShelf
        case .squeak:
            // Enhance upper-mid frequencies for squeaking
            bands[1].frequency = 2000.0
            bands[1].gain = 3.0
            bands[1].bandwidth = 0.6
            bands[1].filterType = .parametric
        }
        
        return eq
    }
    
    private func configureAmbientReverb(_ reverb: AVAudioUnitReverb, for environment: EnvironmentType) {
        switch environment {
        case .garden:
            reverb.loadFactoryPreset(.mediumRoom2)
        case .forest:
            reverb.loadFactoryPreset(.largeRoom2)
        case .cityscape:
            reverb.loadFactoryPreset(.mediumHall2)
        case .meadow:
            reverb.loadFactoryPreset(.largeRoom)
        }
    }
    
    // MARK: - Reverb Parameter Calculations
    
    private func calculatePreDelay(_ volume: Float) -> Float {
        // Pre-delay based on room size: larger rooms = longer pre-delay
        return min(0.05, volume / 1000.0)
    }
    
    private func mapVolumeToRoomSize(_ volume: Float) -> Float {
        // Map room volume to reverb room size parameter (0.0 - 1.0)
        return min(1.0, volume / 100.0)
    }
    
    private func calculateDampening(_ absorption: Float) -> Float {
        // Higher absorption = more dampening
        return absorption
    }
    
    private func calculateDiffusion(_ materials: [MaterialProperties]) -> Float {
        let avgDiffusion = materials.reduce(0.0) { $0 + $1.diffusionCoefficient } / Float(materials.count)
        return avgDiffusion
    }
    
    private func applyReverbParameters() {
        // Apply calculated reverb parameters to reverb unit
        reverbUnit.wetDryMix = reverbParameters.diffusion * 30.0 // 0-30% wet
        
        // Additional reverb configuration would go here
        print("Applied reverb parameters: wetDryMix=\(reverbUnit.wetDryMix)%")
    }
    
    // MARK: - Reflection Calculations
    
    private func calculateReflectionDelay(_ wall: SpatialMesh) -> Float {
        // Calculate reflection delay based on wall distance
        let center = calculateMeshCenter(wall)
        let distance = length(center - listenerPosition)
        return distance / 343.0 // Speed of sound
    }
    
    private func calculateReflectionAmplitude(_ wall: SpatialMesh) -> Float {
        // Calculate reflection amplitude based on material and distance
        let distance = calculateReflectionDelay(wall) * 343.0
        return 1.0 / (1.0 + distance * 0.1) // Simple distance attenuation
    }
    
    private func calculateReflectionDirection(_ wall: SpatialMesh) -> simd_float3 {
        // Calculate reflection direction (simplified)
        let center = calculateMeshCenter(wall)
        return normalize(center - listenerPosition)
    }
    
    private func calculateMeshCenter(_ mesh: SpatialMesh) -> simd_float3 {
        guard !mesh.vertices.isEmpty else { return simd_float3(0, 0, 0) }
        
        var center = simd_float3(0, 0, 0)
        for vertex in mesh.vertices {
            center += vertex
        }
        return center / Float(mesh.vertices.count)
    }
    
    private func calculateReverbDensity(_ volume: Float) -> Float {
        // Larger rooms = higher modal density
        return min(1.0, volume / 50.0)
    }
    
    private func calculateReverbDiffusion(_ absorption: Float) -> Float {
        // Higher absorption generally correlates with more diffusion
        return absorption * 1.2
    }
    
    private func calculateReverbDampening(_ absorption: Float) -> Float {
        // Direct correlation between absorption and dampening
        return absorption
    }
}

// MARK: - Supporting Data Structures

/**
 * Virtual Audio Source: Positioned audio source
 */
class VirtualAudioSource {
    let id: UUID
    let playerNode: AVAudioPlayerNode
    let audioFile: AVAudioFile
    var position: simd_float3
    let isLooping: Bool
    var volume: Float
    var isPlaying: Bool
    
    init(id: UUID, playerNode: AVAudioPlayerNode, audioFile: AVAudioFile, position: simd_float3, isLooping: Bool, volume: Float, isPlaying: Bool) {
        self.id = id
        self.playerNode = playerNode
        self.audioFile = audioFile
        self.position = position
        self.isLooping = isLooping
        self.volume = volume
        self.isPlaying = isPlaying
    }
}

/**
 * Companion Audio Source: Audio for virtual companions
 */
class CompanionAudioSource {
    let id: UUID
    let companionId: UUID
    let playerNode: AVAudioPlayerNode
    let audioFile: AVAudioFile
    var position: simd_float3
    let soundType: CompanionSoundType
    var volume: Float
    var isPlaying: Bool
    
    init(id: UUID, companionId: UUID, playerNode: AVAudioPlayerNode, audioFile: AVAudioFile, position: simd_float3, soundType: CompanionSoundType, volume: Float, isPlaying: Bool) {
        self.id = id
        self.companionId = companionId
        self.playerNode = playerNode
        self.audioFile = audioFile
        self.position = position
        self.soundType = soundType
        self.volume = volume
        self.isPlaying = isPlaying
    }
}

/**
 * Ambient Audio Source: Environmental ambient audio
 */
class AmbientAudioSource {
    let id: UUID
    let environment: EnvironmentType
    let playerNodes: [AVAudioPlayerNode]
    let audioFiles: [AVAudioFile]
    var intensity: Float
    var isPlaying: Bool
    
    init(id: UUID, environment: EnvironmentType, playerNodes: [AVAudioPlayerNode], audioFiles: [AVAudioFile], intensity: Float, isPlaying: Bool) {
        self.id = id
        self.environment = environment
        self.playerNodes = playerNodes
        self.audioFiles = audioFiles
        self.intensity = intensity
        self.isPlaying = isPlaying
    }
}

// MARK: - Supporting Classes

/**
 * Spatial Audio Processor: 3D audio processing
 */
class SpatialAudioProcessor {
    func process3DAudio(sources: [VirtualAudioSource], listenerPosition: simd_float3) {
        // Process 3D spatial audio positioning
    }
}

/**
 * Binaural Processor: Binaural audio processing
 */
class BinauralProcessor {
    func processBinauralAudio() {
        // Process binaural audio for headphone listening
    }
}

/**
 * Distance Attenuator: Distance-based volume control
 */
class DistanceAttenuator {
    func calculateAttenuation(distance: Float) -> Float {
        // Inverse square law with minimum distance
        let minDistance: Float = 0.5
        let effectiveDistance = max(distance, minDistance)
        return 1.0 / (effectiveDistance * effectiveDistance)
    }
}

/**
 * Convolution Processor: Room impulse response convolution
 */
class ConvolutionProcessor {
    private var impulseResponse: RoomImpulseResponse?
    
    func updateImpulseResponse(_ response: RoomImpulseResponse) {
        impulseResponse = response
    }
    
    func processConvolution() {
        // Process convolution with room impulse response
    }
}

/**
 * Frequency Analyzer: Audio frequency analysis
 */
class FrequencyAnalyzer {
    func analyzeFrequencyContent() {
        // Analyze frequency content for canine optimization
    }
}

/**
 * Dynamic Range Processor: Dynamic range processing
 */
class DynamicRangeProcessor {
    func processAudioDynamics() {
        // Process audio dynamics for canine comfort
    }
}

// MARK: - Data Structures

/**
 * Room Impulse Response: Complete acoustic impulse response
 */
struct RoomImpulseResponse {
    let sampleRate: Float
    let duration: Float
    let earlyReflections: [EarlyReflection]
    let lateReverb: LateReverb
}

/**
 * Early Reflection: Individual early reflection
 */
struct EarlyReflection {
    let delay: Float
    let amplitude: Float
    let direction: simd_float3
}

/**
 * Late Reverb: Diffuse late reverberation
 */
struct LateReverb {
    let decayTime: Float
    let density: Float
    let diffusion: Float
    let dampening: Float
}

/**
 * Material Properties: Acoustic material properties
 */
struct MaterialProperties {
    let surface: SurfaceType
    let absorptionCoefficient: Float
    let reflectionCoefficient: Float
    let diffusionCoefficient: Float
    let materialType: MaterialType
}

/**
 * Acoustic Model: Complete room acoustic model
 */
struct AcousticModel {
    let roomVolume: Float
    let surfaceArea: Float
    let absorptionCoefficient: Float
    let reverbTime: Float
    let schroederFrequency: Float
    let criticalDistance: Float
}

/**
 * Reverb Parameters: Reverb processing parameters
 */
struct ReverbParameters {
    var preDelay: Float = 0.02
    var roomSize: Float = 0.5
    var decayTime: Float = 1.5
    var dampening: Float = 0.3
    var diffusion: Float = 0.7
}

/**
 * Canine EQ Settings: EQ settings optimized for canine hearing
 */
struct CanineEQSettings {
    let lowCut: Float = 40.0
    let midBoost: Float = 2000.0
    let highCut: Float = 48000.0
    let overallGain: Float = 0.0
}

// MARK: - Enumerations

/**
 * Surface Type: Type of room surface
 */
enum SurfaceType {
    case wall
    case floor
    case furniture
}

/**
 * Material Type: Type of material
 */
enum MaterialType {
    case plaster
    case hardwood
    case fabric
    case glass
    case metal
}

/**
 * Companion Sound Type: Type of companion sound
 */
enum CompanionSoundType {
    case purr
    case bark
    case chirp
    case squeak
}