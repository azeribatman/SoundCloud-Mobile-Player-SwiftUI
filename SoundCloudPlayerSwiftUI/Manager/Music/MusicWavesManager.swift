//
//  MusicWavesManager.swift
//  SoundCloudPlayerSwiftUI
//
//  Created by Ayxan Səfərli on 05.03.24.
//

import Foundation
import AVFoundation
import SwiftUI
import Combine

struct MusicWavesManager {
    private let music: Music
    
    let audioBarsSubject = PassthroughSubject<[AudioBar], Never>()
    
    init(music: Music) {
        self.music = music
        getAudioBuffer()
    }
    
    private func getAudioBuffer() {
        DispatchQueue.global(qos: .utility).async {
            guard let url = music.fileURL else { return }
            
            guard let file = try? AVAudioFile(forReading: url) else { return }
            
            let audioFormat = file.processingFormat
            let audioFrameCount = UInt32(file.length)
            
            guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount) else { return }
            
            do {
                try file.read(into: buffer)
            } catch {
                print(error)
            }
            
            let samples = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength)))
            
            let downsampled = downsample(amplitudes: samples, targetCount: 150)
            
            let normalizedValues = getNormalizedValues(amplitudes: downsampled)
            
            let audioBars = normalizedValues.map { normalizedValue in
                return AudioBar(barHeight: normalizedValue)
            }
            
            self.audioBarsSubject.send(audioBars)
        }
    }
    
    private func getNormalizedValues(amplitudes: [Float]) -> [CGFloat] {
        let maxBarHeight: CGFloat = 150
        let minThreshold: CGFloat = 10

        guard let maxAmplitude = amplitudes.max(), let minAmplitude = amplitudes.min() else {
            fatalError("No amplitudes found")
        }
        
        let minAmplitudeNormalized = minAmplitude * 0.6

        let scaledAmplitudes = amplitudes.map { amplitude in
            let scaledAmplitude = log10(1 + amplitude - minAmplitudeNormalized) / log10(1 + maxAmplitude - minAmplitudeNormalized)
            return scaledAmplitude
        }

        let scaledBarHeights = scaledAmplitudes.map { scaledAmplitude in
            let barHeight = CGFloat(scaledAmplitude) * maxBarHeight
            return max(barHeight, minThreshold)
        }
        
        return scaledBarHeights
    }
    
    func downsample(amplitudes: [Float], targetCount: Int) -> [Float] {
        let chunkSize = amplitudes.count / targetCount
        var downsampledAmplitudes = [Float]()
        
        for i in stride(from: 0, to: amplitudes.count, by: chunkSize) {
            let chunk = Array(amplitudes[i..<min(i + chunkSize, amplitudes.count)])
            let average = chunk.reduce(0, +) / Float(chunk.count)
            downsampledAmplitudes.append(average)
        }
        
        return downsampledAmplitudes
    }
}

struct AudioBar: Identifiable, Hashable {
    let id = UUID()
    
    var barHeight: CGFloat
    var barColor: Color
    
    init(
        barHeight: CGFloat = 1,
        barColor: Color = .white
    ) {
        self.barHeight = barHeight
        self.barColor = barColor
    }
    
    static func getInitialBars() -> [AudioBar] {
        var bars = [AudioBar]()
        
        for _ in 0...150 {
            bars.append(AudioBar())
        }
        
        return bars
    }
}

extension Array where Element == AudioBar {
    mutating func handle(with newValues: [AudioBar]) {
        for (index, item) in newValues.enumerated() {
            self[index].barHeight = item.barHeight
            self[index].barColor = item.barColor
        }
    }
    
    mutating func handleProgress(with progress: Float) {
        let maxIndex = Int(Float(self.count) * progress)
        for (index, _) in self.enumerated() {
            if index <= maxIndex {
                self[index].barColor = .orange
            } else {
                self[index].barColor = .white
            }
        }
    }
    
    mutating func pause() {
        for (index, _) in self.enumerated() {
            self[index].barHeight = 1
        }
    }
}
