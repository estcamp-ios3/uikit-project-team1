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
    let songs: [String] // 음악 배열
}

// 새로운 카테고리 이름으로 categoryList 구성
let playlists: [Playlist] = [
    Playlist(title: "잔잔한", coverImageName: "calm_cover", songs: ["relax", "chill", "study"]),
    Playlist(title: "활기찬", coverImageName: "lively_cover", songs: ["energetic", "upbeat", "workout"]),
    Playlist(title: "감정적인", coverImageName: "emotional_cover", songs: ["moody", "deep", "sentimental"]),
    Playlist(title: "따뜻한", coverImageName: "warm_cover", songs: ["cozy", "comfort", "home"]),
    Playlist(title: "고급스러운", coverImageName: "luxury_cover", songs: ["elegant", "sophisticated", "classy"]),
    Playlist(title: "트렌디한", coverImageName: "trendy_cover", songs: ["modern", "hip", "popular"]),
    Playlist(title: "레트로/복고풍", coverImageName: "retro_cover", songs: ["vintage", "oldies", "nostalgic"]),
    Playlist(title: "선술집/이자카야", coverImageName: "izakaya_cover", songs: ["bar", "pub", "drinking"]),
    Playlist(title: "야외/루프탑", coverImageName: "outdoor_cover", songs: ["nature", "travel", "picnic"]),
    Playlist(title: "빈티지/로우파이", coverImageName: "lofi_cover", songs: ["chillhop", "lofi", "study"]),
    Playlist(title: "모닝BGM", coverImageName: "morning_cover", songs: ["morning", "fresh", "wake-up"]),
    Playlist(title: "런치타임BGM", coverImageName: "lunch_cover", songs: ["lunch", "bright", "daytime"]),
    Playlist(title: "에프터눈 티타임", coverImageName: "afternoon_cover", songs: ["tea", "relax", "break"]),
]
