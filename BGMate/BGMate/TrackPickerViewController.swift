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
        view.backgroundColor = .systemBackground
        title = "곡 추가"
        
        tableView.allowsMultipleSelection = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TrackCell")
        view.addSubview(tableView)
        
        // ✅ 하단 버튼 추가
        confirmButton.addTarget(self, action: #selector(doneSelecting), for: .touchUpInside)
        view.addSubview(confirmButton)
        
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
            
            // 제목 + 태그 같이 표시
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
