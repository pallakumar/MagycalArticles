//
//  ArticleDetailViewController.swift
//  MagycalArticles
//
//  Created by Palla Kumar on 04/12/26.
//

import Kingfisher
import SafariServices
import UIKit

final class ArticleDetailViewController: UIViewController {
  var article: Article?
  private let scroll = UIScrollView()
  private let stack = UIStackView()
  private let photo = UIImageView()
  private let heading = UILabel()
  private let meta = UILabel()
  private let bodyText = UILabel()
  private let favorite = UIButton(type: .system)
  private var isFavorite = false
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Article"
    view.backgroundColor = UIColor(red: 0.10, green: 0.25, blue: 0.30, alpha: 1)
    build()
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: false)
  }

  private func build() {
    guard let item = article else { return }
    view.addSubview(scroll)
    scroll.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    stack.axis = .vertical
    stack.spacing = 14
    scroll.addSubview(stack)
    stack.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 18),
      stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 20),
      stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -20),
      stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -22),
      stack.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -40),
    ])
    photo.heightAnchor.constraint(equalToConstant: 210).isActive = true
    photo.contentMode = .scaleAspectFill
    photo.clipsToBounds = true
    photo.layer.cornerRadius = 8
    if let url = item.imageURL {
      photo.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
    } else {
      photo.image = UIImage(systemName: "photo")
    }
    heading.text = item.title
    heading.font = .boldSystemFont(ofSize: 22)
    heading.textColor = .label
    heading.numberOfLines = 0
    meta.text = "◷  \(item.publishedAt.isEmpty ? item.sourceName:item.publishedAt)"
    meta.font = .systemFont(ofSize: 12)
    meta.textColor = .secondaryLabel
    bodyText.text = item.content
    bodyText.font = .preferredFont(forTextStyle: .body)
    bodyText.adjustsFontForContentSizeCategory = true
    bodyText.numberOfLines = 0
    [photo, heading, meta, bodyText].forEach { stack.addArrangedSubview($0) }
    let open = UIButton(type: .system)
    open.setTitle("Read full article", for: .normal)
    open.addTarget(self, action: #selector(openOriginal), for: .touchUpInside)
    open.isEnabled = item.articleURL != nil
    stack.addArrangedSubview(open)
    favorite.setImage(UIImage(systemName: "heart"), for: .normal)
    favorite.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favorite)
  }
  @objc private func openOriginal() {
    guard let url = article?.articleURL else { return }
    present(SFSafariViewController(url: url), animated: true)
  }
  @objc private func toggleFavorite() {
    isFavorite.toggle()
    favorite.tintColor = isFavorite ? .systemRed : .systemBlue
    favorite.setImage(UIImage(systemName: isFavorite ? "heart.fill" : "heart"), for: .normal)
  }
}
