//
//  MusicTimeManager.swift
//  SoundCloudPlayerSwiftUI
//
//  Created by Ayxan Səfərli on 05.03.24.
//

import Foundation
import Combine
import AVFoundation

final class MusicTimeManager {
    private let music: Music
    
    let timerLabelSubject = PassthroughSubject<AttributedString, Never>()
    let progressSubject = PassthroughSubject<Float, Never>()
    
    private var timer: Timer?
    private var player: AVAudioPlayer?
    private var timerCount: Float = 0
    private var dragging = false
    private var playing = true
    
    private lazy var calendar: Calendar = {
        let calendar = Calendar(identifier: .gregorian)
        return calendar
    }()
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        return formatter
    }()
    
    private var duration: Float {
        Float(player?.duration ?? 0)
    }
    
    init(music: Music) {
        self.music = music
        self.createTimer()
    }
}

// MARK: - Public functions

extension MusicTimeManager {
    func handlePlaying(with playing: Bool) {
        self.playing = playing
        self.timerTriggered()
        if playing {
            self.createTimer()
            self.timer?.fire()
        } else {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    func handleProgress(with newValue: Float) {
        self.timerCount = Float(Int(newValue * duration))
        self.timerTriggered()
    }
    
    func handleDragging(with newValue: Bool) {
        self.dragging = newValue
        if !playing {
            self.timerTriggered()
        }
    }
    
    func startTimer(with player: AVAudioPlayer?) {
        self.player = player
        self.timer?.fire()
    }
    
    func dismiss() {
        self.timer?.invalidate()
        self.timer = nil
        self.player = nil
    }
}

// MARK: - Private functions

extension MusicTimeManager {
    private func createTimer() {
        self.timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(timerTriggered),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc private func timerTriggered() {
        if playing { self.timerCount += 0.1 }
        
        let currentDurationDateComponents = DateComponents(second: Int(timerCount))
        let durationDateComponents = DateComponents(second: Int(duration))
        guard let currentDurationDate = calendar.date(from: currentDurationDateComponents) else { return }
        guard let durationDate = calendar.date(from: durationDateComponents) else { return }
        
        self.calculateProgress()
        
        let currentDurationString = formatter.string(from: currentDurationDate)
        let durationString = formatter.string(from: durationDate)
        
        let label = MusicLabelManager.createDurationLabel(
            currentDurationString: currentDurationString,
            durationString: durationString,
            dragging: dragging,
            playing: playing
        )
        
        self.timerLabelSubject.send(label)
    }
    
    private func calculateProgress() {
        let progress = timerCount / Float(duration)
        self.progressSubject.send(progress)
    }
}
