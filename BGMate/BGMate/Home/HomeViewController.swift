//
//  HomeViewController.swift
//  BGMate
//
//  Created by catharina J on 7/29/25.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate {
    
    let collectionView: UICollectionView
    
    let nationsStore = NationsStore()
    
    // UIViewController의 init은 다음과 같이 override 해야합니다.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        // CollectionView는 레이아웃이 필요합니다.
        let layout = UICollectionViewFlowLayout()
        
        // Cell의 크기와 간격 정하기
        layout.itemSize = CGSize(width: 70, height: 70)
        layout.minimumLineSpacing = 5 // 줄간격
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
        
        self.title = "Nations Collection"
        
        
        collectionView.backgroundColor = .lightGray
        
        self.view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 커스텀 셀 만들어 활용
        collectionView.register(NationCell.self, forCellWithReuseIdentifier: "NationCell")
    }
}



extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nationsStore.nations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // cell의 재활용
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NationCell", for: indexPath) as! NationCell
        
        cell.flagLabel.text = nationsStore.nations[indexPath.row].flag
        cell.nameLabel.text = nationsStore.nations[indexPath.row].name
        
        return cell
    }
    
    
}

extension NationCollectionViewController: UICollectionViewDelegate {
    
}
