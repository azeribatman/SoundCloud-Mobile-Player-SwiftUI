//
//  Music.swift
//  SoundCloudPlayerSwiftUI
//
//  Created by Ayxan Səfərli on 05.03.24.
//

import Foundation

struct Music: Identifiable {
    let id = UUID()
    
    let artistName: String
    let musicName: String
    let coverName: String
    
    let fileName: String
    let fileExtension: FileExtension
    
    var fileURL: URL? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileExtension.rawValue) else { return nil }
        return URL(fileURLWithPath: path)
    }
    
    init(
        artistName: String,
        musicName: String,
        coverName: String,
        fileName: String,
        fileExtension: FileExtension
    ) {
        self.artistName = artistName
        self.musicName = musicName
        self.coverName = coverName
        self.fileName = fileName
        self.fileExtension = fileExtension
    }
}

extension Music {
    enum FileExtension: String {
        case mp3
        case wav
    }
}

extension Music {
    static func getMusicList() -> [Music] {
        let musicList = [
            Music(artistName: "Kankan", musicName: "Wokeup", coverName: "kankan-cover", fileName: "kankan-wokeup", fileExtension: .mp3),
            Music(artistName: "Baretta", musicName: "douji feva [prod. by glozula & ixzi]", coverName: "barretta-cover", fileName: "barretta-doujiFev", fileExtension: .mp3),
            Music(artistName: "Yeat", musicName: "ILUV", coverName: "yeat-cover", fileName: "yeat-iluv", fileExtension: .wav),
            Music(artistName: "$UICIDEBOY$", musicName: "VICES (FEAT. JGRXXN)", coverName: "suicideboys-cover", fileName: "suicideboys-vices", fileExtension: .mp3),
            Music(artistName: "21 Savage", musicName: "Red Sky (Dirty Sprite)", coverName: "21-cover", fileName: "21savage-redsky", fileExtension: .mp3)
        ]
        
        return musicList
    }
}
