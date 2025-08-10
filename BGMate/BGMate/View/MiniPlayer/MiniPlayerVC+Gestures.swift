//
//  MiniPlayerVC+Gestures.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/5/25.
//

import UIKit

extension MiniPlayerViewController {
    
    // MARK: - 제스처 설정
    
    // MARK: - 제스처 연결
    
    func setupGestures() {
        // 전체 탭 제스처
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(miniPlayerTapped))
        containerView.addGestureRecognizer(tapGesture)
        
        // 좌우 스와이프 제스처
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        leftSwipe.direction = .left
        containerView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        rightSwipe.direction = .right
        containerView.addGestureRecognizer(rightSwipe)
        
        // 위로 스와이프 제스처 (풀스크린으로 전환)
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleUpSwipe))
        upSwipe.direction = .up
        containerView.addGestureRecognizer(upSwipe)
    }
    
    // MARK: - 제스처 처리: 탭
    @objc func miniPlayerTapped() {
        delegate?.miniPlayerDidTap()
    }
    
    // MARK: - 제스처 처리: 좌우 스와이프
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            print("Left swipe detected")  // 디버깅용 로그
            delegate?.miniPlayerNextDidTap()
        } else if gesture.direction == .right {
            print("Right swipe detected")  // 디버깅용 로그
            delegate?.miniPlayerPreviousDidTap()
        }
    }
    
    // MARK: - 제스처 처리: 위로 스와이프 (풀스크린)
    @objc func handleUpSwipe() {
        // 위로 스와이프하면 풀스크린으로 전환 (탭과 동일한 동작)
        delegate?.miniPlayerDidTap()
    }
}
