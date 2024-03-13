//
//  MusicPlayerBarsView.swift
//  SoundCloudPlayerSwiftUI
//
//  Created by Ayxan Səfərli on 05.03.24.
//

import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

struct MusicPlayerBarsView: View {
    @EnvironmentObject private var viewModel: MusicPlayerViewModel
    
    var body: some View {
        ScrollView(.horizontal) {
            barsView
                .padding(.horizontal, 150)
        }
        .frame(height: 130)
        .animation(.easeInOut, value: viewModel.audioBars)
        .introspect(.scrollView, on: .iOS(.v13...)) { scrollView in
            viewModel.setupScrollView(scrollView)
        }
    }
    
    private var barsView: some View {
        HStack(spacing: 1) {
            ForEach(viewModel.audioBars) { audioBar in
                VStack(spacing: 0) {
                    Rectangle()
                        .foregroundStyle(audioBar.barColor)
                        .frame(width: 2.5, height: audioBar.barHeight * 0.6)
                        .animation(viewModel.dragging ? nil : .easeInOut, value: audioBar.barColor)
                    Rectangle()
                        .foregroundStyle(audioBar.barColor)
                        .frame(width: 2.5, height: audioBar.barHeight * 0.40)
                        .opacity(0.7)
                        .animation(viewModel.dragging ? nil : .easeInOut, value: audioBar.barColor)
                }
                .animation(.easeInOut(duration: 0.15), value: audioBar.barHeight)
            }
        }
        .frame(height: 130)
    }
}
