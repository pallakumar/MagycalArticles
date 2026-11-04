//
//  ArticleCardCell.swift
//  MagycalArticles
//
//  Created by Palla Kumar on 04/12/26.
//

import Kingfisher
import UIKit

final class ArticleCardCell: UICollectionViewCell {
  static let id = "ArticleCardCell"
  private let card = UIView()
  private let photo = UIImageView()
  private let titleLabel = UILabel()
  private let meta = UILabel()
  private let read = UIButton(type: .system)
  var onRead: (() -> Void)?
  override init(frame: CGRect) {
    super.init(frame: frame)
    build()
  }
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    build()
  }
  private func build() {
    card.backgroundColor = UIColor(red: 0.10, green: 0.25, blue: 0.30, alpha: 1)
    card.layer.cornerRadius = 9
    card.clipsToBounds = true
    contentView.addSubview(card)
    card.translatesAutoresizingMaskIntoConstraints = false
    photo.contentMode = .scaleAspectFill
    photo.clipsToBounds = true
    photo.backgroundColor = .secondarySystemBackground
    titleLabel.textColor = .white
    titleLabel.font = .preferredFont(forTextStyle: .subheadline)
    titleLabel.adjustsFontForContentSizeCategory = true
    titleLabel.numberOfLines = 3
    meta.textColor = UIColor(white: 0.78, alpha: 1)
    meta.font = .systemFont(ofSize: 10)
    read.setTitle("Read More  ⊕", for: .normal)
    read.setTitleColor(.white, for: .normal)
    read.titleLabel?.font = .systemFont(ofSize: 11, weight: .semibold)
    read.backgroundColor = UIColor(red: 0.10, green: 0.40, blue: 0.68, alpha: 1)
    read.layer.cornerRadius = 5
    read.addTarget(self, action: #selector(readTap), for: .touchUpInside)
    [photo, titleLabel, meta, read].forEach {
      card.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    NSLayoutConstraint.activate([
      card.topAnchor.constraint(equalTo: contentView.topAnchor),
      card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      photo.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
      photo.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
      photo.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
      photo.heightAnchor.constraint(equalTo: card.widthAnchor, multiplier: 0.58),
      titleLabel.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 6),
      titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 9),
      titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -9),
      meta.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
      meta.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
      meta.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -8),
      read.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
      read.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -7),
      read.heightAnchor.constraint(equalToConstant: 27),
      read.widthAnchor.constraint(equalToConstant: 92),
      meta.trailingAnchor.constraint(lessThanOrEqualTo: read.leadingAnchor, constant: -3),
    ])
  }
  func configure(_ item: Article) {
    titleLabel.text = item.title
    meta.text = item.publishedAt.isEmpty ? item.sourceName : item.publishedAt
    if let url = item.imageURL {
      let targetSize = CGSize(
        width: max(photo.bounds.width, 320) * UIScreen.main.scale,
        height: max(photo.bounds.height, 180) * UIScreen.main.scale
      )
      let processor = DownsamplingImageProcessor(size: targetSize)
      photo.kf.setImage(
        with: url,
        placeholder: UIImage(systemName: "photo"),
        options: [
          .processor(processor),
          .scaleFactor(UIScreen.main.scale),
          .cacheOriginalImage,
        ]
      )
    } else {
      photo.image = UIImage(systemName: "photo")
    }
  }
  @objc private func readTap() { onRead?() }
}
