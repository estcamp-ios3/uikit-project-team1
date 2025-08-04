//
//  Untitled.swift
//  BGMate
//
//  Created by MacBook Pro on 8/4/25.
//

import Foundation

class PlaylistStorage {
    static let shared = PlaylistStorage()
    private let key = "savedPlaylist"

    func save(_ playlist: Playlist) {
        if let data = try? JSONEncoder().encode(playlist) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func load() -> Playlist? {
        if let data = UserDefaults.standard.data(forKey: key),
           let playlist = try? JSONDecoder().decode(Playlist.self, from: data) {
            return playlist
        }
        return nil
    }
}
