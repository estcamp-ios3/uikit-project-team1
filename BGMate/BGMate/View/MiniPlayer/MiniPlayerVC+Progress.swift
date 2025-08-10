//
//  MiniPlayerVC+Progress.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/5/25.
//

import UIKit

extension MiniPlayerViewController {
    
    // MARK: - 진행 바 업데이트
    
    // MARK: - 타이머 시작
    func startProgressTimer() {
        stopProgressTimer()
        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    // MARK: - 타이머 정지
    func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    // MARK: - 진행률 갱신
    @objc func updateProgress() {
        let currentTime = AudioManager.shared.playerCurrentTime
        let duration = AudioManager.shared.playerDuration
        
        guard duration > 0 else { return }
        
        let progress = Float(currentTime / duration)
        progressView.setProgress(progress, animated: true)
    }
}
