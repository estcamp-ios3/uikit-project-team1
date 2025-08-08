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
    Song(id: UUID(), title: "sorry i like you", artist: "burbank", tags: ["cafe", "relax", "evening"], fileName:"burbank - sorry i like you"),
    Song(id: UUID(), title: "Chill Noons", artist: "Kronicle", tags: ["morning", "relax"], fileName: "Chill Noons"),
    Song(id: UUID(), title: "Chinese Mood Song", artist: "Fantasy & World Music by the Fiechters", tags: ["bar", "chillhop"], fileName: "ChineseMoodSong"),
    Song(id: UUID(), title: "Chimes · Jeff Kaale", artist: "dash_vfx", tags: ["uplifting", "evening"], fileName:"Chimes  Jeff Kaale"),
    Song(id: UUID(), title: "Dear Katara", artist: "L.Dre", tags: ["moody", "study", "relax"], fileName: "Dear Katara"),
    Song(id: UUID(), title: "Answer", artist: "DLJ", tags: ["chillhop", "evening"], fileName: "DLJ - Answer"),
    Song(id: UUID(), title: "Chillhop Lofi Beats", artist: "Fashion by Alex Productions", tags: ["modern", "energetic","winter"], fileName: "Fashion by Alex Productions"),
    Song(id: UUID(), title: "Float", artist: "Mr.Goldenfold", tags: ["sleep", "chillhop", "cafe"], fileName: "Float"),
    Song(id: UUID(), title: "Japanese Mood", artist: "Uness Beatz", tags: ["bar", "sleep", "brand_cover"], fileName: "JapaneseMoodSong"),
    Song(id: UUID(), title: "watermelt", artist: "Yūgen", tags: ["nature", "summer"], fileName: "watermelt - summer"),
]
