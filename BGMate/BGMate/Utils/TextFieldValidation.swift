//
//  TextFieldValidation.swift
//  BGMate
//
//  Created by catharina J on 8/7/25.
//

import UIKit

struct TextFieldValidator {
    
    /// 허용된 문자셋
    static let allowedCharacterSet = CharacterSet(
        charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789가-힣 _-!@#$%^&*()+~`|[]{}\":;'<>?,./"
    )
    
    /// 문자열이 유효한지 검사
    static func isValidInput(currentText: String, range: NSRange, replacementString string: String) -> Bool {
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // 한글 포함 여부 판단
        let containsHangul = updatedText.contains {
            $0.unicodeScalars.contains { !$0.isASCII && $0.properties.isAlphabetic }
        }
        
        // 글자 수 제한
        let maxCount = containsHangul ? 12 : 22
        guard updatedText.count <= maxCount else { return false }

        // 삭제는 항상 허용
        if string.isEmpty { return true }

        // 한글 조합 중 입력 허용
        if string.unicodeScalars.count == 1,
           string.unicodeScalars.first?.properties.isAlphabetic == true {
            return true
        }

        // 허용된 문자만 입력 가능
        let inputCharacterSet = CharacterSet(charactersIn: string)
        return allowedCharacterSet.isSuperset(of: inputCharacterSet)
    }
}
