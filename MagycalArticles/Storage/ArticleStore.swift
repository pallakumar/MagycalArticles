//
//  ArticleStore.swift
//  MagycalArticles
//
//  Created by Palla Kumar on 04/12/26.
//

import Foundation

final class ArticleStore {
  private let key = "magycal.articles.cache"
  func save(_ articles: [Article]) {
    if let data = try? JSONEncoder().encode(articles) {
      UserDefaults.standard.set(data, forKey: key)
    }
  }
  func load() -> [Article] {
    guard let data = UserDefaults.standard.data(forKey: key),
      let values = try? JSONDecoder().decode([Article].self, from: data)
    else { return [] }
    return values
  }
}
