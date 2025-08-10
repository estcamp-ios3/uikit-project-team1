//
//  MainTabBar+PlaybackState.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/5/25.
//

import UIKit

extension MainTabBarController {
    
    // MARK: - 재생 상태 관리
    
    // MARK: - 플레이어 상태 동기화 (풀스크린 ↔ 미니)
    
    func syncPlaybackState(isShuffleOn: Bool, isRepeatOn: Bool, shuffledIndices: [Int], playHistory: [Int], originalShuffledIndices: [Int]) {
        self.isShuffleOn = isShuffleOn
        self.isRepeatOn = isRepeatOn
        self.shuffledIndices = shuffledIndices
        self.playHistory = playHistory
        self.originalShuffledIndices = originalShuffledIndices
        
        print("재생 상태 동기화: 셔플=\(isShuffleOn), 반복=\(isRepeatOn)")
    }
    
    // MARK: - 현재 재생 상태 조회
    func getCurrentPlaybackState() -> (isShuffleOn: Bool, isRepeatOn: Bool, shuffledIndices: [Int], playHistory: [Int], originalShuffledIndices: [Int]) {
        return (isShuffleOn, isRepeatOn, shuffledIndices, playHistory, originalShuffledIndices)
    }
}
