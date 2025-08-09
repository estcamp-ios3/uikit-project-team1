//
//  AudioManager.swift
//  BGMate
//
//  Created by Yesung Yoon on 7/30/25.
//

import AVFoundation

/// 오디오 재생을 관리하는 싱글톤 클래스
class AudioManager: NSObject, AVAudioPlayerDelegate {
    
    // MARK: - 프로퍼티
    
    /// 싱글톤 인스턴스
    static let shared = AudioManager()
    
    /// AVAudioPlayer 인스턴스 (로컬 미디어 파일 재생용)
    private var player: AVAudioPlayer?
    
    /// 싱글톤 패턴을 위한 private 초기화
    private override init() {
        super.init()
    }
    
    
    // MARK: - 상태 관련 프로퍼티
    
    /// 현재 재생 중인지 여부
    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    /// 현재 볼륨 (0.0 ~ 1.0)
    var currentVolume: Float {
        return player?.volume ?? 0.5
    }
    
    /// 현재 재생 위치 (초 단위)
    var playerCurrentTime: TimeInterval {
        return player?.currentTime ?? 0
    }
    /// 특정 위치로 재생 위치 이동
    func seekTo(time: TimeInterval) {
        player?.currentTime = time
    }
    
    /// 총 재생 시간 (초 단위)
    var playerDuration: TimeInterval {
        return player?.duration ?? 0
    }
    
    
    // MARK: - 오디오 제어 메소드
    
    /// 오디오 파일 로드 및 재생 준비
    func prepareAudio(named name: String, fileExtension: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else {
            print("오디오 파일을 찾을 수 없습니다.")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
        } catch {
            print("오디오 플레이어 초기화 실패: \(error.localizedDescription)")
        }
    }
    
    /// 오디오 재생
    func play() {
        guard let player = player else { return }
        
        if !player.isPlaying {
            player.play()
        }
    }
    
    /// 오디오 일시정지
    func pause() {
        player?.pause()
    }
    
    /// 오디오 정지 및 위치 초기화
    func stop() {
        guard let player = player else { return }
        
        player.stop()
        player.currentTime = 0
    }
    
    /// 볼륨 설정 (0.0 ~ 1.0)
    func setVolume(_ value: Float) {
        player?.volume = value
    }
    
    // MARK: - AVAudioPlayerDelegate 구현
    
    /// 오디오 재생 완료 시 호출되는 델리게이트 메소드
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}
