//
//  Song.swift
//  BGMate
//
//  Created by catharina J on 7/29/25.
//

import Foundation

struct Song: Identifiable, Codable {
    let id: UUID
    let title: String
    let artist: String
    let tags: [String]
    let fileName: String
}

let songs: [Song] = [
    Song(id: UUID(), title: "burbank - sorry i like you", artist: "DEBOIN", tags: ["cafe", "relax", "evening"], fileName:"burbank - sorry i like you"),
    Song(id: UUID(), title: "Chill Noons", artist: "Kronicle - Topic", tags: ["morning", "relax"], fileName: "Chill Noons"),
    Song(id: UUID(), title: "🥢 TRADITIONAL Chinese Music - Chinese Restaurant", artist: "Fantasy & World Music by the Fiechters", tags: ["bar", "chillhop"], fileName: "ChineseMoodSong"),
    Song(id: UUID(), title: "Chimes · Jeff Kaale", artist: "dash_vfx", tags: ["uplifting", "evening"], fileName:"Chimes  Jeff Kaale"),
    Song(id: UUID(), title: "Dear Katara (Avatar's Love but it's lofi hip hop)", artist: "L.Dre", tags: ["moody", "study", "relax"], fileName: "Dear Katara"),
    Song(id: UUID(), title: "DLJ - Answer", artist: "Vrilo Vibes", tags: ["chillhop", "evening"], fileName: "DLJ - Answer"),
    Song(id: UUID(), title: "🎵 Chillhop Lofi Beats (Music For Videos) ", artist: "BreakingCopyright — Royalty Free Music", tags: ["modern", "energetic"], fileName: "Fashion by Alex Productions"),
    Song(id: UUID(), title: "Asian trap beat 2022 | Asian music instrumental (Uness Beatz)", artist: "ChillSpace", tags: ["sleep", "chillhop", "cafe"], fileName: "Float"),
    Song(id: UUID(), title: "Japanese Mood", artist: "Uness Beatz", tags: ["bar", "sleep", "brand_cover"], fileName: "JapaneseMoodSong"),
    Song(id: UUID(), title: "watermelt", artist: "Yūgen", tags: ["nature", "summer"], fileName: "watermelt - summer"),
]
