//
//  MusicPlayerViewModel.swift
//  SoundCloudPlayerSwiftUI
//
//  Created by Ayxan Səfərli on 05.03.24.
//

import Foundation
import Combine
import SwiftUI

final class MusicPlayerViewModel: ObservableObject {
    let music: Music
    
    @Published var playing = true
    @Published var dragging = false
    
    @Published var originalAudioBars = [AudioBar]()
    @Published var audioBars = AudioBar.getInitialBars()
    @Published var progress = Float(0)
    @Published var timeLabel = AttributedString("00:00")
    @Published var musicLabel: AttributedString
    
    var endedSubject: AnyPublisher<Void, Never> {
        return musicManager.dismissSubject.eraseToAnyPublisher()
    }
    
    private var musicManager: MusicManager
    private var musicWavesManager: MusicWavesManager
    private var musicScrollManager: MusicScrollManager
    private var cancellables = Set<AnyCancellable>()
    
    init(music: Music) {
        self.music = music
        self._musicLabel = Published(wrappedValue: MusicLabelManager.createArtistLabel(music: music, playing: true))
        self.musicManager = MusicManager(music: music)
        self.musicWavesManager = MusicWavesManager(music: music)
        self.musicScrollManager = MusicScrollManager()
        self.setupListeners()
    }
}

// MARK: - Public functions

extension MusicPlayerViewModel {
    func togglePlaying() {
        withAnimation(.easeInOut(duration: 0.2)) { playing.toggle() }
        musicManager.handlePlaying(with: playing)
        musicLabel = MusicLabelManager.createArtistLabel(music: music, playing: playing)
        if playing {
            audioBars.handle(with: originalAudioBars)
        } else {
            audioBars.pause()
        }
    }
    
    func setupScrollView(_ newValue: UIScrollView) {
        musicScrollManager.setup(with: newValue)
    }
    
    func dismiss() {
        musicManager.dismiss()
    }
}

// MARK: - Private functions

extension MusicPlayerViewModel {
    private func setupListeners() {
        musicWavesManager.audioBarsSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.originalAudioBars = newValue
                self?.audioBars.handle(with: newValue)
            }.store(in: &cancellables)
        
        musicManager.timerLabelSubject
            .sink { [weak self] newValue in
                self?.timeLabel = newValue
            }.store(in: &cancellables)
        
        musicManager.progressSubject
            .sink { [weak self] newValue in
                guard let self = self else { return }
                
                if !self.dragging {
                    self.progress = newValue
                    self.audioBars.handleProgress(with: newValue)
                    self.musicScrollManager.handleProgress(with: newValue)
                }
            }.store(in: &cancellables)
        
        musicScrollManager.draggingSubject
            .sink { [weak self] newValue in
                self?.musicManager.handleDragging(with: newValue)
                withAnimation(.smooth(duration: 0.3)) {
                    self?.dragging = newValue
                }
            }.store(in: &cancellables)
        
        musicScrollManager.progressSubject
            .sink { [weak self] newValue in
                guard let self = self else { return }
                
                self.progress = newValue
                self.audioBars.handleProgress(with: newValue)
                self.musicScrollManager.handleProgress(with: newValue)
                self.musicManager.handleProgress(with: newValue)
            }.store(in: &cancellables)
        
        musicScrollManager.draggingEndedWithProgressSubject
            .sink { [weak self] newValue in
                guard let self = self else { return }
                self.musicManager.passMusicTo(progress: newValue, playing: self.playing)
            }.store(in: &cancellables)
        
        endedSubject
            .sink { [weak self] in
                self?.dismiss()
        }.store(in: &cancellables)
        
        initialActions()
    }
    
    private func initialActions() {
        self.musicManager.playMusic()
    }
}
