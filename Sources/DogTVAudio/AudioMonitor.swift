import Foundation
import AVFoundation
import Accelerate
import Combine

@available(iOS 17.0, tvOS 17.0, macOS 10.15, *)
class AudioMonitor: ObservableObject, @unchecked Sendable {
    private let tapNode: AVAudioNode
    private let bufferSize: AVAudioFrameCount = 1024

    @Published var currentVolume: Float = 0.0
    @Published var peakVolume: Float = 0.0
    @Published var frequencySpectrum: [Float] = []

    private var fftSetup: OpaquePointer?

    init(tapNode: AVAudioNode) {
        self.tapNode = tapNode
        // TODO: Fix vDSP setup - temporarily disabled
        // self.fftSetup = vDSP_DFT_create_setup(nil, vDSP_Length(bufferSize), .FORWARD)
        setupMonitoring()
    }

    deinit {
        // TODO: Fix vDSP cleanup - temporarily disabled
        // if let fftSetup = fftSetup {
        //     vDSP_DFT_destroy_setup(fftSetup)
        // }
        tapNode.removeTap(onBus: 0)
    }

    private func setupMonitoring() {
        let format = tapNode.outputFormat(forBus: 0)
        tapNode.installTap(onBus: 0, bufferSize: bufferSize, format: format) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer)
        }
    }

    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }

        // Calculate RMS volume
        var rms: Float = 0.0
        vDSP_rmsqv(channelData, 1, &rms, vDSP_Length(buffer.frameLength))

        DispatchQueue.main.async {
            self.currentVolume = rms
            if rms > self.peakVolume {
                self.peakVolume = rms
            }
        }

        // Calculate frequency spectrum
        calculateFrequencySpectrum(channelData)
    }

    private func calculateFrequencySpectrum(_ data: UnsafePointer<Float>) {
        // TODO: Fix vDSP FFT processing - temporarily disabled
        /*
        guard let fftSetup = fftSetup else { return }

        var realIn = [Float](repeating: 0, count: Int(bufferSize))
        var imagIn = [Float](repeating: 0, count: Int(bufferSize))

        for i in 0..<Int(bufferSize) {
            realIn[i] = data[i]
        }

        var realOut = [Float](repeating: 0, count: Int(bufferSize))
        var imagOut = [Float](repeating: 0, count: Int(bufferSize))

        vDSP_DFT_execute(fftSetup, &realIn, &imagIn, &realOut, &imagOut)

        var magnitudes = [Float](repeating: 0, count: Int(bufferSize / 2))

        for i in 0..<magnitudes.count {
            let real = realOut[i]
            let imag = imagOut[i]
            let magnitude = sqrt(real * real + imag * imag)
            magnitudes[i] = magnitude
        }

        DispatchQueue.main.async {
            self.frequencySpectrum = magnitudes
        }
        */
    }

    func resetPeakVolume() {
        peakVolume = 0.0
    }
}
