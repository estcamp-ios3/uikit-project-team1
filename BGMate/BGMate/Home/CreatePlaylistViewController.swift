//
//  CreatePlaylistViewController.swift
//  BGMate
//
//  Created by catharina J on 7/29/25.
//

import UIKit

class CreatePlaylistViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var selectedCategories: [Tags] = []
    
    private let closeButton: UIButton = {
        let config = UIButton.Configuration.plain() // 기본 스타일
        var updated = config
        
        updated.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        updated.background.backgroundColor = .systemGray5
        updated.background.cornerRadius = 12 + 4 * 2 / 2 // (icon + padding) / 2 to keep circle shape
        updated.background.strokeWidth = 0
        updated.imagePadding = 0
        
        let button = UIButton(configuration: updated, primaryAction: nil)
        let icon = UIImage(
            systemName: "xmark",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        )
        button.setImage(icon, for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private let modalLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.text = "플레이리스트 추가"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.attributedPlaceholder = NSAttributedString(
            string: "플레이 리스트 이름 입력",
            attributes: [
                .foregroundColor: UIColor.darkGray,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
        )
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    private let vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private let createButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "플레이리스트 추가하기"
        let button = UIButton(configuration: config, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setLayout()
        
        setupCollectionView()
    }
    
    // MARK: - Layout
    private func setLayout() {
        view.addSubview(stackView)
        view.addSubview(closeButton)
    
        view.addSubview(modalLabel)
        
//        stackView.addArrangedSubview(modalLabel)
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(vStackView)
        
        view.addSubview(createButton)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            modalLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            modalLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            modalLabel.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 1, constant: -32),
            
            stackView.topAnchor.constraint(equalTo: modalLabel.bottomAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo:safeArea.widthAnchor, multiplier: 1, constant: -32),
            stackView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -20),
            
           
            nameTextField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            nameTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalTo:view.widthAnchor, multiplier: 1, constant: -32),
            createButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        closeButton.addAction(UIAction { [weak self] _ in self?.didTapClose() }, for: .touchUpInside)
        createButton.addAction(UIAction { [weak self] _ in self?.didTapClose() }, for: .touchUpInside)
    }
    
    //MARK: - close
    private func didTapClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - CollectionView
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 10
//        layout.minimumInteritemSpacing = 10
        let itemWidth = (UIScreen.main.bounds.width - 16 * 2 - 10 * 2) / 3 // 3열, 좌우 여백(16) 및 아이템 간 여백(10)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 20) // 이미지 + 텍스트 공간
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TagsCell.self, forCellWithReuseIdentifier: TagsCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = true
        
        stackView.addArrangedSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagList.count // Tags.swift 파일의 tagList 사용
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagsCell.identifier, for: indexPath) as? TagsCell else {
            return UICollectionViewCell()
        }
        let tagsCell = tagList[indexPath.item]
        cell.configure(with: tagsCell) // 셀 구성
        return cell
    }
    
    // 아이템 선택 시 동작
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTags = tagList[indexPath.item]
        print("Selected Tags: \(selectedTags.title)")
    }
}
