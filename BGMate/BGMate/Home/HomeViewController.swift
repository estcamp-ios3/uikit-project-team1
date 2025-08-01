//
//  HomeViewController.swift
//  BGMate
//
//  Created by 권태우 on 7/30/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    let collectionView: UICollectionView
    
    
    // UIViewController의 init은 다음과 같이 override 해야합니다.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        // CollectionView는 레이아웃이 필요합니다.
        let layout = UICollectionViewFlowLayout()
        
        // Cell의 크기와 간격 정하기
        layout.itemSize = CGSize(width: 150, height: 180)
        layout.minimumLineSpacing = 20 // 줄간격
        layout.minimumInteritemSpacing = 5 // 셀간격
        
        // 위치는 AuroLayout으로 관한다.
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        // 다 끝나고 super 호출
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // UIViewController의 init을 따로 만들면 다음의 코드도 함께 만들어야합니다.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        self.title = "BGMate"
        
        self.view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(NationCell.self, forCellWithReuseIdentifier: "NationCell")
        collectionView.register(AddCell.self, forCellWithReuseIdentifier: "AddCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPlaylists), name: .playlistCreated, object: nil)
    }
    
    @objc func reloadPlaylists() {
            collectionView.reloadData()
    }
}



extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            // 첫 번째 셀
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCell", for: indexPath) as! AddCell
            
            cell.nameLabel.text = "ADD"
            
            return cell
        } else {
            // cell의 재활용
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NationCell", for: indexPath) as! NationCell
            
            cell.flagLabel.image = UIImage(named: playlists[indexPath.item - 1].coverImageName ?? "")
            cell.nameLabel.text = playlists[indexPath.item - 1].title
            
            return cell
        }
    }
    
    // 셀 선택 시 호출
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            self.present(CreatePlaylistViewController(), animated: true, completion: nil)
            
        } else {
            navigationController?.pushViewController(MusicPlayerViewController(), animated: true)
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
}
