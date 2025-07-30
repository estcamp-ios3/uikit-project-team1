//
//  Category.swift
//  BGMate
//
//  Created by catharina J on 7/29/25.
//

import Foundation

struct Category: Identifiable {
    let id: UUID = UUID()
    let title: String
    let coverImageName: String? // 커버 이미지 파일 이름 (옵셔널)
    let tags: [String] // 이 카테고리에 속하는 태그 (예: "cafe", "relax")
}

// 새로운 카테고리 이름으로 categoryList 구성
let categoryList: [Category] = [
    // 1. 분위기 관련
    Category(title: "잔잔한", coverImageName: "calm_cover", tags: ["relax", "chill", "study"]),
    Category(title: "활기찬", coverImageName: "lively_cover", tags: ["energetic", "upbeat", "workout"]),
    Category(title: "감정적인", coverImageName: "emotional_cover", tags: ["moody", "deep", "sentimental"]),
    Category(title: "따뜻한", coverImageName: "warm_cover", tags: ["cozy", "comfort", "home"]),
    Category(title: "고급스러운", coverImageName: "luxury_cover", tags: ["elegant", "sophisticated", "classy"]),
    Category(title: "트렌디한", coverImageName: "trendy_cover", tags: ["modern", "hip", "popular"]),
    Category(title: "레트로/복고풍", coverImageName: "retro_cover", tags: ["vintage", "oldies", "nostalgic"]),

    // 2. 장소/컨셉 관련
    Category(title: "선술집/이자카야", coverImageName: "izakaya_cover", tags: ["bar", "pub", "drinking"]),
    Category(title: "야외/루프탑", coverImageName: "outdoor_cover", tags: ["nature", "travel", "picnic"]),
    Category(title: "빈티지/로우파이", coverImageName: "lofi_cover", tags: ["chillhop", "lofi", "study"]),

    // 3. 시간대 관련
    Category(title: "모닝BGM", coverImageName: "morning_cover", tags: ["morning", "fresh", "wake-up"]),
    Category(title: "런치타임BGM", coverImageName: "lunch_cover", tags: ["lunch", "bright", "daytime"]),
    Category(title: "에프터눈 티타임", coverImageName: "afternoon_cover", tags: ["tea", "relax", "break"]),
    Category(title: "이브닝BGM", coverImageName: "evening_cover", tags: ["evening", "night", "dinner"]),
    Category(title: "나이트타임BGM", coverImageName: "night_cover", tags: ["sleep", "calm", "midnight"]),

    // 4. 기능/목적 관련
    Category(title: "집중을 돕는 음악", coverImageName: "focus_cover", tags: ["study", "work", "concentration"]),
    Category(title: "무드전환용", coverImageName: "mood_change_cover", tags: ["uplifting", "energizing", "relaxing"]),
    Category(title: "계절별 음악", coverImageName: "seasonal_cover", tags: ["seasonal", "summer", "winter"]),
    Category(title: "브랜드 전용 플레이리스트", coverImageName: "brand_cover", tags: ["brand", "custom", "corporate"])
]
