//
//  MiniPlayerViewController.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/2/25.
//

import UIKit

// 미니플레이어 이벤트 처리를 위한 델리게이트 프로토콜
protocol MiniPlayerDelegate: AnyObject {
    // 미니플레이어 탭 이벤트 (전체화면으로 전환)
    func miniPlayerDidTap()
    // 재생/일시정지 버튼 탭 이벤트
    func miniPlayerPlayPauseDidTap()
    // 이전 곡 버튼 탭 이벤트
    func miniPlayerPreviousDidTap()
    // 다음 곡 버튼 탭 이벤트
    func miniPlayerNextDidTap()
}

class MiniPlayerViewController: UIViewController {
    
    // MARK: - 프로퍼티
    
    // 델리게이트 (PlayerViewController 또는 MainTabBarController)
    weak var delegate: MiniPlayerDelegate?
    
    // 현재 재생 중인 곡 정보
    internal var currentSong: Song?
    
    // 스크롤링 애니메이션 관련 프로퍼티
    internal var titleScrollTimer: Timer?
    internal var isScrollingTitle = false
    
    // 현재 재생 상태를 나타내는 변수
    internal var isPlaying: Bool = false
    
    // 재생 상태 업데이트 타이머
    internal var progressTimer: Timer?
    
    // MARK: - UI 컴포넌트
    // 미니플레이어 컨테이너 뷰
    internal let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        // 그림자 효과 추가
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true  // 사용자 상호작용 활성화
        return view
    }()
    
    // 앨범 커버 이미지
    internal let albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
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
    
    // 곡 제목 라벨
    internal let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()
    
    // 아티스트 라벨
    internal let artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 이전 곡 버튼
    internal let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    // 재생/일시정지 버튼
    internal let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true  // 사용자 상호작용 활성화
        return button
    }()
    
    // 다음 곡 버튼
    internal let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    // 재생 진행 바
    internal let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = .black
        progress.trackTintColor = .black.withAlphaComponent(0.3)
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()

    // MARK: - 라이프사이클 메소드
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        
        // 뷰 컨트롤러의 사용자 상호작용 활성화
        view.isUserInteractionEnabled = true
    }
    
    // MARK: - Deinit
    deinit {
        stopProgressTimer()
        stopTitleScrolling()
    }
}
