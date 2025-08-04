////
////  HomeViewController.swift
////  BGMate
////
////  Created by 권태우 on 7/30/25.
////
//
//import UIKit
//
//class HomeViewController: UIViewController {
//    
//    let collectionView: UICollectionView
//    
//    // Initialize the collection view with a flow layout
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        let layout = UICollectionViewFlowLayout()
//        
//        // Configure cell size and spacing
//        layout.itemSize = CGSize(width: 150, height: 180)
//        layout.minimumLineSpacing = 20
//        layout.minimumInteritemSpacing = 5
//        
//        // Initialize collection view with layout
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//    
//    // Required initializer for using custom init
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.view.backgroundColor = .systemBackground
//        self.title = "BGMate"
//        
//        // Add and layout the collection view
//        self.view.addSubview(collectionView)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
//            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
//            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
//        ])
//        
//        // Set delegate and data source
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        
//        // Register cell classes
//        collectionView.register(NationCell.self, forCellWithReuseIdentifier: "NationCell")
//        collectionView.register(AddCell.self, forCellWithReuseIdentifier: "AddCell")
//        
//        // Observe notification to reload playlists
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadPlaylists), name: .playlistCreated, object: nil)
//    }
//    
//    // Reload the collection view when new playlist is created
//    @objc func reloadPlaylists() {
//        collectionView.reloadData()
//    }
//}
//
//
//
//extension HomeViewController: UICollectionViewDataSource {
//    
//    // Total number of items (including the add button cell)
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return PlaylistManager.shared.playlists.count + 1   // ✅ PlaylistManager - singleton 패턴 사용
//    }
//    
//    // Configure cell for each item
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if indexPath.item == 0 {
//            // First cell is the "Add" button
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCell", for: indexPath) as! AddCell
//            
//            cell.nameLabel.text = "ADD"
//            
//            return cell
//        } else {
//            // Other cells display playlist information
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NationCell", for: indexPath) as! NationCell
//            
//            cell.flagLabel.image = UIImage(named: PlaylistManager.shared.playlists[indexPath.item - 1].coverImageName ?? "")    // ✅ PlaylistManager - singleton 패턴 사용
//            cell.nameLabel.text = PlaylistManager.shared.playlists[indexPath.item - 1].title    // ✅ PlaylistManager - singleton 패턴 사용
//            
//            return cell
//        }
//    }
//    
//    // Handle cell selection
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if indexPath.item == 0 {
//            // Present the create playlist view
//            self.present(CreatePlaylistViewController(), animated: true, completion: nil)
//            
//        } else {
//            // Navigate to the music player view
//            // ✅ 탭하여 선택한 플레이리스트를 단일 데이터로 보내기
//            let selectedPlaylist = PlaylistManager.shared.playlists[indexPath.item - 1]
//            let musicPlayerVC = MusicPlayerViewController()
//            musicPlayerVC.receiveData = selectedPlaylist
//            navigationController?.pushViewController(musicPlayerVC, animated: true)
//        }
//    }
//}
//
//extension HomeViewController: UICollectionViewDelegate {
//    
//}
