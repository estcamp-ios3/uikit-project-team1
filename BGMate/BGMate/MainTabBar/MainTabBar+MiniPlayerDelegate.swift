//
//  MainTabBar+MiniPlayerDelegate.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/5/25.
//

import UIKit

// MARK: - MiniPlayerDelegate 구현
extension MainTabBarController: MiniPlayerDelegate {
    
    // MARK: - 델리게이트: 탭으로 풀스크린 전환
    func miniPlayerDidTap() {
        // 현재 재생 중인 곡이 있는지 확인하고 PlayerViewController 표시
        let playerVC = PlayerViewController()
        
        // 저장된 재생 정보 사용 (없으면 기본값)
        let playingInfo = getCurrentPlayingInfo()
        if let playlist = playingInfo.playlist {
            playerVC.musicList = playlist
            playerVC.currentIndex = playingInfo.index
            playerVC.shouldRestartPlayback = false  // 재생 중인 곡을 다시 시작하지 않도록 설정
        } else {
            // 기본값 설정 (재생 정보가 없을 때)
            playerVC.musicList = Playlist(title: "현재 재생 중", coverImageName: "calm_cover", selectedTag: [], playlist: [songs[0], songs[1], songs[2]])
            playerVC.currentIndex = 0
            playerVC.shouldRestartPlayback = true
        }
        
        playerVC.modalPresentationStyle = .overFullScreen
        playerVC.miniPlayer = miniPlayerVC
        miniPlayerVC.delegate = playerVC
        
        selectedViewController?.present(playerVC, animated: true)
    }
    
    // MARK: - 델리게이트: 재생/일시정지
    func miniPlayerPlayPauseDidTap() {
        // AudioManager를 통해 재생/일시정지
        if AudioManager.shared.isPlaying {
            AudioManager.shared.pause()
        } else {
            AudioManager.shared.play()
        }
        miniPlayerVC.updatePlaybackState(isPlaying: AudioManager.shared.isPlaying)
    }
    
    // MARK: - 델리게이트: 다음 곡
    func miniPlayerNextDidTap() {
        // 다음 곡으로 이동 (셔플/반복 고려)
        if let nextIndex = getNextIndex() {
            if isShuffleOn {
                shuffledIndices.removeFirst()  // 다음 곡으로 이동할 때만 셔플 배열에서 제거
            }
            currentSongIndex = nextIndex
            playCurrentSong()
        }
    }
    
    // MARK: - 델리게이트: 이전 곡
    func miniPlayerPreviousDidTap() {
        // 이전 곡으로 이동 (셔플/반복 고려)
        let currentTime = AudioManager.shared.playerCurrentTime
        if currentTime > 1.0 {
            // 현재 곡 처음으로
            AudioManager.shared.seekTo(time: 0)
        } else if let prevIndex = getPrevIndex() {
            // 이전 곡이 있으면 이동
            playHistory.removeLast() // 현재 곡 제거
            currentSongIndex = prevIndex
            
            if isShuffleOn {
                // 이전 곡으로 돌아갈 때 셔플 순서 복원
                shuffledIndices = originalShuffledIndices.filter { $0 != currentSongIndex }
            }
            
            playCurrentSong()
        } else {
            // 현재 곡이 첫 곡이면 처음으로만 이동
            AudioManager.shared.seekTo(time: 0)
        }
    }
    
    // MARK: - Private Helper Methods
    
    // MARK: - 내부: 현재 곡 재생
    private func playCurrentSong() {
        guard let playlist = currentPlaylist,
              currentSongIndex >= 0,
              currentSongIndex < playlist.playlist.count else { return }
        
        // 현재 곡을 히스토리에 추가 (PlayerViewController와 동일)
        if playHistory.last != currentSongIndex {
            playHistory.append(currentSongIndex)
        }
        
        let currentSong = playlist.playlist[currentSongIndex]
        do {
            try AudioManager.shared.prepareAudioThrowing(named: currentSong.fileName, fileExtension: "mp3")
            AudioManager.shared.play()
        } catch {
            let alert = UIAlertController(
                title: "재생할 수 없습니다",
                message: "오디오 파일을 불러오지 못했습니다.\n\(error)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            selectedViewController?.present(alert, animated: true)
            return
        }
        
        // 플레이리스트 커버 이미지 가져오기
        var playlistImage: UIImage?
        if let coverImageName = playlist.coverImageName {
            playlistImage = UIImage(named: coverImageName)
        }
        
        // 미니플레이어 UI 업데이트
        miniPlayerVC.updateNowPlaying(song: currentSong, image: playlistImage)
        miniPlayerVC.updatePlaybackState(isPlaying: true)
        
        print("미니플레이어에서 곡 변경: \(currentSong.title)")
    }
    
    // MARK: - 내부: 다음 인덱스 계산
    private func getNextIndex() -> Int? {
        guard let playlist = currentPlaylist else { return nil }
        
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
            let nextIndex = currentSongIndex + 1
            if nextIndex < playlist.playlist.count {
                return nextIndex
            } else if isRepeatOn {
                return 0  // 반복 모드면 처음으로
            }
        }
        
        return nil  // 더 이상 재생할 곡이 없음
    }
    
    // MARK: - 내부: 이전 인덱스 계산
    private func getPrevIndex() -> Int? {
        if isShuffleOn {
            // 셔플 모드일 때는 히스토리 기반으로 이전 곡 결정
            if playHistory.count > 1 {
                return playHistory[playHistory.count - 2]
            }
        } else {
            // 셔플 모드가 꺼져있을 때는 현재 인덱스 기준으로 이전 곡 결정
            let prevIndex = currentSongIndex - 1
            if prevIndex >= 0 {
                return prevIndex
            }
        }
        return nil
    }
    
    // MARK: - 내부: 셔플 인덱스 생성
    private func createShuffledIndices() {
        guard let playlist = currentPlaylist else { return }
        
        // 현재 곡을 제외한 나머지 곡들의 인덱스로 배열 생성
        let indices = Array(0..<playlist.playlist.count).filter { $0 != currentSongIndex }
        
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
}
