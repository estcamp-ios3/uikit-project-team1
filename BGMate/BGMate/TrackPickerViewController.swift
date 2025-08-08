//
//  TrackPickerViewController.swift
//  BGMate
//
//  Created by MacBook Pro on 8/1/25.
//

import UIKit

class TrackPickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - 데이터 모델
    
    /// 전체 트랙 목록 중, 현재 플레이리스트에 없는 곡들
    var availableTracks: [Song] = songs
    
    /// 선택된 곡들을 전달할 클로저
    var onTracksSelected: (([Song]) -> Void)?
    
    /// 내부 선택 상태 저장
    private var selectedTracks: [Song] = []
    
    /// 플레이리스트에 이미 있는 곡 (중복 방지)
    var existingTracks: [Song] = []
    var playlistID: UUID?
    
    // MARK: - UI 요소
    
    private let tableView = UITableView()
    
    private lazy var closeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        config.background.backgroundColor = .systemGray5
        config.background.cornerRadius = (12 + 4 * 2) / 2
        let button = UIButton(configuration: config, primaryAction: nil)
        let icon = UIImage(systemName: "xmark",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .regular))
        button.setImage(icon, for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        return button
    }()
    
    private let confirmButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("선택한 곡 추가하기", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 8
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "곡 추가"
        
        // 기존 플레이리스트 곡과 중복 제거
        var existingFileNames = Set(existingTracks.map { $0.fileName })
        if existingFileNames.isEmpty,
           let id = playlistID,
           let playlist = PlaylistManager.shared.playlists.first(where: { $0.id == id }) {
            existingFileNames = Set(playlist.playlist.map { $0.fileName })
        }
        availableTracks = songs.filter { !existingFileNames.contains($0.fileName) }
        
        // 테이블 뷰 설정: 다중 선택 허용
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TrackCell")
        tableView.allowsMultipleSelection = true
        view.addSubview(tableView)
        
        // 닫기 버튼
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        // 하단 확인 버튼
        view.addSubview(confirmButton)
        confirmButton.addTarget(self, action: #selector(doneSelecting), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // TableView
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -12),
            
            // Confirm 버튼
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneSelecting() {
        onTracksSelected?(selectedTracks)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        availableTracks.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TrackCell", for: indexPath)
        let track = availableTracks[indexPath.row]
        
        // 기본 텍스트 구성
        var content = cell.defaultContentConfiguration()
        content.text = track.title
        content.secondaryText = track.tags.joined(separator: ", ")
        cell.contentConfiguration = content
        
        // ──────────────────────────────
        // ── [변경] 왼쪽에 원형 아이콘으로 선택 표시 ──
        // 내부 selectedTracks 여부에 따라 빈 원(circle) 또는 체크된 원(checkmark.circle.fill) 사용
        let isSel = selectedTracks.contains(where: { $0.id == track.id })
        let iconName = isSel ? "checkmark.circle.fill" : "circle"
        cell.imageView?.image = UIImage(systemName: iconName)
        cell.imageView?.tintColor = .systemBlue
        // ──────────────────────────────
        
        // 배경 강조(선택된 경우)
        cell.backgroundColor = isSel ? .systemGray5 : .clear
        
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let track = availableTracks[indexPath.row]
        // 중복 방지 후 추가
        if !selectedTracks.contains(where: { $0.id == track.id }) {
            selectedTracks.append(track)
        }
        // ────────────────────────────────────────
        // ── [변경] 선택 시 아이콘을 체크된 원으로 업데이트 ──
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.imageView?.image = UIImage(systemName: "checkmark.circle.fill")
            cell.backgroundColor = .systemGray5
        }
        // ────────────────────────────────────────
    }
    
    func tableView(_ tableView: UITableView,
                   didDeselectRowAt indexPath: IndexPath) {
        let track = availableTracks[indexPath.row]
        selectedTracks.removeAll { $0.id == track.id }
        // ────────────────────────────────────────────
        // ── [변경] 선택 해제 시 아이콘을 빈 원으로 복원 ──
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.imageView?.image = UIImage(systemName: "circle")
            cell.backgroundColor = .clear
        }
        // ────────────────────────────────────────────
    }
}
