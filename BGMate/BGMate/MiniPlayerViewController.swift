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
    func miniPlayerPreviousDidTap()
    func miniPlayerNextDidTap()
}

class MiniPlayerViewController: UIViewController {
    
    // MARK: - UI 구성요소
    private let containerView: UIView = {
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
    
    private let albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true  // 사용자 상호작용 활성화
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
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
    
    // 텍스트 스크롤링 애니메이션 관련
    private var titleScrollTimer: Timer?
    private var isScrollingTitle = false
    
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
        
        // 제목 스크롤뷰 설정
        titleScrollView.addSubview(titleLabel)
        
        // 제목 스크롤뷰와 아티스트 레이블을 담을 스택뷰
        let labelStackView = UIStackView(arrangedSubviews: [titleScrollView, artistLabel])
        labelStackView.axis = .vertical
        labelStackView.spacing = 2
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.isUserInteractionEnabled = true
        
        // 버튼들을 담을 스택뷰 생성
        let buttonStackView = UIStackView(arrangedSubviews: [previousButton, playPauseButton, nextButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 8
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.isUserInteractionEnabled = true
        
        containerView.addSubview(labelStackView)
        containerView.addSubview(buttonStackView)
        containerView.addSubview(progressView)
        
        // 모든 뷰의 사용자 상호작용 활성화
        containerView.isUserInteractionEnabled = true
        albumImageView.isUserInteractionEnabled = true
        titleLabel.isUserInteractionEnabled = true
        artistLabel.isUserInteractionEnabled = true
        previousButton.isUserInteractionEnabled = true
        playPauseButton.isUserInteractionEnabled = true
        nextButton.isUserInteractionEnabled = true
        
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
            labelStackView.trailingAnchor.constraint(equalTo: buttonStackView.leadingAnchor, constant: -12),
            
            // 버튼 스택뷰
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            buttonStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // 각 버튼 크기 설정
            previousButton.widthAnchor.constraint(equalToConstant: 36),
            previousButton.heightAnchor.constraint(equalToConstant: 36),
            playPauseButton.widthAnchor.constraint(equalToConstant: 40),
            playPauseButton.heightAnchor.constraint(equalToConstant: 40),
            nextButton.widthAnchor.constraint(equalToConstant: 36),
            nextButton.heightAnchor.constraint(equalToConstant: 36),
            
            // 진행 바 (컨테이너 하단에 배치)
            progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2),
            
            // 제목 스크롤뷰 제약조건
            titleScrollView.heightAnchor.constraint(equalToConstant: 20),
            
            // 제목 레이블 제약조건 (스크롤뷰 내부)
            titleLabel.leadingAnchor.constraint(equalTo: titleScrollView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleScrollView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleScrollView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleScrollView.bottomAnchor),
            titleLabel.heightAnchor.constraint(equalTo: titleScrollView.heightAnchor)
        ])
        
        // 버튼 액션 추가
        previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
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
    
    @objc private func previousButtonTapped() {
        print("Previous button tapped")  // 디버깅용 로그
        delegate?.miniPlayerPreviousDidTap()
    }
    
    @objc private func playPauseButtonTapped() {
        print("Play/Pause button tapped")  // 디버깅용 로그
        isPlaying.toggle()
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
        delegate?.miniPlayerPlayPauseDidTap()
    }
    
    @objc private func nextButtonTapped() {
        print("Next button tapped")  // 디버깅용 로그
        delegate?.miniPlayerNextDidTap()
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            print("Left swipe detected")  // 디버깅용 로그
            delegate?.miniPlayerNextDidTap()
        } else if gesture.direction == .right {
            print("Right swipe detected")  // 디버깅용 로그
            delegate?.miniPlayerPreviousDidTap()
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
        
        // 앨범 이미지에서 색상 추출해서 배경색 변경
        updateBackgroundColor(from: image)
        
        // 레이아웃이 완료된 후 스크롤링 애니메이션 시작
        DispatchQueue.main.async { [weak self] in
            self?.startTitleScrollingIfNeeded()
        }
    }
    
