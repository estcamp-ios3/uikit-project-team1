//
//  PlayerVC+Notifications.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/5/25.
//

import UIKit
import AVFoundation

extension PlayerViewController {
    
    // MARK: - 알림 설정
    
    func setupNotifications() {
        // 재생 완료 알림
        NotificationCenter.default.addObserver(self,
        selector: #selector(handlePlaybackFinished),
        name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}
