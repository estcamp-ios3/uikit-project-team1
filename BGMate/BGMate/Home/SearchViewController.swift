//
//  SearchViewController.swift
//  UIKitPrototype
//
//  Created by 권태우 on 7/23/25.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let searchBar = UISearchBar()
    let tableView = UITableView()
    
    let results: [String] = [
        "포항은 영원히 강하다",
        "영일만 친구들",
        "대구 FC",
        "전북 현대",
        "울산 현대",
        "광주 FC",
        "기 동 종 신",
        "제주 SK",
        "대전 하나",
        "김천 상무",
        "수원 FC",
        "강원 FC",
        "안양 FC",
    ]
    
    var filteredResults: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupSearchBar()
        setupTableView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tapGesture)
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "검색"
        searchBar.delegate = self
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let text = filteredResults[indexPath.row]
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = "팀 이름 예시"
        
        cell.imageView?.image = UIImage(named: "pohangSteelers")
        return cell
    }
    
    // MARK: - SearchBar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredResults.removeAll()
        } else {
            filteredResults = results.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredResults.removeAll()
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
