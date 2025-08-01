//
//  Category.swift
//  BGMate
//
//  Created by catharina J on 7/29/25.
//

import Foundation

struct Tags: Identifiable {
    let id: UUID = UUID()
    let title: String
    let coverImageName: String? // 커버 이미지 파일 이름 (옵셔널)
    let tags: String
}

let tagList: [Tags] = [
    // 1. 분위기 관련
    Tags(title: "잔잔한", coverImageName: "calm_cover", tags:"relax"),
    Tags(title: "활기찬", coverImageName: "lively_cover", tags: "energetic"),
    Tags(title: "감정적인", coverImageName: "emotional_cover", tags: "moody"),
    Tags(title: "따뜻한", coverImageName: "warm_cover", tags: "cozy"),
    Tags(title: "고급스러운", coverImageName: "luxury_cover", tags: "elegant"),
    Tags(title: "트렌디한", coverImageName: "trendy_cover", tags: "modern"),
    Tags(title: "레트로/복고풍", coverImageName: "retro_cover", tags: "vintage"),

    // 2. 장소/컨셉 관련
    Tags(title: "선술집/이자카야", coverImageName: "izakaya_cover", tags: "bar"),
    Tags(title: "야외/루프탑", coverImageName: "outdoor_cover", tags: "nature"),
    Tags(title: "빈티지/로우파이", coverImageName: "lofi_cover", tags: "chillhop"),

    // 3. 시간대 관련
    Tags(title: "모닝BGM", coverImageName: "morning_cover", tags: "morning"),
    Tags(title: "런치타임BGM", coverImageName: "lunch_cover", tags: "lunch"),
    Tags(title: "에프터눈 티타임", coverImageName: "afternoon_cover", tags: "tea"),
    Tags(title: "이브닝BGM", coverImageName: "evening_cover", tags: "evening"),
    Tags(title: "나이트타임BGM", coverImageName: "night_cover", tags: "sleep"),

    // 4. 기능/목적 관련
    Tags(title: "집중을 돕는 음악", coverImageName: "focus_cover", tags: "study"),
    Tags(title: "무드전환용", coverImageName: "mood_change_cover", tags: "uplifting"),
    Tags(title: "계절별 음악", coverImageName: "seasonal_cover", tags: "seasonal"),
    Tags(title: "브랜드 전용 플레이리스트", coverImageName: "brand_cover", tags: "brand")
]