    // MARK: - 배경색 업데이트
    private func updateBackgroundColor(from image: UIImage?) {
        guard let image = image else {
            // 이미지가 없으면 기본 색상으로 설정
            animateBackgroundColor(to: .systemGray)
            return
        }
        
        // 백그라운드 큐에서 색상 추출 (메인 스레드 블로킹 방지)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let extractedColor = image.getSafeColorForMiniPlayer()
            
            // 메인 스레드에서 UI 업데이트
            DispatchQueue.main.async {
                self?.animateBackgroundColor(to: extractedColor)
            }
        }
    }
    
    private func animateBackgroundColor(to color: UIColor) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            self.containerView.backgroundColor = color
        })
    }
    
    func show(animated: Bool = true) {
        guard animated else {
            view.alpha = 1.0
            if isPlaying {
                startProgressTimer()
            }
            // 레이아웃이 완료된 후 스크롤링 시작
            DispatchQueue.main.async { [weak self] in
                self?.startTitleScrollingIfNeeded()
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
            // 레이아웃이 완료된 후 스크롤링 시작
            DispatchQueue.main.async { [weak self] in
                self?.startTitleScrollingIfNeeded()
            }
        }
    }
    
    func hide(animated: Bool = true) {
        stopProgressTimer()
        stopTitleScrolling()  // 미니플레이어가 숨겨질 때 스크롤링 정지
        
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
        let scrollDistance = labelWidth - scrollViewWidth + 20 // 여백 추가
        
        // 일정한 속도 계산 (픽셀/초)
        let scrollSpeed: CGFloat = 60.0 // 60 픽셀/초로 고정 (적당한 속도)
        let scrollDuration = TimeInterval(scrollDistance / scrollSpeed)
        let returnDuration = TimeInterval(scrollDistance / (scrollSpeed * 1.2)) // 복귀는 조금 더 빠르게
        
        // 최소/최대 시간 제한 (너무 빠르거나 느리지 않게)
        let minDuration: TimeInterval = 1.0
        let maxDuration: TimeInterval = 8.0
        let finalScrollDuration = max(minDuration, min(maxDuration, scrollDuration))
        let finalReturnDuration = max(minDuration, min(maxDuration, returnDuration))
        
        // 오른쪽 끝까지 스크롤 (계산된 시간)
        UIView.animate(withDuration: finalScrollDuration, delay: 0, options: [.curveLinear], animations: {
            self.titleScrollView.contentOffset = CGPoint(x: scrollDistance, y: 0)
        }) { [weak self] _ in
            // 1초 대기 후 처음으로 돌아가기
            self?.titleScrollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                UIView.animate(withDuration: finalReturnDuration, delay: 0, options: [.curveLinear], animations: {
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
    
    // MARK: - Deinit
    deinit {
        stopProgressTimer()
        stopTitleScrolling()
    }
}

// MARK: - UIImage 색상 추출 확장
extension UIImage {
    func getDominantColor() -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = 50  // 성능을 위해 작은 크기로 리사이즈
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
        
        // 픽셀 데이터를 순회하면서 평균 색상 계산
        for i in stride(from: 0, to: pixelData.count, by: bytesPerPixel) {
            let r = CGFloat(pixelData[i]) / 255.0
            let g = CGFloat(pixelData[i + 1]) / 255.0
            let b = CGFloat(pixelData[i + 2]) / 255.0
            let a = CGFloat(pixelData[i + 3]) / 255.0
            
            // 투명하지 않은 픽셀만 계산
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
    
    func getVibrantColor() -> UIColor? {
        guard let dominantColor = getDominantColor() else { return nil }
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        dominantColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // 미니플레이어용: 텍스트 가독성을 위해 더 밝고 연하게 조정
        let adjustedSaturation = min(saturation * 0.7, 0.8)  // 채도 줄임 (더 연하게)
        let adjustedBrightness = max(brightness * 1.4, 0.65)  // 밝기 증가 (더 밝게)
        
        // 최대 밝기 제한 (너무 밝아지지 않도록)
        let finalBrightness = min(adjustedBrightness, 0.85)
        
        return UIColor(hue: hue, saturation: adjustedSaturation, brightness: finalBrightness, alpha: alpha)
    }
    
    // 텍스트 가독성을 위한 안전한 색상 추출
    func getSafeColorForMiniPlayer() -> UIColor {
        // 먼저 생동감 있는 색상 시도
        if let vibrantColor = getVibrantColor() {
            var brightness: CGFloat = 0
            vibrantColor.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
            
            // 밝기가 충분하면 사용
            if brightness >= 0.5 {
                return vibrantColor
            }
        }
        
        // 생동감 있는 색상이 너무 어두우면 주요 색상 시도
        if let dominantColor = getDominantColor() {
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            
            dominantColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            
            // 강제로 밝고 연하게 조정
            let safeSaturation = min(saturation * 0.5, 0.6)
            let safeBrightness = max(brightness * 1.6, 0.75)
            let finalBrightness = min(safeBrightness, 0.9)
            
            return UIColor(hue: hue, saturation: safeSaturation, brightness: finalBrightness, alpha: alpha)
        }
        
        // 모든 시도가 실패하면 기본 연한 회색
        return UIColor.systemGray4
    }
}
