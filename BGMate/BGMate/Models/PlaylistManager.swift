//
//  PlaylistManager.swift
//  BGMate
//
//  Created by catharina J on 8/1/25.
//

import Foundation
import Combine

class PlaylistManager: ObservableObject {
    static let shared = PlaylistManager()
    
    private init() {
        loadPlaylists()
    }
    
    /// 앱 전역에서 공유되는 플레이리스트
    @Published var playlists: [Playlist] = [] {
        didSet {
            savePlaylists()
        }
    }
    private let key = "SavedPlaylists" //didSet 블록 값이 바뀌면 자동저장

    /// 저장
    func savePlaylists() {
        let encoder = JSONEncoder()  // 데이터를 JSON 문자열로 만들기
        if let encoded = try? encoder.encode(playlists) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    /// 로드
    func loadPlaylists() {
        let decoder = JSONDecoder() // JSON 문자열을 데이터로 만들기
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decoded = try? decoder.decode([Playlist].self, from: savedData) {
            playlists = decoded
        } else {
            playlists = []  // 처음 앱 실행 시 빈 배열
        }
    }
    
    /// 새로운 플레이리스트 추가
     func addPlaylist(_ playlist: Playlist) {
         playlists.append(playlist)
         NotificationCenter.default.post(name: .playlistCreated, object: nil)
     }
    
    /// 곡 추가
    func addSong(_ song: Song, to playlistID: UUID) {
        if let index = playlists.firstIndex(where: { $0.id == playlistID }) {
            playlists[index].playlist.append(song)
        }
    }

    /// 곡 삭제
    func removeSong(songID: UUID, from playlistID: UUID) {
        if let index = playlists.firstIndex(where: { $0.id == playlistID }) {
            playlists[index].playlist.removeAll { $0.id == songID }
        }
    }
}
