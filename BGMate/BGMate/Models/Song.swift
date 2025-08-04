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
    Song(id: UUID(), title: "Sunset Lounge", artist: "LofiBeats", tags: ["cafe", "relax", "evening"], fileName:"burbank - sorry i like you"),
    Song(id: UUID(), title: "Fresh Morning", artist: "AcousticFlow", tags: ["morning", "relax"], fileName: "Chill Noons"),
    Song(id: UUID(), title: "Fresh Morning", artist: "AcousticFlow", tags: ["bar", "chillhop"], fileName: "ChineseMoodSong"),
    Song(id: UUID(), title: "Sunset Lounge", artist: "LofiBeats", tags: ["uplifting", "evening"], fileName:"Chimes  Jeff Kaale"),
    Song(id: UUID(), title: "Fresh Morning", artist: "AcousticFlow", tags: ["moody", "study", "relax"], fileName: "Dear Katara"),
    Song(id: UUID(), title: "Minimal Vibe", artist: "ChillSpace", tags: ["chillhop", "evening"], fileName: "DLJ - Answer"),
    Song(id: UUID(), title: "Minimal Vibe", artist: "ChillSpace", tags: ["modern", "energetic"], fileName: "Fashion by Alex Productions"),
    Song(id: UUID(), title: "Minimal Vibe", artist: "ChillSpace", tags: ["sleep", "chillhop", "cafe"], fileName: "Float"),
    Song(id: UUID(), title: "Minimal Vibe", artist: "ChillSpace", tags: ["bar", "sleep", "brand_cover"], fileName: "JapaneseMoodSong"),
    Song(id: UUID(), title: "Minimal Vibe", artist: "ChillSpace", tags: ["nature", "seasonal"], fileName: "watermelt - summer"),
]
