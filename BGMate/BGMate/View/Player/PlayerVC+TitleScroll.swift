//
//  PlayerVC+TitleScroll.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/5/25.
//

import UIKit

extension PlayerViewController {
    
    // MARK: - 제목 스크롤링
    
    func startTitleScrollingIfNeeded() {
        // 기존 애니메이션 정지
        stopTitleScrolling()
        
        // 텍스트가 컨테이너보다 길 때만 스크롤링 시작
        titleLabel.sizeToFit()
        let labelWidth = titleLabel.frame.width
        let scrollViewWidth = titleScrollView.frame.width
        
        guard labelWidth > scrollViewWidth else {
            // 텍스트가 짧으면 스크롤링 불필요
            titleScrollView.contentOffset = CGPoint.zero
            return
        }
        
        // 스크롤링 시작
        isScrollingTitle = true
        titleScrollView.contentSize = CGSize(width: labelWidth, height: titleScrollView.frame.height)
        
        // 2초 후 스크롤링 시작
        titleScrollTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.performTitleScrollAnimation()
        }
    }
    
    // MARK: - 제목 스크롤 애니메이션 수행
    func performTitleScrollAnimation() {
        guard isScrollingTitle else { return }
        
        let labelWidth = titleLabel.frame.width
        let scrollViewWidth = titleScrollView.frame.width
        let scrollDistance = labelWidth - scrollViewWidth + 20 // 여백 추가
        
        // 일정한 속도 계산 (픽셀/초)
        let scrollSpeed: CGFloat = 60.0 // 60 픽셀/초로 고정 (적당한 속도)
        let scrollDuration = TimeInterval(scrollDistance / scrollSpeed)
        let returnDuration = TimeInterval(scrollDistance / (scrollSpeed * 1.2)) // 복귀는 조금 더 빠르게
        
        // 최소/최대 시간 제한 (너무 빠르거나 느리지 않게)
        let minDuration: TimeInterval = 1.0
        let maxDuration: TimeInterval = 8.0
        let finalScrollDuration = max(minDuration, min(maxDuration, scrollDuration))
        let finalReturnDuration = max(minDuration, min(maxDuration, returnDuration))
        
        // 오른쪽 끝까지 스크롤 (계산된 시간)
        UIView.animate(withDuration: finalScrollDuration, delay: 0, options: [.curveLinear], animations: {
            self.titleScrollView.contentOffset = CGPoint(x: scrollDistance, y: 0)
        }) { [weak self] _ in
            // 1초 대기 후 처음으로 돌아가기
            self?.titleScrollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                UIView.animate(withDuration: finalReturnDuration, delay: 0, options: [.curveLinear], animations: {
                    self?.titleScrollView.contentOffset = CGPoint.zero
                }) { [weak self] _ in
                    // 2초 대기 후 다시 스크롤링 시작
                    self?.titleScrollTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                        self?.performTitleScrollAnimation()
                    }
                }
            }
        }
    }
    
    // MARK: - 제목 스크롤 정지
    func stopTitleScrolling() {
        isScrollingTitle = false
        titleScrollTimer?.invalidate()
        titleScrollTimer = nil
        titleScrollView.layer.removeAllAnimations()
    }
}
