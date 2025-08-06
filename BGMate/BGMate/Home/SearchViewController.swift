//
//  SearchViewController.swift
//  UIKitPrototype
//
//  Created by 권태우 on 7/30/25.
//

import UIKit

// View controller responsible for the Search screen
class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var musicList: Playlist?
    // Declaration of search bar and table view
    let searchBar = UISearchBar()
    let tableView = UITableView()
    
    // Full tag list and filtered results
    let results = tagList
    var filteredResults: [Tags] = tagList
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.title = "SEARCH"
        
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: "SearchResultCell")
        
        // Add tap gesture to dismiss the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // UI setup
        setupSearchBar()
        setupTableView()
    }
    
    // Configure the search bar
    private func setupSearchBar() {
        searchBar.placeholder = "Type to search..."
        searchBar.delegate = self
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        // Set up auto layout constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // Configure the table view
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Set up auto layout constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: MiniPlayerState.shared.isMiniPlayerVisible ? -65 : 0)
        ])
    }
    
    // MARK: - TableView DataSource
    
    // Return number of cells in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    // Configure cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "SearchResultCell")
        
        cell.textLabel?.text = filteredResults[indexPath.row].title
        cell.imageView?.image = UIImage(named: filteredResults[indexPath.row].coverImageName ?? "")
        return cell
    }
    
    // Navigate to music player screen when a cell is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        musicList = Playlist(
            title: filteredResults[indexPath.row].title,
            coverImageName: filteredResults[indexPath.row].coverImageName,
            selectedTag: [filteredResults[indexPath.row].tags],
            playlist: songs.filter { $0.tags.contains(filteredResults[indexPath.row].tags)}
        )
        if musicList!.playlist.isEmpty {
            let alert = UIAlertController(title: "Alert", message: "No song found", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
        } else {
            playAllMusic()
        }
    }
    
    // MARK: - SearchBar Delegate
    
    // Perform filtering when search text changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredResults.removeAll()
            filteredResults = tagList
        } else {
            filteredResults = tagList.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        tableView.reloadData()
    }
    
    // Reset state when cancel button is clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredResults.removeAll()
        filteredResults = tagList
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    // Method to dismiss the keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Method to present the music player screen modally
    @objc func playAllMusic() {
        let playerVC = PlayerViewController()
        playerVC.musicList = musicList
        playerVC.currentIndex = 0
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true, completion: nil)
    }
}
