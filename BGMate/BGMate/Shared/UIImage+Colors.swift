//
//  UIImage+Colors.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/5/25.
//

import UIKit
import CoreImage

// MARK: - UIImage 색상 추출 확장 (공용)
extension UIImage {
    func getDominantColor() -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = 50  // 성능을 위해 작은 크기로 리사이즈
        let height = 50
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var pixelCount: CGFloat = 0
        
        // 픽셀 데이터를 순회하면서 평균 색상 계산
        for i in stride(from: 0, to: pixelData.count, by: bytesPerPixel) {
            let r = CGFloat(pixelData[i]) / 255.0
            let g = CGFloat(pixelData[i + 1]) / 255.0
            let b = CGFloat(pixelData[i + 2]) / 255.0
            let a = CGFloat(pixelData[i + 3]) / 255.0
            
            // 투명하지 않은 픽셀만 계산
            if a > 0.1 {
                red += r
                green += g
                blue += b
                pixelCount += 1
            }
        }
        
        guard pixelCount > 0 else { return UIColor.gray }
        
        red /= pixelCount
        green /= pixelCount
        blue /= pixelCount
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    func getVibrantColor() -> UIColor? {
        guard let dominantColor = getDominantColor() else { return nil }
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        dominantColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // 미니플레이어용: 텍스트 가독성을 위해 더 밝고 연하게 조정
        let adjustedSaturation = min(saturation * 0.7, 0.8)  // 채도 줄임 (더 연하게)
        let adjustedBrightness = max(brightness * 1.4, 0.65)  // 밝기 증가 (더 밝게)
        
        // 최대 밝기 제한 (너무 밝아지지 않도록)
        let finalBrightness = min(adjustedBrightness, 0.85)
        
        return UIColor(hue: hue, saturation: adjustedSaturation, brightness: finalBrightness, alpha: alpha)
    }
    
    // 텍스트 가독성을 위한 안전한 색상 추출 (MiniPlayer용)
    func getSafeColorForMiniPlayer() -> UIColor {
        // 먼저 생동감 있는 색상 시도
        if let vibrantColor = getVibrantColor() {
            var brightness: CGFloat = 0
            vibrantColor.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
            
            // 밝기가 충분하면 사용
            if brightness >= 0.5 {
                return vibrantColor
            }
        }
        
        // 생동감 있는 색상이 너무 어두우면 주요 색상 시도
        if let dominantColor = getDominantColor() {
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            
            dominantColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            
            // 강제로 밝고 연하게 조정
            let safeSaturation = min(saturation * 0.5, 0.6)
            let safeBrightness = max(brightness * 1.6, 0.75)
            let finalBrightness = min(safeBrightness, 0.9)
            
            return UIColor(hue: hue, saturation: safeSaturation, brightness: finalBrightness, alpha: alpha)
        }
        
        // 모든 시도가 실패하면 기본 연한 회색
        return UIColor.systemGray4
    }
    
    // 텍스트 가독성을 위한 안전한 색상 추출 (Player용)
    func getSafeColorForPlayer() -> UIColor {
        // MiniPlayerViewController에 이미 정의된 메소드 활용
        // 먼저 생동감 있는 색상 시도
        if let vibrantColor = getVibrantColor() {
            var brightness: CGFloat = 0
            vibrantColor.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
            
            // 밝기가 충분하면 사용
            if brightness >= 0.5 {
                return vibrantColor
            }
        }
        
        // 생동감 있는 색상이 너무 어두우면 주요 색상 시도
        if let dominantColor = getDominantColor() {
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            
            dominantColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            
            // 강제로 밝고 연하게 조정 (PlayerVC용으로 약간 더 밝게)
            let safeSaturation = min(saturation * 0.5, 0.6)
            let safeBrightness = max(brightness * 1.6, 0.75)
            let finalBrightness = min(safeBrightness, 0.9)
            
            return UIColor(hue: hue, saturation: safeSaturation, brightness: finalBrightness, alpha: alpha)
        }
        
        // 모든 시도가 실패하면 기본 연한 회색
        return UIColor.systemGray4
    }
}
