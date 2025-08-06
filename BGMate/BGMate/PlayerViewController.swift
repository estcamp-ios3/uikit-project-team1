//
//  PlayerViewController.swift
//  BGMate
//
//  Created by Yesung Yoon on 7/30/25.
//

import UIKit

class PlayerViewController: UIViewController {
    
    // 외부에서 받을 음악 리스트와 현재 인덱스
    var musicList: Playlist!
    var currentIndex: Int = 0
    var shouldRestartPlayback: Bool = true  // 재생을 다시 시작할지 여부
    
    // MARK: - 미니플레이어 관련 프로퍼티
    weak var miniPlayer: MiniPlayerViewController?
    private var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)
    private let dismissThreshold: CGFloat = 200
    
    // 셔플, 반복 상태
    private var isShuffleOn: Bool = false
    private var isRepeatOn: Bool = false
    
    // 셔플된 재생 순서를 저장할 배열
    private var shuffledIndices: [Int] = []
    
    // 재생 히스토리를 저장할 배열
    private var playHistory: [Int] = []
    
    // 상단 드롭다운 화살표 (닫기용)
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("⌄", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // 플레이리스트/상단 제목
    private let playlistLabel: UILabel = {
        let label = UILabel()
        label.text = //"Chill Lofi Music ~ lofi hip hop mix"
        "오후 일식"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 앨범커버 이미지
    private let albumImageView: UIImageView = {
        let imageView = UIImageView()
        // 예시 이미지, 실제는 네트워크 또는 Assets에서 교체
        imageView.image = UIImage(named: "sample") ?? UIImage(systemName: "sample")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // 곡명
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "answer"
        label.font = .boldSystemFont(ofSize: 28)
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 아티스트
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.8)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 재생 슬라이더
    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.15
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = .white.withAlphaComponent(0.3)
        slider.thumbTintColor = .white
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    // 현재시간/총시간 라벨
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "0:26"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "-2:51"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white.withAlphaComponent(0.8)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 컨트롤 버튼 (이전/재생/다음)
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 35
        button.clipsToBounds = true
        return button
    }()
    private let prevButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let shuffleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "shuffle"), for: .normal)
        button.tintColor = .white.withAlphaComponent(0.2)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let repeatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "repeat"), for: .normal)
        button.tintColor = .white.withAlphaComponent(0.2)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 타이머로 재생 위치 갱신
    private var playbackTimer: Timer?
    
    override func viewDidLoad() {
        self.modalPresentationStyle = .fullScreen
        super.viewDidLoad()
        view.backgroundColor = .gray
        setupDismissGesture()
        setupUI()
        setupActions()
        setupNotifications()
        
        // musicList와 currentIndex가 세팅되어 있으면 해당 곡 재생 (shouldRestartPlayback 확인)
        if !musicList.playlist.isEmpty && currentIndex < musicList.playlist.count {
            if shouldRestartPlayback {
                updatePlayerForCurrentIndex()
            } else {
                updateUIForCurrentIndex()  // UI만 업데이트하고 재생은 유지
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 미니플레이어 연결 설정 (한번만 실행)
        if miniPlayer == nil {
            setupMiniPlayerConnection()
        }
        
        // 미니플레이어에서 풀스크린으로 전환 시 상태 동기화
        if !shouldRestartPlayback {
            syncFromMainTabBarController()
        }
    }
    
    private func setupNotifications() {
        // 재생 완료 알림
        NotificationCenter.default.addObserver(self,
        selector: #selector(handlePlaybackFinished),
        name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    // MARK: - 제스처 관련 메서드
    private func setupDismissGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPan(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc private func handleDismissPan(_ gesture: UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: view.window)
        
        switch gesture.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed:
            if touchPoint.y - initialTouchPoint.y > 0 {
                let draggedDistance = touchPoint.y - initialTouchPoint.y
                view.frame.origin.y = draggedDistance
                
                // 스와이프 진행도에 따라 배경 투명도 조절 (뒷배경 보이기 효과)
                let progress = min(draggedDistance / dismissThreshold, 1.0)
                let alpha = 1.0 - (progress * 0.3) // 최대 30%까지 투명해짐
                view.backgroundColor = view.backgroundColor?.withAlphaComponent(alpha)
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
    
    // MARK: - 미니플레이어 관련 메서드
    private func minimizeToMiniPlayer() {
        miniPlayer?.updateNowPlaying(
            song: musicList.playlist[currentIndex],
            image: albumImageView.image
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
    
    @objc private func handlePlaybackFinished() {
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
    
    private func setupUI() {
        // 상단 dismiss
        view.addSubview(dismissButton)
        view.addSubview(playlistLabel)
        view.addSubview(albumImageView)
        view.addSubview(titleLabel)
        view.addSubview(artistLabel)
        view.addSubview(progressSlider)
        view.addSubview(currentTimeLabel)
        view.addSubview(durationLabel)
        
        // 하단 컨트롤 스택
        let controlStack = UIStackView(arrangedSubviews: [shuffleButton, prevButton, playButton, nextButton, repeatButton])
        controlStack.axis = .horizontal
        controlStack.spacing = 24
        controlStack.alignment = .center
        controlStack.distribution = .equalCentering
        controlStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlStack)
        
        // 오토레이아웃
        NSLayoutConstraint.activate([
            // 상단 닫기 버튼
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dismissButton.heightAnchor.constraint(equalToConstant: 40),
            dismissButton.widthAnchor.constraint(equalToConstant: 40),
            
            // 플레이리스트명
            playlistLabel.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor),
            playlistLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playlistLabel.leadingAnchor.constraint(greaterThanOrEqualTo: dismissButton.trailingAnchor, constant: 8),
            playlistLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // 앨범 커버
            albumImageView.topAnchor.constraint(equalTo: playlistLabel.bottomAnchor, constant: 28),
            albumImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            albumImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            albumImageView.heightAnchor.constraint(equalTo: albumImageView.widthAnchor),
            
            // 곡명
            titleLabel.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 36),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            
            // 아티스트
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // 슬라이더
            progressSlider.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 36),
            progressSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            progressSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            
            // 시간 라벨
            currentTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 2),
            currentTimeLabel.leadingAnchor.constraint(equalTo: progressSlider.leadingAnchor),
            durationLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 2),
            durationLabel.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor),
            
            // 컨트롤 버튼
            controlStack.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 36),
            controlStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlStack.heightAnchor.constraint(equalToConstant: 70),
        ])
        
        // 메인 Play버튼 크기 키우기
        playButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    private func setupActions() {
        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        shuffleButton.addTarget(self, action: #selector(shuffleTapped), for: .touchUpInside)
        repeatButton.addTarget(self, action: #selector(repeatTapped), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    
    // 셔플 순서 생성 (첫 곡 제외)
    // 원본 셔플 순서를 저장할 배열 추가
    private var originalShuffledIndices: [Int] = []
    
    private func createShuffledIndices() {
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
        
    @objc private func dismissTapped() {
        stopPlaybackTimer()
        minimizeToMiniPlayer()
    }
    // 플레이 중 이면 pause 버튼 형태로 보여주고, 반대로 pause 상태면 play버튼으로 보여줌
    @objc private func playTapped() {
        if AudioManager.shared.isPlaying {
            AudioManager.shared.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            AudioManager.shared.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    // shuffle, repeat 실행전 투명도 0.4, 실행시 full white color
    @objc private func shuffleTapped() {
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
    @objc private func repeatTapped() {
        isRepeatOn.toggle()
        UIView.animate(withDuration: 0.4) {
            self.repeatButton.tintColor = self.isRepeatOn ? .white : .white.withAlphaComponent(0.4)
        }
        
        // MainTabBarController와 상태 동기화
        syncWithMainTabBarController()
    }
    
    // 곡 재생 및 UI 갱신 함수
    private func updatePlayerForCurrentIndex() {
        guard !musicList.playlist.isEmpty, currentIndex >= 0, currentIndex < musicList.playlist.count else { return }
        
        // 현재 곡을 히스토리에 추가
        if playHistory.last != currentIndex {
            playHistory.append(currentIndex)
        }
        
        let fileName = musicList.playlist[currentIndex].fileName
        AudioManager.shared.prepareAudio(named: fileName, fileExtension: "mp3")
        AudioManager.shared.play()
        
        // 재생 버튼 이미지 업데이트 (재생 중이므로 pause 이미지로)
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        
        // UI 업데이트
        titleLabel.text = musicList.playlist[currentIndex].title
        artistLabel.text = musicList.playlist[currentIndex].artist
        
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
    
    // UI만 업데이트 (재생은 유지)
    private func updateUIForCurrentIndex() {
        guard !musicList.playlist.isEmpty, currentIndex >= 0, currentIndex < musicList.playlist.count else { return }
        
        // UI 업데이트만 수행
        titleLabel.text = musicList.playlist[currentIndex].title
        artistLabel.text = musicList.playlist[currentIndex].artist
        
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
    
    // MainTabBarController와 셔플/반복 상태 동기화
    private func syncWithMainTabBarController() {
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
    
    // MainTabBarController로부터 상태 가져와서 UI 업데이트
    private func syncFromMainTabBarController() {
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
    
    // 셔플/반복 버튼 UI 업데이트
    private func updateShuffleRepeatButtonsUI() {
        UIView.animate(withDuration: 0.2) {
            self.shuffleButton.tintColor = self.isShuffleOn ? .white : .white.withAlphaComponent(0.4)
            self.repeatButton.tintColor = self.isRepeatOn ? .white : .white.withAlphaComponent(0.4)
        }
    }
    
    @objc private func prevTapped() {
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
    
    // 다음 곡 인덱스 계산
    private func getNextIndex() -> Int? {
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
    
    private func getPrevIndex() -> Int? {
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
    
    @objc private func nextTapped() {
        if let nextIndex = getNextIndex() {
            if isShuffleOn {
                shuffledIndices.removeFirst()  // 다음 곡으로 이동할 때만 셔플 배열에서 제거
            }
            currentIndex = nextIndex
            updatePlayerForCurrentIndex()
        }
    }
    
    // 타이머 시작/정지 및 슬라이더/라벨 갱신
    private func startPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(updatePlaybackUI), userInfo: nil, repeats: true)
    }
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    @objc private func updatePlaybackUI() {
        let current = AudioManager.shared.playerCurrentTime
        let duration = AudioManager.shared.playerDuration
        progressSlider.maximumValue = Float(duration)
        progressSlider.value = Float(current)
        currentTimeLabel.text = formatTime(current)
        durationLabel.text = "-" + formatTime(duration - current)
    }
    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    @objc private func sliderValueChanged(_ sender: UISlider) {
        AudioManager.shared.seekTo(time: TimeInterval(sender.value))
        updatePlaybackUI()
    }
}

// MARK: - 미니플레이어 델리게이트
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
    // MARK: - 미니플레이어 연결 설정
    private func setupMiniPlayerConnection() {
        if let tabBarController = presentingViewController as? MainTabBarController {
            miniPlayer = tabBarController.getMiniPlayerVC()
            tabBarController.getMiniPlayerVC().delegate = self
            // 현재 재생 정보 저장
            tabBarController.setCurrentPlayingInfo(playlist: musicList, index: currentIndex)
        }
    }
}



