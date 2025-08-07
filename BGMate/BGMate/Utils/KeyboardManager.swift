//
//  KeyboardManager.swift
//  BGMate
//
//  Created by catharina J on 8/7/25.
//

import UIKit

enum KeyboardManager {
    /// 키보드에 '닫기' 툴바를 추가하는 메서드
    static func addCloseButtonToolbar(to textField: UITextField, target: Any?, action: Selector) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "닫기", style: .done, target: target, action: action)
        toolbar.items = [flexibleSpace, doneButton]
        
        textField.inputAccessoryView = toolbar
    }
    
    /// 화면 탭 시 키보드 숨기기 설정
    static func enableTapToDismiss(in viewController: UIViewController) {
        let tapGesture = UITapGestureRecognizer(target: viewController, action: #selector(viewController.hideKeyboardFromScreen))
        tapGesture.cancelsTouchesInView = false
        viewController.view.addGestureRecognizer(tapGesture)
    }
}
