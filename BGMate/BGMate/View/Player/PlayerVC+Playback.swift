//
//  PlayerVC+Playback.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/5/25.
//

import UIKit

extension PlayerViewController {
    
    // MARK: - 재생 관련 메소드
    
    func createShuffledIndices() {
        // 현재 곡을 제외한 나머지 곡들의 인덱스로 배열 생성
        let indices = Array(0..<musicList.playlist.count).filter { $0 != currentIndex }
        
        // Fisher-Yates 알고리즘으로 셔플
        var shuffled = indices
        for i in (0..<shuffled.count).reversed() {
            let j = Int.random(in: 0...i)
            shuffled.swapAt(i, j)
        }
        
        // 원본 셔플 순서 저장
        originalShuffledIndices = shuffled
        // 현재 재생할 셔플 순서 설정
        shuffledIndices = shuffled
    }
    
    @objc func handlePlaybackFinished() {
        if let nextIndex = getNextIndex() {
            if isShuffleOn {
                shuffledIndices.removeFirst()  // 자동 재생으로 다음 곡으로 이동할 때도 셔플 배열에서 제거
            }
            currentIndex = nextIndex
            updatePlayerForCurrentIndex()
        } else {
            // 다음 곡이 없고 반복도 꺼져있으면 재생 중지
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    func updatePlayerForCurrentIndex() {
        guard !musicList.playlist.isEmpty, currentIndex >= 0, currentIndex < musicList.playlist.count else { return }
        
        // 현재 곡을 히스토리에 추가
        if playHistory.last != currentIndex {
            playHistory.append(currentIndex)
        }
        
        let fileName = musicList.playlist[currentIndex].fileName
        do {
            try AudioManager.shared.prepareAudioThrowing(named: fileName, fileExtension: "mp3")
            AudioManager.shared.play()
        } catch {
            let alert = UIAlertController(
                title: "재생할 수 없습니다",
                message: "오디오 파일을 불러오지 못했습니다.\n\(error)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            return
        }
        
        // 재생 버튼 이미지 업데이트 (재생 중이므로 pause 이미지로)
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        
        // UI 업데이트
        titleLabel.text = musicList.playlist[currentIndex].title
        artistLabel.text = musicList.playlist[currentIndex].artist
        updateBackgroundImage() // ADD
        
        // 레이아웃이 완료된 후 스크롤링 애니메이션 시작
        DispatchQueue.main.async { [weak self] in
            self?.startTitleScrollingIfNeeded()
        }
        
        // 미니플레이어도 업데이트
        miniPlayer?.updateNowPlaying(
            song: musicList.playlist[currentIndex],
            image: albumImageView.image
        )
        miniPlayer?.updatePlaybackState(isPlaying: true)
        
        // MainTabBarController의 재생 정보도 업데이트
        if let tabBarController = presentingViewController as? MainTabBarController {
            tabBarController.setCurrentPlayingInfo(playlist: musicList, index: currentIndex)
        }
        
        // 셔플/반복 상태도 동기화
        syncWithMainTabBarController()
        
        startPlaybackTimer()
    }
    
    func updateUIForCurrentIndex() {
        guard !musicList.playlist.isEmpty, currentIndex >= 0, currentIndex < musicList.playlist.count else { return }
        
        // UI 업데이트만 수행
        titleLabel.text = musicList.playlist[currentIndex].title
        artistLabel.text = musicList.playlist[currentIndex].artist
        updateBackgroundImage() 
        
        // 레이아웃이 완료된 후 스크롤링 애니메이션 시작
        DispatchQueue.main.async { [weak self] in
            self?.startTitleScrollingIfNeeded()
        }
        
        // 재생 버튼 상태 업데이트 (현재 재생 상태에 따라)
        let imageName = AudioManager.shared.isPlaying ? "pause.fill" : "play.fill"
        playButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        // 🔧 슬라이더 즉시 현재 위치로 동기화 (움직임 방지)
        let currentTime = AudioManager.shared.playerCurrentTime
        let duration = AudioManager.shared.playerDuration
        if duration > 0 {
            progressSlider.maximumValue = Float(duration)
            progressSlider.setValue(Float(currentTime), animated: false)  // animated: false로 즉시 설정
            currentTimeLabel.text = formatTime(currentTime)
            durationLabel.text = "-" + formatTime(duration - currentTime)
        }
        
        // 미니플레이어도 업데이트
        miniPlayer?.updateNowPlaying(
            song: musicList.playlist[currentIndex],
            image: albumImageView.image
        )
        miniPlayer?.updatePlaybackState(isPlaying: AudioManager.shared.isPlaying)
        
        // MainTabBarController의 재생 정보도 업데이트
        if let tabBarController = presentingViewController as? MainTabBarController {
            tabBarController.setCurrentPlayingInfo(playlist: musicList, index: currentIndex)
        }
        
        startPlaybackTimer()
    }
    
    func syncWithMainTabBarController() {
        if let tabBarController = presentingViewController as? MainTabBarController {
            tabBarController.syncPlaybackState(
                isShuffleOn: isShuffleOn,
                isRepeatOn: isRepeatOn,
                shuffledIndices: shuffledIndices,
                playHistory: playHistory,
                originalShuffledIndices: originalShuffledIndices
            )
        }
    }
    
    func syncFromMainTabBarController() {
        if let tabBarController = presentingViewController as? MainTabBarController {
            let state = tabBarController.getCurrentPlaybackState()
            
            // 상태 동기화
            isShuffleOn = state.isShuffleOn
            isRepeatOn = state.isRepeatOn
            shuffledIndices = state.shuffledIndices
            playHistory = state.playHistory
            originalShuffledIndices = state.originalShuffledIndices
            
            // 버튼 UI 업데이트
            updateShuffleRepeatButtonsUI()
            
            print("풀스크린으로 상태 동기화: 셔플=\(isShuffleOn), 반복=\(isRepeatOn)")
        }
    }
    
    func updateShuffleRepeatButtonsUI() {
        UIView.animate(withDuration: 0.2) {
            self.shuffleButton.tintColor = self.isShuffleOn ? .white : .white.withAlphaComponent(0.4)
            self.repeatButton.tintColor = self.isRepeatOn ? .white : .white.withAlphaComponent(0.4)
        }
    }
    
    func getNextIndex() -> Int? {
        if isShuffleOn {
            // 셔플 모드일 때
            if let nextIndex = shuffledIndices.first {
                // 셔플된 다음 곡이 있으면 반환
                return nextIndex
            } else if isRepeatOn {
                // 반복 모드가 켜져있으면 새로운 셔플 순서 생성
                createShuffledIndices()
                return shuffledIndices.first
            }
            // 셔플된 곡을 모두 재생했고 반복 모드도 꺼져있으면 nil 반환
            return nil
        } else {
            // 셔플 모드가 꺼져있을 때는 순차적으로 다음 곡 결정
            let nextIndex = currentIndex + 1
            if nextIndex < musicList.playlist.count {
                return nextIndex
            } else if isRepeatOn {
                return 0  // 반복 모드면 처음으로
            }
        }
        
        return nil  // 더 이상 재생할 곡이 없음
    }
    
    func getPrevIndex() -> Int? {
        if isShuffleOn {
            // 셔플 모드일 때는 히스토리 기반으로 이전 곡 결정
            if playHistory.count > 1 {
                return playHistory[playHistory.count - 2]
            }
        } else {
            // 셔플 모드가 꺼져있을 때는 현재 인덱스 기준으로 이전 곡 결정
            let prevIndex = currentIndex - 1
            if prevIndex >= 0 {
                return prevIndex
            }
        }
        return nil
    }
    
    func startPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(updatePlaybackUI), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    @objc func updatePlaybackUI() {
        let current = AudioManager.shared.playerCurrentTime
        let duration = AudioManager.shared.playerDuration
        progressSlider.maximumValue = Float(duration)
        progressSlider.value = Float(current)
        currentTimeLabel.text = formatTime(current)
        durationLabel.text = "-" + formatTime(duration - current)
    }
}
