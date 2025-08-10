//
//  MiniPlayerVC+Actions.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/5/25.
//

import UIKit

extension MiniPlayerViewController {
    
    // MARK: - 버튼 액션
    
    // MARK: - 액션: 이전 곡
    @objc func previousButtonTapped() {
        print("Previous button tapped")  // 디버깅용 로그
        delegate?.miniPlayerPreviousDidTap()
    }
    
    // MARK: - 액션: 재생/일시정지
    @objc func playPauseButtonTapped() {
        print("Play/Pause button tapped")  // 디버깅용 로그
        isPlaying.toggle()
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
        delegate?.miniPlayerPlayPauseDidTap()
    }
    
    // MARK: - 액션: 다음 곡
    @objc func nextButtonTapped() {
        print("Next button tapped")  // 디버깅용 로그
        delegate?.miniPlayerNextDidTap()
    }
}
