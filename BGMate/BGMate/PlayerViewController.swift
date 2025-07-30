//
//  PlayerViewController.swift
//  BGMate
//
//  Created by Yesung Yoon on 7/30/25.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController, AVAudioPlayerDelegate {
    
    // 외부에서 받을 음악 리스트와 현재 인덱스
    var musicList: [(fileName: String, displayName: String, artist: String)] = []
    var currentIndex: Int = 0
    
    // 타이머로 재생 위치 갱신
    private var playbackTimer: Timer?

    // MARK: - UI Components
    
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
        label.text = "Chill Lofi Music ~ lofi hip hop mix"
        label.font = .systemFont(ofSize: 14, weight: .medium)
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
        label.text = "DLJ"
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
        button.tintColor = .white.withAlphaComponent(0.7)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let repeatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "repeat"), for: .normal)
        button.tintColor = .white.withAlphaComponent(0.7)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        self.modalPresentationStyle = .fullScreen
        if !musicList.isEmpty && currentIndex < musicList.count {
            let fileName = musicList[currentIndex].fileName
            AudioManager.shared.prepareAudio(named: fileName, fileExtension: "mp3")
            AudioManager.shared.play()
            titleLabel.text = musicList[currentIndex].displayName
            artistLabel.text = musicList[currentIndex].artist
        }
        super.viewDidLoad()
        view.backgroundColor = .gray
        setupUI()
        setupActions()
        startPlaybackTimer()
    }
    
    // MARK: - UI Setup
    
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
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    // 곡 재생 및 UI 갱신 함수
    private func updatePlayerForCurrentIndex() {
        guard !musicList.isEmpty, currentIndex >= 0, currentIndex < musicList.count else { return }
        let fileName = musicList[currentIndex].fileName
        AudioManager.shared.prepareAudio(named: fileName, fileExtension: "mp3", delegate: self)
        AudioManager.shared.play()
        titleLabel.text = musicList[currentIndex].displayName
        artistLabel.text = musicList[currentIndex].artist
        startPlaybackTimer()
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
    
    @objc private func dismissTapped() {
        stopPlaybackTimer()
        self.dismiss(animated: true, completion: nil)
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
    @objc private func prevTapped() {
        let currentTime = AudioManager.shared.playerCurrentTime
        if currentTime > 1.0 {
            AudioManager.shared.seekTo(time: 0)
        } else if currentIndex > 0 {
            currentIndex -= 1
            updatePlayerForCurrentIndex()
        }
    }
    @objc private func nextTapped() {
        if currentIndex < musicList.count - 1 {
            currentIndex += 1
            updatePlayerForCurrentIndex()
        }
    }

    // AVAudioPlayerDelegate: 곡이 끝나면 다음 곡으로 자동 이동
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if currentIndex < musicList.count - 1 {
            currentIndex += 1
            updatePlayerForCurrentIndex()
        }
    }
}
#Preview {
    PlayerViewController()
}


