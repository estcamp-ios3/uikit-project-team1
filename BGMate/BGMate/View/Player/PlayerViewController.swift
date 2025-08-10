//
//  PlayerViewController.swift
//  BGMate
//
//  Created by Yesung Yoon on 7/30/25.
//

import UIKit
import CoreImage

class PlayerViewController: UIViewController {
    
    // MARK: - 프로퍼티
    
    // 외부에서 받을 음악 리스트와 현재 인덱스
    var musicList: Playlist!
    var currentIndex: Int = 0
    // 재생을 다시 시작할지 여부 (미니플레이어에서 전환 시 false)
    var shouldRestartPlayback: Bool = true
    
    // MARK: - 미니플레이어 관련 프로퍼티
    weak var miniPlayer: MiniPlayerViewController?
    internal var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)
    internal let dismissThreshold: CGFloat = 200
    
    // MARK: - 재생 모드 관련 프로퍼티
    // 셔플 모드 활성화 상태
    internal var isShuffleOn: Bool = false
    // 반복 모드 활성화 상태
    internal var isRepeatOn: Bool = false
    
    // 셔플된 재생 순서를 저장할 배열
    internal var shuffledIndices: [Int] = []
    // 원본 셔플 순서를 저장할 배열
    internal var originalShuffledIndices: [Int] = []
    // 재생 히스토리를 저장할 배열
    internal var playHistory: [Int] = []
    
    // MARK: - 텍스트 스크롤링 관련 프로퍼티
    // 타이틀 스크롤링 타이머
    internal var titleScrollTimer: Timer?
    // 스크롤링 진행 중 여부
    internal var isScrollingTitle = false
    
    // MARK: - 재생 관련 프로퍼티
    // 재생 진행 상태 업데이트 타이머
    internal var playbackTimer: Timer?
    
    // MARK: - UI 컴포넌트
    
    // 상단 드롭다운 화살표 (닫기용)
    internal let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("⌄", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // 플레이리스트/상단 제목
    internal let playlistLabel: UILabel = {
        let label = UILabel()
        label.text = "" // 실제 플레이리스트 제목으로 동적으로 설정
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 앨범커버 이미지 (QR 코드)
    internal let albumImageView: UIImageView = {
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
    internal let titleScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = false  // 수동 스크롤 비활성화
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    // 곡명
    internal let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "answer"
        label.font = .boldSystemFont(ofSize: 28)
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()

    // 아티스트
    internal let artistLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 재생 슬라이더
    internal let progressSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.15
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = .white.withAlphaComponent(0.3)
        slider.thumbTintColor = .white
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    // 현재시간 라벨
    internal let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "0:26"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // 총시간 라벨
    internal let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "-2:51"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white.withAlphaComponent(0.8)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 재생/일시정지 버튼
    internal let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 35
        button.clipsToBounds = true
        return button
    }()
    // 이전 곡 버튼
    internal let prevButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // 다음 곡 버튼
    internal let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // 셔플 모드 버튼
    internal let shuffleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "shuffle"), for: .normal)
        button.tintColor = .white.withAlphaComponent(0.2)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // 반복 모드 버튼
    internal let repeatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "repeat"), for: .normal)
        button.tintColor = .white.withAlphaComponent(0.2)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - 배경 관련 컴포넌트
    
    // 배경 이미지 뷰 (플레이리스트 커버 이미지)
    internal let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.alpha = 0.7
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // 블러 효과 뷰
    internal let blurEffectView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)
        let bv = UIVisualEffectView(effect: blur)
        bv.translatesAutoresizingMaskIntoConstraints = false
        return bv
    }()
    
    // MARK: - 라이프사이클 메소드
    
    override func viewDidLoad() {
        self.modalPresentationStyle = .overFullScreen
        super.viewDidLoad()
        view.backgroundColor = .white
        setupDismissGesture()
        setupUI()
        setupActions()
        setupNotifications()
        
        // 플레이리스트 정보 업데이트
        updatePlaylistInfo()
        updateBackgroundImage() // optional
        
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
}
