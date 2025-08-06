//
//  CreatePlaylistViewController.swift
//  BGMate
//
//  Created by catharina J on 7/29/25.
//

import UIKit
import Combine

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
    
    private let modalLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.text = "Playlist 생성"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
//    private let infoLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = .secondaryLabel
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textAlignment = .left
//        label.text = "Playlist에 추가할 Tag를 선택해주세요."
//        //        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        return label
//    }()
    private let infoLabel: UIStackView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true

        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.text = "Playlist에 추가할 Tag를 선택해주세요."

        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.attributedPlaceholder = NSAttributedString(
            string: "플레이리스트 제목 입력",
            attributes: [
                .foregroundColor: UIColor.darkGray,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
        )
        
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
    
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setLayout()
    }
    
    
    // MARK: - Layout
    private func setLayout() {
        view.addSubview(closeButton)
        view.addSubview(modalLabel)
        view.addSubview(nameTextField)
        view.addSubview(infoLabel)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        //        layout.minimumLineSpacing = 10 //줄(정렬 축) 간격
        //        layout.minimumInteritemSpacing = 10  //셀(교차축) 간격
        
        let itemWidth = (UIScreen.main.bounds.width - 16 * 2 - 10 * 2) / 3 // 3열, 좌우 여백(16) 및 아이템 간 여백(10)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 20) // 이미지 + 텍스트 공간
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TagsCell.self, forCellWithReuseIdentifier: TagsCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = true
        
        view.addSubview(collectionView)
        view.addSubview(createButton)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            modalLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            modalLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: modalLabel.bottomAnchor, constant: 16),
            nameTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 16),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            infoLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),

            
            collectionView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -16),
            
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalTo:view.widthAnchor, multiplier: 1, constant: -32),
            createButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        closeButton.addAction(UIAction { [weak self] _ in self?.didTapClose() }, for: .touchUpInside)
        createButton.addAction(UIAction { [weak self] _ in self?.didTapCreate() }, for: .touchUpInside)
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
        let selectedTag = tagList[indexPath.item]
        selectedCategories.append(selectedTag)
        print("Selected Tags: \(selectedTag.tags)")
    }
    
    // 아이템 선택 해제시 동작
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let deselectedTag = tagList[indexPath.item]
        selectedCategories.removeAll { $0.id == deselectedTag.id }
        print("해제된 태그: \(deselectedTag.tags)")
    }
    
    //MARK: - close
    private func didTapClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Create Playlist
    private func didTapCreate() {
        // 플레이리스트 제목 및 커버 설정
        //        guard let playlistName = nameTextField.text, !playlistName.trimmingCharacters(in: .whitespaces).isEmpty else {
        //               // ⚠️ 경고창 띄우기
        //               let alert = UIAlertController(title: "이름 없음", message: "플레이리스트 이름을 입력해주세요.", preferredStyle: .alert)
        //               alert.addAction(UIAlertAction(title: "확인", style: .default))
        //               present(alert, animated: true)
        //               return
        //           }
        //
        
        let selectedTagStrings = selectedCategories.map { $0.tags }
        guard !selectedTagStrings.isEmpty else {
            // ⚠️ 경고창 띄우기
            let alert = UIAlertController(title: "태그 없음", message: "Tag를 1개 이상 선택해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        // 제목 자동 생성 또는 사용자 입력
        let selectedTitles = selectedCategories.map { $0.title }
        let userInput = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let playlistName: String
        if userInput.isEmpty {
            // 사용자가 입력하지 않은 경우 자동 생성
            if selectedTitles.count == 1 {
                playlistName = selectedTitles[0]
            } else if selectedTitles.count < 2 {
                playlistName = selectedTitles.joined(separator: ", ")
            } else {
                playlistName = "\(selectedTitles[0]) 외 \(selectedTitles.count - 1)건"
            }
        } else {
            playlistName = userInput
        }
        
        // 태그가 겹치는 곡들 필터링
        let filteredSongs = songs.filter { song in
            !Set(song.tags).isDisjoint(with: selectedTagStrings)
        }
        
        let coverImageName = selectedCategories.randomElement()?.coverImageName
        
        let newPlaylist = Playlist(title: playlistName, coverImageName: coverImageName, selectedTag: selectedTitles, playlist: filteredSongs )
        
        // 싱글톤 변수에 추가
        PlaylistManager.shared.playlists.append(newPlaylist)
        print("Playlist Created: \(newPlaylist)")
        
        NotificationCenter.default.post(name: .playlistCreated, object: nil)
        
        // 홈으로 돌아가기
        dismiss(animated: true)
    }
}
