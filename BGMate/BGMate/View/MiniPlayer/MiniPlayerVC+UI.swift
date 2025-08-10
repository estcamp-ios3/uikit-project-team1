//
//  MiniPlayerVC+UI.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/5/25.
//

import UIKit

extension MiniPlayerViewController {
        
    // MARK: - UI 구성
    
    func setupUI() {
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
    
    // MARK: - 배경색 업데이트 (앨범 아트 기반)
    func updateBackgroundColor(from image: UIImage?) {
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
    
    // MARK: - 애니메이션
    func animateBackgroundColor(to color: UIColor) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            self.containerView.backgroundColor = color
        })
    }
    
    // MARK: - 표시/숨김
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
}
