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
    Song(id: UUID(), title: "Fresh Morning", artist: "AcousticFlow", tags: ["brunch", "bright", "relax"], fileName: "Chill Noons"),
    Song(id: UUID(), title: "Minimal Vibe", artist: "ChillSpace", tags: ["nature", "minimal", "gallery"], fileName: "watermelt - summer")
]
