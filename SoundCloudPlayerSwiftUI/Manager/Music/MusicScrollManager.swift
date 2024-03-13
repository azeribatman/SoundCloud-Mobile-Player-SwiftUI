//
//  MusicScrollManager.swift
//  SoundCloudPlayerSwiftUI
//
//  Created by Ayxan Səfərli on 06.03.24.
//

import Foundation
import UIKit
import Combine

final class MusicScrollManager: NSObject, ObservableObject {
    private var scrollView: UIScrollView?
    
    var progressSubject = PassthroughSubject<Float, Never>()
    var draggingSubject = PassthroughSubject<Bool, Never>()
    var draggingEndedWithProgressSubject = PassthroughSubject<Float, Never>()
    
    private var dragging = false
    
    override init() {
        super.init()
    }
    
    func setup(with scrollView: UIScrollView) {
        self.scrollView = scrollView
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.decelerationRate = .fast
    }
    
    func handleProgress(with newValue: Float) {
        guard let scrollView, !dragging else { return }
        scrollView.contentOffset = .init(
            x: (scrollView.contentSize.width - scrollView.frame.width) * CGFloat(newValue),
            y: 0
        )
    }
}

extension MusicScrollManager: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if dragging {
            progressSubject.send(getProgress(with: scrollView))
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dragging = true
        draggingSubject.send(dragging)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            dragging = false
            draggingSubject.send(dragging)
            draggingEndedWithProgressSubject.send(getProgress(with: scrollView))
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dragging = false
        draggingSubject.send(dragging)
        draggingEndedWithProgressSubject.send(getProgress(with: scrollView))
    }
    
    private func getProgress(with scrollView: UIScrollView) -> Float {
        let maxOffset = scrollView.contentSize.width - scrollView.frame.width
        let progress = min(1, max(0, scrollView.contentOffset.x / maxOffset))
        return Float(progress)
    }
}
