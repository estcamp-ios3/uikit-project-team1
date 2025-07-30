//
//  CreatePlaylistViewController.swift
//  BGMate
//
//  Created by catharina J on 7/29/25.
//

import UIKit

class CreatePlaylistViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var selectedCategories: [Category] = []
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "플레이 리스트 이름 입력"
        textField.borderStyle = .roundedRect
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
    
    private let stackLable: UILabel = {
        let label = UILabel()
        label.text = "배경선택"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
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
//    private var collectionViewHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "Playlist 생성"
        
        setLayout()
     
        addColorBoxes()
        
        setupCollectionView()
    }
    
    // MARK: - Layout
    private func setLayout() {
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(vStackView)
        
        vStackView.addArrangedSubview(stackLable)
        vStackView.addArrangedSubview(hStackView)
        
        view.addSubview(createButton)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
        
            stackView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
           
            stackView.widthAnchor.constraint(equalTo:safeArea.widthAnchor, multiplier: 1, constant: -32),
            stackView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -20),
            
            vStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            vStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
//            vStackView.widthAnchor.constraint(equalTo:stackView.widthAnchor, multiplier: 1),
            vStackView.heightAnchor.constraint(equalToConstant: 60),
            
            nameTextField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            nameTextField.widthAnchor.constraint(equalTo:stackView.widthAnchor, multiplier: 1),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalTo:view.widthAnchor, multiplier: 1, constant: -32),
            createButton.heightAnchor.constraint(equalToConstant: 44)
            
        ])
    }
    
    //MARK: - hStackView에 색상 박스 추가
    private func addColorBoxes() {
        let colors: [UIColor] = [.systemOrange, .systemTeal, .systemGreen, .systemBlue, .systemPurple, .systemGray] // 예시 색상
        for color in colors {
            let colorView = UIView()
            colorView.backgroundColor = color
            colorView.translatesAutoresizingMaskIntoConstraints = false
            colorView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            colorView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            colorView.layer.cornerRadius = 8
            colorView.layer.masksToBounds = true
            hStackView.addArrangedSubview(colorView)
        }
    }
    
    // MARK: - CollectionView
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let itemWidth = (UIScreen.main.bounds.width - 16 * 2 - 10 * 2) / 3 // 3열, 좌우 여백 및 아이템 간 여백 고려
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 30) // 이미지 + 텍스트 공간
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
        collectionView.backgroundColor = .clear // 배경색 설정
        collectionView.allowsMultipleSelection = true
        
        // stackView에 collectionView 추가
        stackView.addArrangedSubview(collectionView)
        
        // 컬렉션 뷰 제약 조건 추가 (필요시)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
           
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryList.count // Category.swift 파일의 categoryList 사용
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else {
            return UICollectionViewCell()
        }
        let category = categoryList[indexPath.item]
        cell.configure(with: category) // 셀 구성
        return cell
    }
    
    // 아이템 선택 시 동작
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCategory = categoryList[indexPath.item]
        print("Selected category: \(selectedCategory.title)")
    }
}
