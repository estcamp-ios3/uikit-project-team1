//
//  Playlists.swift
//  BGMate
//
//  Created by 권태우 on 7/30/25.
//

import Foundation

struct Playlist: Identifiable {
    let id: UUID = UUID()
    let title: String
    let coverImageName: String?
    let playlist: [Song] // 음악 배열
}

// 새로운 카테고리 이름으로 categoryList 구성
var playlists: [Playlist] = [
    Playlist(title: "Ronaldo, the GOAT", coverImageName: "calm_cover", playlist: [songs[0], songs[1], songs[2]]),
]
