//
//  HomeView.swift
//  SoundCloudPlayerSwiftUI
//
//  Created by Ayxan Səfərli on 05.03.24.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @State private var musics = Music.getMusicList()
    @State private var selectedMusic: Music?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(musics) { music in
                        musicView(music)
                    }
                }
                .padding(.top, 20)
            }
            .navigationTitle("Musics")
        }
        .fullScreenCover(item: $selectedMusic) { music in
            MusicPlayerView(viewModel: MusicPlayerViewModel(music: music))
        }
    }
    
    private func musicView(_ music: Music) -> some View {
        Button {
            selectedMusic = music
        } label: {
            HStack(spacing: 16) {
                Image(music.coverName)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                
                VStack {
                    Text(music.artistName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(uiColor: .label))
                    
                    Text(music.musicName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(uiColor: .label))
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
