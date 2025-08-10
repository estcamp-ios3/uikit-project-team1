//
//  PlayerVC+MiniPlayer.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/5/25.
//

import UIKit

extension PlayerViewController {
    
    // MARK: - 미니플레이어 연결 및 전환
    
    func minimizeToMiniPlayer() {
        // 풀스크린 애니메이션 정지
        stopTitleScrolling()
        
        miniPlayer?.updateNowPlaying(
            song: musicList.playlist[currentIndex],
            image: UIImage(named: musicList.coverImageName ?? "japanese")
        )
        miniPlayer?.updatePlaybackState(isPlaying: AudioManager.shared.isPlaying)
        MiniPlayerState.shared.isMiniPlayerVisible = true
        miniPlayer?.show()
        
        // 델리게이트를 MainTabBarController로 다시 설정 & 현재 재생 정보 저장
        if let tabBarController = presentingViewController as? MainTabBarController {
            miniPlayer?.delegate = tabBarController
            tabBarController.setCurrentPlayingInfo(playlist: musicList, index: currentIndex)
        }
        
        dismiss(animated: true)
    }
    
    // MARK: - 연결: 미니플레이어 델리게이트/상태
    func setupMiniPlayerConnection() {
        if let tabBarController = presentingViewController as? MainTabBarController {
            miniPlayer = tabBarController.getMiniPlayerVC()
            tabBarController.getMiniPlayerVC().delegate = self
            // 현재 재생 정보 저장
            tabBarController.setCurrentPlayingInfo(playlist: musicList, index: currentIndex)
        }
    }
}

// MARK: - 미니플레이어 델리게이트 구현
extension PlayerViewController: MiniPlayerDelegate {
    func miniPlayerDidTap() {
        // 미니플레이어 탭 시 풀스크린으로 전환되는 로직은 상위 뷰컨트롤러에서 처리
        // 여기서는 단순히 알림만 전달
    }
    
    func miniPlayerPlayPauseDidTap() {
        playTapped()
    }
    
    func miniPlayerNextDidTap() {
        nextTapped()
    }
    
    func miniPlayerPreviousDidTap() {
        prevTapped()
    }
}
