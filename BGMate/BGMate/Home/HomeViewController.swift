//
//  HomeViewController.swift
//  BGMate
//
//  Created by 권태우 on 7/30/25.
//

import UIKit

class HomeViewController: UIViewController, UISearchBarDelegate {
    let collectionView: UICollectionView
    // Declaration of search bar and table view
    let searchBar = UISearchBar()
    // Full tag list and filtered results
    let results = PlaylistManager.shared.playlists
    var filteredResults: [Playlist] = PlaylistManager.shared.playlists
    
    var isEditingPlaylists = false // Track edit mode
    
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
        
        // Add tap gesture to dismiss the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // Add right bar button item
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "minus.circle"),
            style: .plain,
            target: self,
            action: #selector(rightBarButtonTapped)
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // UI setup
        setupSearchBar()
        
        // Add and layout the collection view
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: MiniPlayerState.shared.isMiniPlayerVisible ? -65 : 0)
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
    
    // Configure the search bar
    private func setupSearchBar() {
        searchBar.placeholder = "Type to search..."
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        // Set up auto layout constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - SearchBar Delegate
    
    // Perform filtering when search text changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredResults.removeAll()
            filteredResults = PlaylistManager.shared.playlists
        } else {
            filteredResults = PlaylistManager.shared.playlists.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        collectionView.reloadData()
    }
    
    // Reset state when cancel button is clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredResults.removeAll()
        filteredResults = PlaylistManager.shared.playlists
        collectionView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    // Method to dismiss the keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Reload the collection view when new playlist is created
    @objc func reloadPlaylists() {
        collectionView.reloadData()
    }
    
    @objc func rightBarButtonTapped() {
        isEditingPlaylists.toggle()
        
        // Change the right bar button icon
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: isEditingPlaylists ? "checkmark" : "minus.circle")
        
        // Reload collection view to show/hide delete icons
        collectionView.reloadData()
    }
}



extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // One extra cell for the "Add" button
        return filteredResults.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            // First cell is the "Add" button
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCell", for: indexPath) as! AddCell
            cell.nameLabel.text = "ADD PLAYLIST"
            return cell
        } else {
            // Playlist cells
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NationCell", for: indexPath) as! NationCell
            let playlist = filteredResults[indexPath.item - 1]
            cell.flagLabel.image = UIImage(named: playlist.coverImageName ?? "")
            cell.nameLabel.text = playlist.title
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditingPlaylists {
            if indexPath.item != 0 {
                let alert = UIAlertController(
                    title: "Delete Playlist",
                    message: "Are you sure you want to delete \"\(filteredResults[indexPath.item - 1].title)\"?",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    // Remove from PlaylistManager's playlists
                    if let fullIndex = PlaylistManager.shared.playlists.firstIndex(where: { $0.id == self.filteredResults[indexPath.item - 1].id }) {
                        PlaylistManager.shared.playlists.remove(at: fullIndex)
                    }
                    self.filteredResults.remove(at: indexPath.item - 1)
                    collectionView.reloadData()
                }))
                present(alert, animated: true)
            }
        } else{
            if indexPath.item == 0 {
                // Show view to create a new playlist
                self.present(CreatePlaylistViewController(), animated: true, completion: nil)
            } else {
                // Navigate to the music player screen with selected playlist
                let selectedPlaylist = filteredResults[indexPath.item - 1]
                let musicPlayerVC = MusicPlayerViewController()
                musicPlayerVC.receiveData = selectedPlaylist
                navigationController?.pushViewController(musicPlayerVC, animated: true)
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
}
