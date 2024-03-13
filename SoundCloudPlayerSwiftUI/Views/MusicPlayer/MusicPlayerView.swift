//
//  MusicPlayerView.swift
//  SoundCloudPlayerSwiftUI
//
//  Created by Ayxan Səfərli on 01.03.24.
//

import SwiftUI

struct MusicPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: MusicPlayerViewModel
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                backgroundView(proxy)
                
                if !viewModel.dragging {
                    overlayView
                }
                
                barsView
                
                durationText
            }
            .onTapGesture { viewModel.togglePlaying() }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(30)
            .padding(.bottom, 60)
            .clipped()
            .background(.black)
        }
        .onReceive(viewModel.endedSubject) {
            self.dismiss()
        }
    }
    
    private var barsView: some View {
        MusicPlayerBarsView()
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 40)
            .environmentObject(viewModel)
    }
    
    private var overlayView: some View {
        headerView
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .overlay {
                actionButtons
            }
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        if !viewModel.playing {
            Circle()
                .frame(width: 60, height: 60)
                .foregroundColor(.black)
                .overlay {
                    Image(systemName: "play")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.white)
                        .padding(.leading, 5)
                }
        }
    }
    
    private var durationText: some View {
        VStack {
            Text(viewModel.timeLabel)
                .frame(maxHeight: .infinity, alignment: viewModel.dragging ? .center : .bottom)
                .padding(.bottom, viewModel.dragging ? 0 : 105)
                .allowsHitTesting(false)
                .animation(.bouncy(duration: 0.3), value: viewModel.dragging)
        }
    }
    
    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.musicLabel)
                
                HStack {
                    Image(systemName: "lines.measurement.horizontal")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color(.systemGray))
                        .frame(width: 14, height: 14)
                    
                    Text("Behind This Track")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(.systemGray))
                }
                .padding(.horizontal, 6)
                .background(viewModel.playing ? .black : .clear)
                .animation(nil, value: viewModel.playing)
            }
            
            Spacer()
            
            VStack(alignment: .center, spacing: 20) {
                Button {
                    viewModel.dismiss()
                    dismiss()
                } label: {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black)
                        .overlay {
                            Image(systemName: "chevron.down")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                                .foregroundStyle(.white)
                        }
                }
                
                Button {} label: {
                    Image(systemName: "person.badge.plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(20)
    }
    
    private func backgroundView(_ proxy: GeometryProxy) -> some View {
        GeometryReader { _ in
            Image(viewModel.music.coverName)
                .resizable()
                .frame(width: proxy.size.width * 2)
                .offset(x: min(-(proxy.size.width * CGFloat(viewModel.progress)), 0))
                .overlay(.black.opacity(0.3))
                .overlay(.regularMaterial.opacity(viewModel.dragging || !viewModel.playing ? 1 : 0))
                .preferredColorScheme(.dark)
        }
    }
}
