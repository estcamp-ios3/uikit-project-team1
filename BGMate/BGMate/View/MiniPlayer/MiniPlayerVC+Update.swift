//
//  MiniPlayerVC+Update.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/5/25.
//

import UIKit

extension MiniPlayerViewController {
    
    // MARK: - 재생 상태/NowPlaying 업데이트
    
    // MARK: - 재생 상태 갱신
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
    
    // MARK: - Now Playing 정보 갱신
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
}
