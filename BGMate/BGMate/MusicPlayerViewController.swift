//
//  MusicPlayerViewController.swift
//  BGMate
//
//  Created by MacBook Pro on 8/1/25.
//

import UIKit
import AVFoundation

class MusicPlayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
    
    // MARK: - Background Blur & Color
    private let backgroundImageView: UIImageView = {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
        iv.alpha = 0.7
            iv.translatesAutoresizingMaskIntoConstraints = false
            return iv
        }()
    private let blurEffectView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)
        let bv = UIVisualEffectView(effect: blur)
        bv.translatesAutoresizingMaskIntoConstraints = false
        return bv
        }()
    
    // MARK: - 상단 바 버튼 아이템
    private lazy var editBarButtonItem: UIBarButtonItem = {
        if #available(iOS 14.0, *) {
            let titleAction = UIAction(title: "제목 변경") { _ in self.editPlaylistTitle() }
            let editAction = UIAction(title: "플레이리스트 편집") { _ in self.enterBatchEditMode() }
            let deleteAction = UIAction(title: "플레이리스트 삭제", attributes: .destructive) { _ in self.showDeletePlaylistConfirmation() }
            let menu = UIMenu(title: "", children: [titleAction, editAction, deleteAction])
            return UIBarButtonItem(title: "편집", menu: menu)
        } else {
            return UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(editButtonTapped))
        }
    }()
    private lazy var finishBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(editButtonTapped))
    
    // MARK: - 모델
    var receiveData: Playlist? {
        didSet {
            guard let playlist = receiveData else { return }
            musicList = playlist
            tableView.reloadData()
            updateUI()
        }
    }
    private var musicList = Playlist(title: "", coverImageName: nil, selectedTag: [], playlist: [])
    
    // MARK: - UI 요소
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let tagsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 4
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    private let addTrackButton = UIButton(type: .system)
    private let playAllButton = UIButton(type: .system)
    private let tableView = UITableView()
    
    // MARK: - 라이프사이클
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background 뷰 설정
                view.addSubview(backgroundImageView)
                NSLayoutConstraint.activate([
                    backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
                    backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                ])
                view.addSubview(blurEffectView)
                NSLayoutConstraint.activate([
                    blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
                    blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                ])
                view.sendSubviewToBack(backgroundImageView)
        
        view.backgroundColor = .systemBackground
        setupUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MusicCell")
        tableView.backgroundColor = .clear
        tableView.backgroundView = nil
        
        // 다중 선택 허용
        tableView.allowsSelection = true
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        navigationItem.rightBarButtonItem = editBarButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let updated = PlaylistManager.shared.playlists.first(where: { $0.id == musicList.id }) {
            musicList = updated
            tableView.reloadData()
            updateUI()
        }
    }
    
    // MARK: - UI 구성
    private func setupUI() {
        [imageView, titleLabel, tagsLabel, addTrackButton, playAllButton, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        
        addTrackButton.setTitle("+ 곡추가", for: .normal)
        addTrackButton.setTitleColor(.black, for: .normal)
        addTrackButton.backgroundColor = .white
        addTrackButton.layer.cornerRadius = 8
        addTrackButton.layer.borderWidth = 2
        addTrackButton.layer.borderColor = UIColor.systemGray4.cgColor
        addTrackButton.addTarget(self, action: #selector(openTrackPicker), for: .touchUpInside)
        
        playAllButton.setTitle("▶ 전체 재생", for: .normal)
        playAllButton.backgroundColor = .systemBlue
        playAllButton.setTitleColor(.white, for: .normal)
        playAllButton.layer.cornerRadius = 8
        playAllButton.addTarget(self, action: #selector(playAllMusic), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tagsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            tagsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            tagsLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            addTrackButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            addTrackButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addTrackButton.widthAnchor.constraint(equalToConstant: 120),
            addTrackButton.heightAnchor.constraint(equalToConstant: 40),
            
            playAllButton.centerYAnchor.constraint(equalTo: addTrackButton.centerYAnchor),
            playAllButton.leadingAnchor.constraint(equalTo: addTrackButton.trailingAnchor, constant: 12),
            playAllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            playAllButton.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: addTrackButton.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - UI 업데이트
    private func updateUI() {
        titleLabel.text = musicList.title
        let coverImage = UIImage(named: musicList.coverImageName ?? "default_cover")
        imageView.image = coverImage
        
        // 배경 이미지 업데이트
        backgroundImageView.image = coverImage
        
        if musicList.selectedTag.isEmpty {
            tagsLabel.isHidden = true
        } else {
            tagsLabel.isHidden = false
            tagsLabel.text = musicList.selectedTag.joined(separator: ", ")
        }
        
        let hasSongs = !musicList.playlist.isEmpty
        let editing = tableView.isEditing
        playAllButton.isEnabled = hasSongs && !editing
        playAllButton.backgroundColor = playAllButton.isEnabled ? .systemBlue : .systemGray4
        addTrackButton.isEnabled = !editing
    }
    
    // MARK: - 테이블뷰 데이터소스 & 델리게이트
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        musicList.playlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath)
        let song = musicList.playlist[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = "\(song.title) - \(song.artist)"
        cell.contentConfiguration = content
        
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.backgroundView = nil
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            updateFinishButtonTitle()
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            // 일반 모드 재생
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            updateFinishButtonTitle()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        deleteSongs(at: [indexPath])
    }
    
    // 편집 모드 진입시 delete control 숨김 → selection control 표시
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return tableView.isEditing ? .none : .delete
    }
    
    // editing indent 해제
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // MARK: - 편집 모드 진입
    private func enterBatchEditMode() {
        tableView.setEditing(true, animated: true)
        tableView.allowsSelection = true
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsMultipleSelectionDuringEditing = true
        navigationItem.rightBarButtonItem = finishBarButtonItem
        updateFinishButtonTitle()
        updateUI()
    }
    
    // MARK: - 편집/삭제 버튼 동작
    @objc private func editButtonTapped() {
        if tableView.isEditing {
            if let selections = tableView.indexPathsForSelectedRows, !selections.isEmpty {
                deleteSongs(at: selections.sorted(by: { $0.row > $1.row }))
            } else {
                tableView.setEditing(false, animated: true)
                navigationItem.rightBarButtonItem = editBarButtonItem
                updateUI()
            }
        } else {
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "제목 변경", style: .default) { _ in self.editPlaylistTitle() })
            sheet.addAction(UIAlertAction(title: "플레이리스트 편집", style: .default) { _ in self.enterBatchEditMode() })
            sheet.addAction(UIAlertAction(title: "플레이리스트 삭제", style: .destructive) { _ in self.showDeletePlaylistConfirmation() })
            sheet.addAction(UIAlertAction(title: "취소", style: .cancel))
            present(sheet, animated: true)
        }
    }
    
    private func updateFinishButtonTitle() {
        finishBarButtonItem.title = (tableView.indexPathsForSelectedRows?.isEmpty == false) ? "삭제" : "완료"
    }
    
    // 노래 삭제 공통
    private func deleteSongs(at indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            musicList.playlist.remove(at: indexPath.row)
        }
        if let idx = PlaylistManager.shared.playlists.firstIndex(where: { $0.id == musicList.id }) {
            PlaylistManager.shared.playlists[idx].playlist = musicList.playlist
        }
        PlaylistManager.shared.savePlaylists()
        tableView.reloadData()
        updateUI()
        updateFinishButtonTitle()
    }
    
    // MARK: - 전체 재생
    @objc private func playAllMusic() {
        guard !musicList.playlist.isEmpty, !tableView.isEditing else { return }
        let playerVC = PlayerViewController()
        playerVC.musicList = musicList
        playerVC.currentIndex = 0
        playerVC.modalPresentationStyle = .overFullScreen
        present(playerVC, animated: true)
    }
    
    // MARK: - 곡 추가
    @objc private func openTrackPicker() {
        guard !tableView.isEditing else { return }
        let picker = TrackPickerViewController()
        picker.playlistID = musicList.id
        picker.existingTracks = musicList.playlist
        picker.onTracksSelected = { [weak self] newSongs in
            guard let self = self else { return }
            let combined = self.musicList.playlist + newSongs
            self.musicList.playlist = Array(NSOrderedSet(array: combined)) as? [Song] ?? combined
            if let idx = PlaylistManager.shared.playlists.firstIndex(where: { $0.id == self.musicList.id }) {
                PlaylistManager.shared.playlists[idx].playlist = self.musicList.playlist
            }
            PlaylistManager.shared.savePlaylists()
            self.tableView.reloadData()
            self.updateUI()
        }
        let nav = UINavigationController(rootViewController: picker)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 20
        }
        present(nav, animated: true)
    }
    
    // MARK: - 플레이리스트 제목 수정
    private func editPlaylistTitle() {
        let alert = UIAlertController(title: "플레이리스트 이름 변경", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.text = self.musicList.title; $0.placeholder = "새 제목을 입력하세요" }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        let saveAction = UIAlertAction(title: "저장", style: .default) { _ in
            guard let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty else { return }
            self.musicList.title = newTitle
            if let idx = PlaylistManager.shared.playlists.firstIndex(where: { $0.id == self.musicList.id }) {
                PlaylistManager.shared.playlists[idx].title = newTitle
            }
            PlaylistManager.shared.savePlaylists()
            self.updateUI()
            NotificationCenter.default.post(name: .playlistUpdated, object: nil)
        }
        alert.addAction(saveAction)
        alert.preferredAction = saveAction
        present(alert, animated: true)
    }
    
    // MARK: - 플레이리스트 삭제 확인
    private func showDeletePlaylistConfirmation() {
        let alert = UIAlertController(title: "플레이리스트 삭제",
                                      message: "\"\(musicList.title)\"를 삭제하시겠습니까?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
            if let idx = PlaylistManager.shared.playlists.firstIndex(where: { $0.id == self.musicList.id }) {
                PlaylistManager.shared.playlists.remove(at: idx)
                PlaylistManager.shared.savePlaylists()
            }
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
