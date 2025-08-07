//
//  PlayerViewController.swift
//  BGMate
//
//  Created by Yesung Yoon on 7/30/25.
//

import UIKit
import CoreImage

// MARK: - UIImage 색상 추출 확장 (PlayerViewController용)
extension UIImage {
    func getDominantColorForPlayer() -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = 50
        let height = 50
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var pixelCount: CGFloat = 0
        
        for i in stride(from: 0, to: pixelData.count, by: bytesPerPixel) {
            let r = CGFloat(pixelData[i]) / 255.0
            let g = CGFloat(pixelData[i + 1]) / 255.0
            let b = CGFloat(pixelData[i + 2]) / 255.0
            let a = CGFloat(pixelData[i + 3]) / 255.0
            
            if a > 0.1 {
                red += r
                green += g
                blue += b
                pixelCount += 1
            }
        }
        
        guard pixelCount > 0 else { return UIColor.gray }
        
        red /= pixelCount
        green /= pixelCount
        blue /= pixelCount
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    func getVibrantColorForPlayer() -> UIColor? {
        guard let dominantColor = getDominantColorForPlayer() else { return nil }
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        dominantColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // PlayerViewController용으로 좀 더 어둡게 조정 (가독성을 위해)
        let adjustedSaturation = min(saturation * 1.2, 1.0)
        let adjustedBrightness = max(min(brightness * 0.6, 0.7), 0.2)
        
        return UIColor(hue: hue, saturation: adjustedSaturation, brightness: adjustedBrightness, alpha: alpha)
    }
}

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
    
    // 텍스트 스크롤링 애니메이션 관련
    private var titleScrollTimer: Timer?
    private var isScrollingTitle = false
    
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
        label.text = "" // 실제 플레이리스트 제목으로 동적으로 설정
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

    // 제목을 위한 스크롤 가능한 컨테이너
    private let titleScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = false  // 수동 스크롤 비활성화
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    // 곡명
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "answer"
        label.font = .boldSystemFont(ofSize: 28)
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
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
        self.modalPresentationStyle = .overFullScreen
        super.viewDidLoad()
        view.backgroundColor = .gray
        setupDismissGesture()
        setupUI()
        setupActions()
        setupNotifications()
        
        // 플레이리스트 정보 업데이트
        updatePlaylistInfo()
        
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
    
    // MARK: - 플레이리스트 정보 업데이트
    private func updatePlaylistInfo() {
        guard musicList != nil else { return }
        
        // 플레이리스트 제목 설정
        playlistLabel.text = musicList.title
        
        // 플레이리스트 커버 이미지 설정
        if musicList.coverImageName != nil {
            albumImageView.image = generateQRCode(from: "https://youtu.be/N8VHBJooRwg?si=V64ncPh5-7NRZHaT")
        } else {
            // 기본 이미지 설정 (필요시)
            albumImageView.image = UIImage(named: "japanese")
        }
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
                
//                // 스와이프 진행도에 따라 배경 투명도 조절 (뒷배경 보이기 효과)
//                let progress = min(draggedDistance / dismissThreshold, 1.0)
//                let alpha = 1.0 - (progress * 0.3) // 최대 30%까지 투명해짐
//                view.backgroundColor = view.backgroundColor?.withAlphaComponent(alpha)
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
        
        // 제목 스크롤뷰 설정
        titleScrollView.addSubview(titleLabel)
        view.addSubview(titleScrollView)
        
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
            
            // 제목 스크롤뷰
            titleScrollView.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 36),
            titleScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            titleScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            titleScrollView.heightAnchor.constraint(equalToConstant: 35),
            
            // 제목 레이블 (스크롤뷰 내부)
            titleLabel.leadingAnchor.constraint(equalTo: titleScrollView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleScrollView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleScrollView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleScrollView.bottomAnchor),
            titleLabel.heightAnchor.constraint(equalTo: titleScrollView.heightAnchor),
            
            // 아티스트
            artistLabel.topAnchor.constraint(equalTo: titleScrollView.bottomAnchor, constant: 4),
            artistLabel.leadingAnchor.constraint(equalTo: titleScrollView.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: titleScrollView.trailingAnchor),
            
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
        stopTitleScrolling()
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
        
        // 앨범 이미지에서 색상 추출해서 배경색 변경
        updatePlayerBackgroundColor(from: albumImageView.image)
        
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
    
    // UI만 업데이트 (재생은 유지)
    private func updateUIForCurrentIndex() {
        guard !musicList.playlist.isEmpty, currentIndex >= 0, currentIndex < musicList.playlist.count else { return }
        
        // UI 업데이트만 수행
        titleLabel.text = musicList.playlist[currentIndex].title
        artistLabel.text = musicList.playlist[currentIndex].artist
        
        // 앨범 이미지에서 색상 추출해서 배경색 변경 (UI만 업데이트할 때도)
        updatePlayerBackgroundColor(from: albumImageView.image)
        
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
    
    // MARK: - 텍스트 스크롤링 애니메이션
    private func startTitleScrollingIfNeeded() {
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
    
    private func performTitleScrollAnimation() {
        guard isScrollingTitle else { return }
        
        let labelWidth = titleLabel.frame.width
        let scrollViewWidth = titleScrollView.frame.width
        let scrollDistance = labelWidth - scrollViewWidth
        
        // 오른쪽 끝까지 스크롤
        UIView.animate(withDuration: 3.0, delay: 0, options: [.curveLinear], animations: {
            self.titleScrollView.contentOffset = CGPoint(x: scrollDistance + 20, y: 0) // 여백 추가
        }) { [weak self] _ in
            // 1초 대기 후 처음으로 돌아가기
            self?.titleScrollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                UIView.animate(withDuration: 2.0, delay: 0, options: [.curveLinear], animations: {
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
    
    private func stopTitleScrolling() {
        isScrollingTitle = false
        titleScrollTimer?.invalidate()
        titleScrollTimer = nil
        titleScrollView.layer.removeAllAnimations()
    }
    
    // MARK: - 배경색 업데이트 (PlayerViewController용)
    private func updatePlayerBackgroundColor(from image: UIImage?) {
        guard let image = image else {
            // 이미지가 없으면 기본 색상으로 설정
            animatePlayerBackgroundColor(to: .systemGray)
            return
        }
        
        // 백그라운드 큐에서 색상 추출 (메인 스레드 블로킹 방지)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let extractedColor = image.getVibrantColorForPlayer() ?? image.getDominantColorForPlayer() ?? .systemGray
            
            // 메인 스레드에서 UI 업데이트
            DispatchQueue.main.async {
                self?.animatePlayerBackgroundColor(to: extractedColor)
            }
        }
    }
    
    private func animatePlayerBackgroundColor(to color: UIColor) {
        UIView.animate(withDuration: 0.6, delay: 0, options: [.curveEaseInOut], animations: {
            self.view.backgroundColor = color
        })
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("Q", forKey: "inputCorrectionLevel")

            if let outputImage = filter.outputImage {
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let scaledImage = outputImage.transformed(by: transform)
                return UIImage(ciImage: scaledImage)
            }
        }

        return nil
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



