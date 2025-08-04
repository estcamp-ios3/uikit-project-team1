//
//  NationCell.swift
//  BGMate
//
//  Created by 권태우 on 7/30/25.
//

import UIKit

class NationCell: UICollectionViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let flagLabel: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = backgroundColor
        self.contentView.addSubview(flagLabel)
        self.contentView.addSubview(nameLabel)
        
        // Set up Auto Layout constraints
        NSLayoutConstraint.activate([
            flagLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            flagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            flagLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            flagLabel.heightAnchor.constraint(equalToConstant: 150),
            
            nameLabel.topAnchor.constraint(equalTo: flagLabel.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -5)
        ])
        
    }
    
    // Required initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
