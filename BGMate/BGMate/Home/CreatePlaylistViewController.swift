//
//  CreatePlaylistViewController.swift
//  BGMate
//
//  Created by catharina J on 7/29/25.
//

import UIKit
import Combine

class CreatePlaylistViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    private var selectedCategories: [Tags] = []
    var displayTagList: [Tags] = []
    
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
        stack.spacing = 4
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
        
        nameTextField.delegate = self  // ✅ Validation 델리게이트 지정
        
        //  ✅ songs.tags 문자열이 포함되지 않을 TagList 필터링
        let allSongTags = Set(songs.flatMap { $0.tags })
            displayTagList = tagList.filter { allSongTags.contains($0.tags) }
        
        setLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder() // 화면 뜨자마자 키보드 활성화
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
            
            
            collectionView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 8),
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
        return displayTagList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagsCell.identifier, for: indexPath) as? TagsCell else {
            return UICollectionViewCell()
        }
        let tagsCell = displayTagList[indexPath.item]
        cell.configure(with: tagsCell) // 셀 구성
        return cell
    }
    
    // 아이템 선택 시 동작
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTag = displayTagList[indexPath.item]
        selectedCategories.append(selectedTag)
        print("Selected Tags: \(selectedTag.tags)")
    }
    
    // 아이템 선택 해제시 동작
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let deselectedTag = displayTagList[indexPath.item]
        selectedCategories.removeAll { $0.id == deselectedTag.id }
        print("해제된 태그: \(deselectedTag.tags)")
    }
    
    
    //MARK: - Sheet Close
    private func didTapClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - TextField Validation
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        // 현재 입력된 텍스트
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // 한글 포함 여부 판단
        let containsHangul = updatedText.contains {
            $0.unicodeScalars.contains { !$0.isASCII && $0.properties.isAlphabetic }
        }
        
        // 글자 수 제한
        let maxCount = containsHangul ? 12 : 22
        guard updatedText.count <= maxCount else { return false }
        
        // 삭제 이벤트는 항상 허용
        if string.isEmpty { return true }
        
        // 한글 조합 중 입력 허용
        if string.unicodeScalars.count == 1,
           string.unicodeScalars.first?.properties.isAlphabetic == true {
            return true
        }
        
        // 허용된 문자만 입력 가능
        let allowedCharacterSet = CharacterSet(
            charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789가-힣 _-!@#$%^&*()+~`|[]{}\":;'<>?,./"
        )
        let inputCharacterSet = CharacterSet(charactersIn: string)
        return allowedCharacterSet.isSuperset(of: inputCharacterSet)
    }
    
    
    // MARK: - Return key handling: UITextFieldDelegate 프로토콜에서 제공
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 키보드 닫기
        return true
    }
    
    
    // MARK: - Create Playlist
    private func didTapCreate() {
        // 제목 자동 생성 또는 사용자 입력
        let selectedTitles = selectedCategories.map { $0.title }
        let userInput = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let playlistName: String
        if userInput.isEmpty {
            // 사용자가 입력하지 않은 경우 자동 생성
            if selectedTitles.count == 1 {
                playlistName = selectedTitles[0]
            } else {
                playlistName = "\(selectedTitles[0]) 외 \(selectedTitles.count - 1)건"
            }
        } else {
            playlistName = userInput
        }
        
        let selectedTagStrings = selectedCategories.map { $0.tags }
        guard !selectedTagStrings.isEmpty else {
            // ⚠️ 경고창 띄우기
            let alert = UIAlertController(title: "태그 없음", message: "Tag를 1개 이상 선택해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
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
