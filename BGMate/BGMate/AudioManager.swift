//
//  AudioManager.swift
//  BGMate
//
//  Created by Yesung Yoon on 7/30/25.
//

import AVFoundation

class AudioManager {
    
    // Singleton 패턴
    static let shared = AudioManager()
    
    // 로컬 미디어 파일 재생은 AVFoundation이 제공하는 AVAudioPlayer를 활용
    private var player: AVAudioPlayer?
    
    private init() {}
    
    
    // MARK: - 연산프로퍼티
    
    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    var currentVolume: Float {
        return player?.volume ?? 0.5
    }
    
    // 현재 재생 위치 반환
    var playerCurrentTime: TimeInterval {
        return player?.currentTime ?? 0
    }
    // 특정 위치로 이동
    func seekTo(time: TimeInterval) {
        player?.currentTime = time
    }
    
    // 총 재생 시간 반환
    var playerDuration: TimeInterval {
        return player?.duration ?? 0
    }
    
    
    // MARK: - 메서드
    
    func prepareAudio(named name: String, fileExtension: String, delegate: AVAudioPlayerDelegate? = nil) {
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else {
            print("오디오 파일을 찾을 수 없습니다.")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = delegate
            player?.prepareToPlay()
        } catch {
            print("오디오 플레이어 초기화 실패: \(error.localizedDescription)")
        }
    }
    
    func play() {
        guard let player = player else { return }
        
        if !player.isPlaying {
            player.play()
        }
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        guard let player = player else { return }
        
        player.stop()
        player.currentTime = 0
    }
    
    func setVolume(_ value: Float) {
        player?.volume = value
    }
}
