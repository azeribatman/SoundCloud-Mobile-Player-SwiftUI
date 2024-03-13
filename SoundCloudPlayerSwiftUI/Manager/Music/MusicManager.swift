//
//  MusicManager.swift
//  SoundCloudPlayerSwiftUI
//
//  Created by Ayxan Səfərli on 01.03.24.
//

import Foundation
import AVFoundation
import UIKit
import Combine

final class MusicManager: NSObject {
    private let music: Music
    
    var dismissSubject = PassthroughSubject<Void, Never>()
    var timerLabelSubject: AnyPublisher<AttributedString, Never> {
        return musicTimeManager.timerLabelSubject.eraseToAnyPublisher()
    }
    var progressSubject: AnyPublisher<Float, Never> {
        return musicTimeManager.progressSubject.eraseToAnyPublisher()
    }
    
    private var musicTimeManager: MusicTimeManager
    private var player: AVAudioPlayer?
    
    init(music: Music) {
        self.music = music
        self.musicTimeManager = MusicTimeManager(music: music)
        super.init()
        self.createPlayer()
    }
}

// MARK: - Public functions

extension MusicManager {
    func playMusic() {
        self.player?.play()
        self.musicTimeManager.startTimer(with: player)
    }
    
    func passMusicTo(progress: Float, playing: Bool) {
        guard let player, progress != 1 else {
            dismissSubject.send(())
            return
        }
        let time = Float(player.duration) * progress
        player.stop()
        player.currentTime = TimeInterval(time)
        if playing {
            player.play()
        }
    }
    
    func stopMusic() {
        self.player?.stop()
    }
    
    func dismiss() {
        self.player?.stop()
        self.player = nil
        self.musicTimeManager.dismiss()
    }
    
    func handleProgress(with newValue: Float) {
        self.musicTimeManager.handleProgress(with: newValue)
    }
    
    func handleDragging(with newValue: Bool) {
        self.musicTimeManager.handleDragging(with: newValue)
    }
    
    func handlePlaying(with playing: Bool) {
        self.musicTimeManager.handlePlaying(with: playing)
        if playing {
            self.player?.play()
        } else {
            self.player?.pause()
        }
    }
}

// MARK: - Private functions

extension MusicManager {
    private func createPlayer() {
        guard let url = music.fileURL else { return }
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playback)
            try session.setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension MusicManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        dismissSubject.send(())
    }
}
