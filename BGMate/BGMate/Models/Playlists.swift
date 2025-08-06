//
//  Playlists.swift
//  BGMate
//
//  Created by catharina J on 7/30/25.
//

import Foundation

struct Playlist: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var coverImageName: String?
    var selectedTag: [String] // ✅ 여기! 추가되었습니다!
    var playlist: [Song]
}
