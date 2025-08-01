//
//  MusicPlayerViewController.swift
//  BGMate
//
//  Created by MacBook Pro on 7/30/25.
//

import UIKit
import AVFoundation

class MusicPlayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
    
    
    
    // MARK: - 음악 플레이어 관련 변수
    var player: AVAudioPlayer?
    var nowPlayingIndex: Int? = nil

    // 고정된 mp3 파일 목록 (파일명, 표시 텍스트, 아티스트)
    var musicList: Playlist = Playlist(title: "Ronaldo, the GOAT", coverImageName: "calm_cover", playlist: [songs[0], songs[1], songs[2]])

    // MARK: - UI 구성 요소
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let addTrackButton = UIButton(type: .system)
    let playAllButton = UIButton(type: .system)
    let tableView = UITableView()

    // MARK: - 생명 주기
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    // MARK: - UI 구성
    func setupUI() {
        // 앨범 이미지
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "japanese") // 프로젝트에 있는 이미지 이름으로 변경
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        view.addSubview(imageView)

        // 제목
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "오후 일식"
        titleLabel.font = .systemFont(ofSize: 40, weight: .semibold)
        view.addSubview(titleLabel)

        // + 곡추가 (기능 없음 - 비활성)
        addTrackButton.translatesAutoresizingMaskIntoConstraints = false
        addTrackButton.setTitle("+ 곡추가", for: .normal)
        addTrackButton.setTitleColor(.white, for: .normal)
        addTrackButton.backgroundColor = UIColor.systemGray
        addTrackButton.layer.cornerRadius = 8
        addTrackButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        addTrackButton.addTarget(self, action: #selector(openTrackPicker), for: .touchUpInside)
        view.addSubview(addTrackButton)

        // ▶ 전체 재생 버튼
        playAllButton.translatesAutoresizingMaskIntoConstraints = false
        playAllButton.setTitle("▶ 전체 재생", for: .normal)
        playAllButton.backgroundColor = UIColor.systemBlue
        playAllButton.setTitleColor(.white, for: .normal)
        playAllButton.layer.cornerRadius = 8
        playAllButton.addTarget(self, action: #selector(playAllMusic), for: .touchUpInside)
        playAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        view.addSubview(playAllButton)
        
        // 테이블뷰 (곡 리스트)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MusicCell")
        view.addSubview(tableView)

        // 오토레이아웃
        NSLayoutConstraint.activate([
            
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            addTrackButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            addTrackButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            addTrackButton.widthAnchor.constraint(equalToConstant: 95),
            addTrackButton.heightAnchor.constraint(equalToConstant: 44),

            playAllButton.centerYAnchor.constraint(equalTo: addTrackButton.centerYAnchor),
            playAllButton.leadingAnchor.constraint(equalTo: addTrackButton.trailingAnchor, constant: 12),
            playAllButton.widthAnchor.constraint(equalToConstant: 120),
            playAllButton.heightAnchor.constraint(equalToConstant: 44),

            tableView.topAnchor.constraint(equalTo: addTrackButton.bottomAnchor, constant: 15),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - 전체 재생 (순차 재생)
    @objc func playAllMusic() {
        // PlayerViewController를 모달로 띄우고, 음악 리스트와 첫 곡 정보를 전달
        let playerVC = PlayerViewController()
        playerVC.musicList = musicList
        playerVC.currentIndex = 0
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true, completion: nil)
    }
    
    //MARK: - 곡추가 버튼 동작
    @objc func openTrackPicker() {
           let pickerVC = TrackPickerViewController()
           if let sheet = pickerVC.sheetPresentationController {
               sheet.detents = [.medium(), .large()]
               sheet.prefersGrabberVisible = true
           }
           
        pickerVC.onTrackSelected = { [weak self] (newSong: Song) in
            guard let self = self else { return }
            self.musicList = Playlist(title: self.musicList.title,
                                      coverImageName: self.musicList.coverImageName,
                                      playlist: self.musicList.playlist + [newSong])
            self.tableView.reloadData()
        }
           present(pickerVC, animated: true, completion: nil)
       }
//    // MARK: - 특정 인덱스 음악 재생
//    func playMusic(at index: Int) {
//        guard index < musicList.count else { return }
//
//        let fileName = musicList[index].fileName
//        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
//            print("파일 없음: \(fileName).mp3")
//            return
//        }
//
//        do {
//            player = try AVAudioPlayer(contentsOf: url)
//            player?.delegate = self
//            player?.play()
//            nowPlayingIndex = index
//        } catch {
//            print("오디오 재생 오류: \(error)")
//        }
//    }

    // MARK: - AVAudioPlayerDelegate → 재생이 끝나면 다음 곡 자동 재생
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard let currentIndex = nowPlayingIndex else { return }
        let nextIndex = currentIndex + 1
        if nextIndex < musicList.playlist.count {
          //  playMusic(at: nextIndex)
        }
    }

    // MARK: - 테이블뷰 DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicList.playlist.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath)
        cell.textLabel?.text = musicList.playlist[indexPath.row].title

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

    // MARK: - 테이블뷰 Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 아무 동작도 하지 않음 (개별 곡 선택 시 재생 제거)
        tableView.deselectRow(at: indexPath, animated: true)
    }

