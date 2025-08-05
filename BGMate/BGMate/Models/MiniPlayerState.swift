//
//  MiniPlayerState.swift
//  BGMate
//
//  Created by 권태우 on 8/5/25.
//

class MiniPlayerState {
    static let shared = MiniPlayerState()
    private init() {}

    var isMiniPlayerVisible: Bool = false
    var sizeOfMiniBar: Double = isMiniPlayerVisible ? 36 : 0
}
