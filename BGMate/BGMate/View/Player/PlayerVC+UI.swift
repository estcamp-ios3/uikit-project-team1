//
//  PlayerVC+UI.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/5/25.
//

import UIKit
import CoreImage

extension PlayerViewController {
        
    // MARK: - UI 구성
    
    func setupUI() {
        // ADD: 배경 먼저 추가
        view.addSubview(backgroundImageView)
        view.addSubview(blurEffectView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

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
    
    // MARK: - 배경 이미지 및 테마
    func updateBackgroundImage() {
        // 플레이리스트 커버 이미지 가져오기
        guard let coverImageName = musicList.coverImageName,
              let coverImage = UIImage(named: coverImageName) else {
            return
        }
        
        // 배경 이미지 설정 (크로스 디졸브 애니메이션 적용)
        UIView.transition(with: backgroundImageView, duration: 0.3, options: .transitionCrossDissolve) {
            self.backgroundImageView.image = coverImage
        }
        
        // 배경 색상 추출 및 적용 (비동기 처리)
        DispatchQueue.global(qos: .userInitiated).async {
            // 플레이리스트 커버 이미지에서 안전한 색상 추출
            let extractedColor = coverImage.getSafeColorForPlayer()
            
            DispatchQueue.main.async {
                // 추출한 색상으로 배경 색상 변경
                UIView.animate(withDuration: 0.3) {
                    self.view.backgroundColor = extractedColor
                }
            }
        }
    }
    
    // MARK: - 유틸리티 (QR 코드 생성)
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
    
    // MARK: - 데이터 바인딩 (플레이리스트 정보)
    func updatePlaylistInfo() {
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
}
