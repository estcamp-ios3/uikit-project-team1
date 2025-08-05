//
//  HomeViewController.swift
//  BGMate
//
//  Created by 권태우 on 7/30/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    let collectionView: UICollectionView
    
    // Initialize the collection view with a flow layout
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout = UICollectionViewFlowLayout()
        
        // Configure cell size and spacing
        layout.itemSize = CGSize(width: 150, height: 180)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 5
        
        // Initialize collection view with layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // Required initializer for using custom init
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        self.title = "BGMate"
        
        // Add and layout the collection view
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Set delegate and data source
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Register cell classes
        collectionView.register(NationCell.self, forCellWithReuseIdentifier: "NationCell")
        collectionView.register(AddCell.self, forCellWithReuseIdentifier: "AddCell")
        
        // Observe notification to reload playlists
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPlaylists), name: .playlistCreated, object: nil)
    }
    
    // Reload the collection view when new playlist is created
    @objc func reloadPlaylists() {
        collectionView.reloadData()
    }
}



extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // One extra cell for the "Add" button
        return PlaylistManager.shared.playlists.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            // First cell is the "Add" button
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCell", for: indexPath) as! AddCell
            cell.nameLabel.text = "ADD"
            return cell
        } else {
            // Playlist cells
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NationCell", for: indexPath) as! NationCell
            let playlist = PlaylistManager.shared.playlists[indexPath.item - 1]
            cell.flagLabel.image = UIImage(named: playlist.coverImageName ?? "")
            cell.nameLabel.text = playlist.title
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            // Show view to create a new playlist
            self.present(CreatePlaylistViewController(), animated: true, completion: nil)
        } else {
            // Navigate to the music player screen with selected playlist
            let selectedPlaylist = PlaylistManager.shared.playlists[indexPath.item - 1]
            let musicPlayerVC = MusicPlayerViewController()
            musicPlayerVC.receiveData = selectedPlaylist
            navigationController?.pushViewController(musicPlayerVC, animated: true)
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
}
