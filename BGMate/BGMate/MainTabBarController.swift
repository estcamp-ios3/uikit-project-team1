//
//  MainTabBarController.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/3/25.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - 프로퍼티
    
    /// 미니플레이어 뷰 컨트롤러
    let miniPlayerVC = MiniPlayerViewController()
    
    /// 현재 재생 중인 플레이리스트
    private var currentPlaylist: Playlist?
    /// 현재 재생 중인 곡 인덱스
    private var currentSongIndex: Int = 0
    
    // MARK: - 재생 모드 관련 프로퍼티
    
    /// 셔플 모드 활성화 상태
    private var isShuffleOn: Bool = false
    /// 반복 모드 활성화 상태
    private var isRepeatOn: Bool = false
    /// 셔플된 재생 순서 배열
    private var shuffledIndices: [Int] = []
    /// 재생 히스토리 배열
    private var playHistory: [Int] = []
    /// 원본 셔플 순서 배열
    private var originalShuffledIndices: [Int] = []
    
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
    
    // MARK: - 초기 설정 메소드
    
    /// 탭바 설정
    private func setupTabBar() {
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        homeVC.tabBarItem = UITabBarItem(title: "BGMate", image: UIImage(systemName: "house"), tag: 0)
        
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        searchVC.tabBarItem = UITabBarItem(title: "LIBRARY", image: UIImage(systemName: "square.stack"), tag: 1)
        
        self.viewControllers = [homeVC, searchVC]
    }
    
    /// 미니플레이어 설정
    private func setupMiniPlayer() {
        // 미니플레이어 뷰 추가 (child로 추가하지 않음)
        view.addSubview(miniPlayerVC.view)
        
        // 미니플레이어 델리게이트 설정
        miniPlayerVC.delegate = self
        
        // 오토레이아웃 제약 (항상 탭바 위에!)
        miniPlayerVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            miniPlayerVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            miniPlayerVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            miniPlayerVC.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            miniPlayerVC.view.heightAnchor.constraint(equalToConstant: 65)
        ])
    }
    
    // MARK: - 공개 메소드
    
    /// 미니플레이어 뷰컨트롤러 반환
    func getMiniPlayerVC() -> MiniPlayerViewController {
        return miniPlayerVC
    }
    
    /// 현재 재생 정보 저장
    func setCurrentPlayingInfo(playlist: Playlist, index: Int) {
        currentPlaylist = playlist
        currentSongIndex = index
    }
    
    /// 현재 재생 정보 반환
    func getCurrentPlayingInfo() -> (playlist: Playlist?, index: Int) {
        return (currentPlaylist, currentSongIndex)
    }
    
    // MARK: - 재생 모드 관련 메소드
    
    /// 재생 모드 상태 동기화 (PlayerViewController에서 호출)
    func syncPlaybackState(isShuffleOn: Bool, isRepeatOn: Bool, shuffledIndices: [Int], playHistory: [Int], originalShuffledIndices: [Int]) {
        self.isShuffleOn = isShuffleOn
        self.isRepeatOn = isRepeatOn
        self.shuffledIndices = shuffledIndices
        self.playHistory = playHistory
        self.originalShuffledIndices = originalShuffledIndices
        
        print("재생 상태 동기화: 셔플=\(isShuffleOn), 반복=\(isRepeatOn)")
    }
    
    /// 현재 재생 모드 상태 반환
    func getCurrentPlaybackState() -> (isShuffleOn: Bool, isRepeatOn: Bool, shuffledIndices: [Int], playHistory: [Int], originalShuffledIndices: [Int]) {
        return (isShuffleOn, isRepeatOn, shuffledIndices, playHistory, originalShuffledIndices)
    }
}

// MARK: - MiniPlayerDelegate 구현
extension MainTabBarController: MiniPlayerDelegate {
    /// 미니플레이어 탭 처리 - 풀스크린 플레이어로 전환
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
    
    /// 재생/일시정지 버튼 탭 처리
    func miniPlayerPlayPauseDidTap() {
        // AudioManager를 통해 재생/일시정지
        if AudioManager.shared.isPlaying {
            AudioManager.shared.pause()
        } else {
            AudioManager.shared.play()
        }
        miniPlayerVC.updatePlaybackState(isPlaying: AudioManager.shared.isPlaying)
    }
    
    /// 다음 곡 버튼 탭 처리
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
    
    /// 이전 곡 버튼 탭 처리
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
    
    // MARK: - 재생 관련 메소드
    
    /// 현재 선택된 곡 재생
    private func playCurrentSong() {
        guard let playlist = currentPlaylist,
              currentSongIndex >= 0,
              currentSongIndex < playlist.playlist.count else { return }
        
        // 현재 곡을 히스토리에 추가 (PlayerViewController와 동일)
        if playHistory.last != currentSongIndex {
            playHistory.append(currentSongIndex)
        }
        
        let currentSong = playlist.playlist[currentSongIndex]
        AudioManager.shared.prepareAudio(named: currentSong.fileName, fileExtension: "mp3")
        AudioManager.shared.play()
        
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
    
    // MARK: - 셔플/반복 로직 (PlayerViewController와 동일)
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
