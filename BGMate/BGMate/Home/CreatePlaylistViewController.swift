//
//  CreatePlaylistViewController.swift
//  BGMate
//
//  Created by catharina J on 7/29/25.
//

import UIKit

class CreatePlaylistViewController: UIViewController {
    private let scrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollview
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
//    private let nameLabel: UILabel = {
//        let label = UILabel()
//        label.text = "이름"
//        label.font = .systemFont(ofSize: 14, weight: .bold)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        return label
//        
//    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "플레이 리스트 이름 입력"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    private let createButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "플레이리스트 추가하기"
        let button = UIButton(configuration: config, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "Playlist 생성"
        
        setUI()
    }
    
    func setUI() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(nameTextField)
        
        view.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo:view.widthAnchor, multiplier: 1),
            
            nameTextField.widthAnchor.constraint(equalTo:stackView.widthAnchor, multiplier: 1),
            nameTextField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            createButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalTo:view.widthAnchor, multiplier: 1, constant: -32),
            
        ])
    }
}

#Preview{
    CreatePlaylistViewController()
}
