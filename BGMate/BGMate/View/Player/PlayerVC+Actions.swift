//
//  PlayerVC+Actions.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/5/25.
//

import UIKit

extension PlayerViewController {
    
    // MARK: - 버튼 액션 설정
    
    // MARK: - 버튼 타깃 연결
    
    func setupActions() {
        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        shuffleButton.addTarget(self, action: #selector(shuffleTapped), for: .touchUpInside)
        repeatButton.addTarget(self, action: #selector(repeatTapped), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    
    // MARK: - 액션: 닫기
    @objc func dismissTapped() {
        stopPlaybackTimer()
        stopTitleScrolling()
        minimizeToMiniPlayer()
    }
    
    // MARK: - 액션: 재생/일시정지
    @objc func playTapped() {
        if AudioManager.shared.isPlaying {
            AudioManager.shared.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            AudioManager.shared.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    // MARK: - 액션: 셔플
    @objc func shuffleTapped() {
        isShuffleOn.toggle()
        UIView.animate(withDuration: 0.4) {
            self.shuffleButton.tintColor = self.isShuffleOn ? .white : .white.withAlphaComponent(0.4)
        }
        
        // 현재 재생 중인 곡의 인덱스 저장
        _ = currentIndex
        
        if isShuffleOn {
            // 셔플 모드를 켤 때
            playHistory = [currentIndex] // 현재 곡만 남기고 히스토리 초기화
            createShuffledIndices()
        } else {
            // 셔플 모드를 끌 때
            playHistory = [currentIndex] // 현재 곡만 남기고 히스토리 초기화
            shuffledIndices = []
            originalShuffledIndices = []
        }
        
        // MainTabBarController와 상태 동기화
        syncWithMainTabBarController()
    }
    
    // MARK: - 액션: 반복
    @objc func repeatTapped() {
        isRepeatOn.toggle()
        UIView.animate(withDuration: 0.4) {
            self.repeatButton.tintColor = self.isRepeatOn ? .white : .white.withAlphaComponent(0.4)
        }
        
        // MainTabBarController와 상태 동기화
        syncWithMainTabBarController()
    }
    
    // MARK: - 액션: 이전 곡
    @objc func prevTapped() {
        let currentTime = AudioManager.shared.playerCurrentTime
        if currentTime > 1.0 {
            // 현재 곡 처음으로
            AudioManager.shared.seekTo(time: 0)
        } else if let prevIndex = getPrevIndex() {
            // 이전 곡이 있으면 이동
            playHistory.removeLast() // 현재 곡 제거
            currentIndex = prevIndex
            
            if isShuffleOn {
                // 이전 곡으로 돌아갈 때 셔플 순서 복원
                shuffledIndices = originalShuffledIndices.filter { $0 != currentIndex }
            }
            
            updatePlayerForCurrentIndex()
        } else {
            // 현재 곡이 첫 곡이면 처음으로만 이동
            AudioManager.shared.seekTo(time: 0)
        }
    }
    
    // MARK: - 액션: 다음 곡
    @objc func nextTapped() {
        if let nextIndex = getNextIndex() {
            if isShuffleOn {
                shuffledIndices.removeFirst()  // 다음 곡으로 이동할 때만 셔플 배열에서 제거
            }
            currentIndex = nextIndex
            updatePlayerForCurrentIndex()
        }
    }
    
    // MARK: - 액션: 슬라이더 변경
    @objc func sliderValueChanged(_ sender: UISlider) {
        AudioManager.shared.seekTo(time: TimeInterval(sender.value))
        updatePlaybackUI()
    }
    
    // MARK: - 유틸리티: 시간 포맷
    func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
