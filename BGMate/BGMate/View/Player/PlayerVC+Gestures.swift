//
//  PlayerVC+Gestures.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/5/25.
//

import UIKit

extension PlayerViewController {
    
    // MARK: - 제스처 설정
    
    // MARK: - 제스처 연결
    
    func setupDismissGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPan(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: - 제스처 처리: 드래그로 최소화
    @objc func handleDismissPan(_ gesture: UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: view.window)
        
        switch gesture.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed:
            if touchPoint.y - initialTouchPoint.y > 0 {
                let draggedDistance = touchPoint.y - initialTouchPoint.y
                view.frame.origin.y = draggedDistance
                
//                // 스와이프 진행도에 따라 배경 투명도 조절 (뒷배경 보이기 효과)
//                let progress = min(draggedDistance / dismissThreshold, 1.0)
//                let alpha = 1.0 - (progress * 0.3) // 최대 30%까지 투명해짐
//                view.backgroundColor = view.backgroundColor?.withAlphaComponent(alpha)
            }
        case .ended, .cancelled:
            if touchPoint.y - initialTouchPoint.y > dismissThreshold {
                minimizeToMiniPlayer()
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.view.frame.origin.y = 0
                    self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(1.0)
                }
            }
        default:
            break
        }
    }
}
