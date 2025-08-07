//
//  NationCell.swift
//  BGMate
//
//  Created by 권태우 on 7/30/25.
//

import UIKit

class AddCell: UICollectionViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .systemGray6
        label.numberOfLines = 2
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        // Add nameLabel to content view
        self.contentView.addSubview(nameLabel)
        
        // Set up Auto Layout constraints
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1),
            nameLabel.heightAnchor.constraint(equalToConstant: 150),
        ])
        
    }
    
    // Required initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
