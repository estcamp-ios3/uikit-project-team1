//
//  NationCell.swift
//  Nataions
//
//  Created by Jongwook Park on 7/22/25.
//

import UIKit

class AddCell: UICollectionViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
//        self.backgroundColor = .red
        self.contentView.addSubview(nameLabel)
        
        // 오토레이아웃 설정
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            nameLabel.heightAnchor.constraint(equalToConstant: 140),
        ])
        
    }
    
    // 필수요소
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
