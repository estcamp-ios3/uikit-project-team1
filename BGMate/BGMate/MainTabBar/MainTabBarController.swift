//
//  MainTabBarController.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/3/25.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - 프로퍼티
    
    // 미니플레이어 뷰 컨트롤러
    let miniPlayerVC = MiniPlayerViewController()
    
    // 현재 재생 중인 플레이리스트
    internal var currentPlaylist: Playlist?
    // 현재 재생 중인 곡 인덱스
    internal var currentSongIndex: Int = 0
    
    // MARK: - 재생 모드 관련 프로퍼티
    
    // 셔플 모드 활성화 상태
    internal var isShuffleOn: Bool = false
    // 반복 모드 활성화 상태
    internal var isRepeatOn: Bool = false
    // 셔플된 재생 순서 배열
    internal var shuffledIndices: [Int] = []
    // 재생 히스토리 배열
    internal var playHistory: [Int] = []
    // 원본 셔플 순서 배열
    internal var originalShuffledIndices: [Int] = []
    
    // MARK: - 라이프사이클 메소드
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 탭바 설정
        setupTabBar()
        
        // 미니플레이어 설정
        setupMiniPlayer()
        
        // 처음에는 미니플레이어 숨김
        miniPlayerVC.hide(animated: false)
    }
    
    // MARK: - 공개 메소드
    
    // 미니플레이어 뷰컨트롤러 반환
    func getMiniPlayerVC() -> MiniPlayerViewController {
        return miniPlayerVC
    }
    
    // 현재 재생 정보 저장
    func setCurrentPlayingInfo(playlist: Playlist, index: Int) {
        currentPlaylist = playlist
        currentSongIndex = index
    }
    
    // 현재 재생 정보 반환
    func getCurrentPlayingInfo() -> (playlist: Playlist?, index: Int) {
        return (currentPlaylist, currentSongIndex)
    }
}
