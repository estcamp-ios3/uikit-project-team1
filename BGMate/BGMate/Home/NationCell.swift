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
        label.textAlignment = .left
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let tagsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .light)
        label.textAlignment = .left
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let flagLabel: UIImageView = {
        let image = UIImageView()
        // Apply rounded corners to the flag image view
        image.layer.cornerRadius = 8
        image.layer.masksToBounds = true
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = backgroundColor
        self.contentView.addSubview(flagLabel)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(tagsLabel)
        
        // Set up Auto Layout constraints
        NSLayoutConstraint.activate([
            flagLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            flagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            flagLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            flagLabel.heightAnchor.constraint(equalToConstant: 150),
            
            nameLabel.topAnchor.constraint(equalTo: flagLabel.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            tagsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            tagsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            tagsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            tagsLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -5)
        ])
        
    }
    
    func startShaking() {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.values = [-0.03, 0.03, -0.03]
        animation.autoreverses = true
        animation.duration = 0.5
        animation.repeatCount = .infinity
        layer.add(animation, forKey: "shaking")
    }

    func stopShaking() {
        layer.removeAnimation(forKey: "shaking")
    }
    
    // Required initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
