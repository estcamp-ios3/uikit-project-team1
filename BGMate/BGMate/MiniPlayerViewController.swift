//
//  MiniPlayerViewController.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/2/25.
//

import UIKit

protocol MiniPlayerDelegate: AnyObject {
    func miniPlayerDidTap()
    func miniPlayerPlayPauseDidTap()
    func miniPlayerDidSwipeLeft()
    func miniPlayerDidSwipeRight()
}

class MiniPlayerViewController: UIViewController {
    
    // MARK: - UI 구성요소
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray.withAlphaComponent(0.7)
        // 그림자 효과 추가
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true  // 사용자 상호작용 활성화
        return view
    }()
    
    private let albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true  // 사용자 상호작용 활성화
        return button
    }()
    
    // 재생 진행 바
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = .black
        progress.trackTintColor = .black.withAlphaComponent(0.3)
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    // MARK: - 프로퍼티
    weak var delegate: MiniPlayerDelegate?
    private var isPlaying: Bool = false
    private var currentSong: Song?
    private var progressTimer: Timer?
    
// 호출
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        
        // 뷰 컨트롤러의 사용자 상호작용 활성화
        view.isUserInteractionEnabled = true
    }
    
    // MARK: - UI 설정
    private func setupUI() {
        // 배경을 투명하게 설정
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        
        view.addSubview(containerView)
        containerView.addSubview(albumImageView)
        
        // 제목과 아티스트 레이블을 담을 스택뷰
        let labelStackView = UIStackView(arrangedSubviews: [titleLabel, artistLabel])
        labelStackView.axis = .vertical
        labelStackView.spacing = 2
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.isUserInteractionEnabled = true
        
        containerView.addSubview(labelStackView)
        containerView.addSubview(playPauseButton)
        containerView.addSubview(progressView)
        
        // 모든 뷰의 사용자 상호작용 활성화
        containerView.isUserInteractionEnabled = true
        albumImageView.isUserInteractionEnabled = true
        titleLabel.isUserInteractionEnabled = true
        artistLabel.isUserInteractionEnabled = true
        playPauseButton.isUserInteractionEnabled = true
        
        // 오토레이아웃 설정
        NSLayoutConstraint.activate([
            // 컨테이너 뷰
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 65),
            
            // 앨범 이미지
            albumImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            albumImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            albumImageView.widthAnchor.constraint(equalToConstant: 45),
            albumImageView.heightAnchor.constraint(equalToConstant: 45),
            
            // 레이블 스택뷰
            labelStackView.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 12),
            labelStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            labelStackView.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -12),
            
            // 재생/일시정지 버튼
            playPauseButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            playPauseButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 44),
            playPauseButton.heightAnchor.constraint(equalToConstant: 44),
            
            // 진행 바 (컨테이너 하단에 배치)
            progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
        
        // 버튼 액션 추가
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - 제스처 설정
    private func setupGestures() {
        // 전체 탭 제스처
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(miniPlayerTapped))
        containerView.addGestureRecognizer(tapGesture)
        
        // 좌우 스와이프 제스처
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        leftSwipe.direction = .left
        containerView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        rightSwipe.direction = .right
        containerView.addGestureRecognizer(rightSwipe)
        
        // 위로 스와이프 제스처 (풀스크린으로 전환)
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleUpSwipe))
        upSwipe.direction = .up
        containerView.addGestureRecognizer(upSwipe)
    }
    
    // MARK: - 동작 처리
    @objc private func miniPlayerTapped() {
        delegate?.miniPlayerDidTap()
    }
    
    @objc private func playPauseButtonTapped() {
        print("Play/Pause button tapped")  // 디버깅용 로그
        isPlaying.toggle()
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
        delegate?.miniPlayerPlayPauseDidTap()
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            delegate?.miniPlayerDidSwipeLeft()
        } else if gesture.direction == .right {
            delegate?.miniPlayerDidSwipeRight()
        }
    }
    
    @objc private func handleUpSwipe() {
        // 위로 스와이프하면 풀스크린으로 전환 (탭과 동일한 동작)
        delegate?.miniPlayerDidTap()
    }
    
    // MARK: - 공개 메서드
    func updatePlaybackState(isPlaying: Bool) {
        self.isPlaying = isPlaying
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        // 재생 상태에 따라 타이머 제어
        if isPlaying {
            startProgressTimer()
        } else {
            stopProgressTimer()
        }
    }
    
    func updateNowPlaying(song: Song, image: UIImage?) {
        self.currentSong = song
        titleLabel.text = song.title
        artistLabel.text = song.artist
        albumImageView.image = image
        
        // 새로운 곡으로 변경되면 진행 바 리셋
        progressView.setProgress(0.0, animated: false)
    }
    
    func show(animated: Bool = true) {
        guard animated else {
            view.alpha = 1.0
            if isPlaying {
                startProgressTimer()
            }
            return
        }
        
        view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 1.0
        } completion: { _ in
            if self.isPlaying {
                self.startProgressTimer()
            }
        }
    }
    
    func hide(animated: Bool = true) {
        stopProgressTimer()
        
        guard animated else {
            view.alpha = 0
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 0
        }
    }
    
    // MARK: - 진행 바 타이머 관리
    private func startProgressTimer() {
        stopProgressTimer()
        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    @objc private func updateProgress() {
        let currentTime = AudioManager.shared.playerCurrentTime
        let duration = AudioManager.shared.playerDuration
        
        guard duration > 0 else { return }
        
        let progress = Float(currentTime / duration)
        progressView.setProgress(progress, animated: true)
    }
    
    // MARK: - Deinit
    deinit {
        stopProgressTimer()
    }
}
#Preview {
    MiniPlayerViewController()
}
