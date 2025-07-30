//
//  CategoryCell.swift
//  BGMate
//
//  Created by catharina J on 7/30/25.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    static let identifier = "CategoryCell"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8 // 모서리 둥글게
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 선택되었을 때 표시할 체크마크
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true // 초기에는 숨김
        return imageView
    }()

    override var isSelected: Bool {
        didSet {
            checkmarkImageView.isHidden = !isSelected
            imageView.layer.borderWidth = isSelected ? 2 : 0
            imageView.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkImageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor), // 정사각형 유지

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),

            checkmarkImageView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 5),
            checkmarkImageView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -5),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    func configure(with category: Category) {
        titleLabel.text = category.title
        // 이미지 설정 (category.coverImageName이 있다면)
        if let imageName = category.coverImageName {
            imageView.image = UIImage(named: imageName)
        } else {
            imageView.image = UIImage(named: "defaultAlbumCover") // 기본 이미지 설정
            imageView.backgroundColor = .systemGray5 // 이미지가 없을 경우 회색 배경
        }
    }
}
