//
//  NationCell.swift
//  Nataions
//
//  Created by Jongwook Park on 7/22/25.
//

import UIKit

class NationCell: UICollectionViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let flagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = .red
        self.contentView.addSubview(flagLabel)
        self.contentView.addSubview(nameLabel)
        
        // 오토레이아웃 설정
        NSLayoutConstraint.activate([
            flagLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            flagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            flagLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            nameLabel.topAnchor.constraint(equalTo: flagLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
        
    }
    
    // 필수요소
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
