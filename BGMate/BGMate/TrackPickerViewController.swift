//
//  TrackPickerViewController.swift
//  BGMate
//
//  Created by MacBook Pro on 8/1/25.
//

import UIKit

class TrackPickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView = UITableView()
    var availableTracks: [Song] = songs // Song.swift의 전역 songs 사용
    
    // ✅ 다중 선택된 곡들을 MusicPlayerViewController로 전달
    var onTracksSelected: (([Song]) -> Void)?
    
    private var selectedTracks: [Song] = []
    
    // ✅ 현재 플레이리스트에 존재하는 곡들 (중복 제거용)
    var existingTracks: [Song] = []
    var playlistID: UUID? // 현재 플레이리스트의 ID
    
    // ✅ 하단 버튼
        private let confirmButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("선택한 곡 추가하기", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .systemBlue
            button.layer.cornerRadius = 8
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(confirmButton)
        view.backgroundColor = .systemBackground
        title = "곡 추가"
    
        // ✅ 기존 곡들의 fileName 기준으로 중복 필터링
        var existingFileNames = Set(existingTracks.map { $0.fileName })
        // 만약 existingTracks가 비어있다면 PlaylistManager에서 다시 가져오기
        if existingTracks.isEmpty, let id = playlistID,
        let playlist = PlaylistManager.shared.playlists.first(where: { $0.id == id }) {
            existingFileNames = Set(playlist.playlist.map { $0.fileName })
            }
        
        // ✅ 기존 곡 제외
        availableTracks = songs.filter { !existingFileNames.contains($0.fileName) }

        tableView.allowsMultipleSelection = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TrackCell")
        view.addSubview(tableView)
                
        NSLayoutConstraint.activate([
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            confirmButton.heightAnchor.constraint(equalToConstant: 50),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -12)
        ])
        
        // Add right bar button item
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "multiply.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(didTapClose)
        )

        // ✅ 하단 버튼 추가
        confirmButton.addTarget(self, action: #selector(doneSelecting), for: .touchUpInside)
    }
    
    //MARK: - close
    @objc func didTapClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneSelecting() {
        onTracksSelected?(selectedTracks)
        dismiss(animated: true, completion: nil)
        }
    
    // MARK: - DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return availableTracks.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath)
            let track = availableTracks[indexPath.row]
            
            var content = cell.defaultContentConfiguration()
            content.text = track.title
            content.secondaryText = track.tags.joined(separator: ", ")
            cell.contentConfiguration = content
            
            return cell
        }
        
    
    // MARK: - Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedTrack = availableTracks[indexPath.row]
            if !selectedTracks.contains(where: { $0.id == selectedTrack.id }) {
                selectedTracks.append(selectedTrack)
            }
        }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
            let deselectedTrack = availableTracks[indexPath.row]
            selectedTracks.removeAll { $0.id == deselectedTrack.id }
        }
    }
