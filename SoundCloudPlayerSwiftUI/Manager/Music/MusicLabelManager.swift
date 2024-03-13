//
//  MusicLabelManager.swift
//  SoundCloudPlayerSwiftUI
//
//  Created by Ayxan Səfərli on 06.03.24.
//

import Foundation
import UIKit

struct MusicLabelManager {
    static func createDurationLabel(
        currentDurationString: String,
        durationString: String,
        dragging: Bool,
        playing: Bool
    ) -> AttributedString {
        var firstPart: AttributedString {
            var result = AttributedString(" \(currentDurationString)  ")
            result.foregroundColor = .white
            result.font = .systemFont(ofSize: dragging ? 18  : 12, weight: .medium)
            return result
        }
        
        var seperator: AttributedString {
            var result = AttributedString("|")
            result.foregroundColor = .white
            result.font = .systemFont(ofSize: dragging ? 20  : 14, weight: .ultraLight)
            return result
        }
        
        var secondPart: AttributedString {
            var result = AttributedString("  \(durationString) ")
            result.foregroundColor = .systemGray
            result.font = .systemFont(ofSize: dragging ? 18  : 12, weight: .regular)
            return result
        }
        
        var resultString: AttributedString {
            var result = firstPart + seperator + secondPart
            result.backgroundColor = dragging || !playing ? .clear : .black
            return result
        }
        
        return resultString
    }
    
    static func createArtistLabel(
        music: Music,
        playing: Bool
    ) -> AttributedString {
        var musicName: AttributedString {
            var result = AttributedString(" \(music.musicName) \n")
            result.foregroundColor = .white
            result.font = .systemFont(ofSize: 20, weight: .semibold)
            return result
        }
        
        var artistName: AttributedString {
            var result = AttributedString(" \(music.artistName) ")
            result.foregroundColor = .white.withAlphaComponent(0.8)
            result.font = .systemFont(ofSize: 20, weight: .semibold)
            return result
        }
        
        var resultString: AttributedString {
            var result = musicName + artistName
            result.backgroundColor = playing ? .black : .clear
            return result
        }
        
        return resultString
    }
}
