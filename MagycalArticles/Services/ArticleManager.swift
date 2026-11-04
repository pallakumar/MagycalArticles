//
//  ArticleManager.swift
//  MagycalArticles
//
//  Created by Palla Kumar on 04/12/26.
//

import Foundation

final class ArticleManager {
  private let provider: ArticleProviding
  private let store: ArticleStore
  init(provider: ArticleProviding, store: ArticleStore) {
    self.provider = provider
    self.store = store
  }
  func load(completion: @escaping (Result<([Article], Bool), Error>) -> Void) {
    provider.fetch { [weak self] result in
      switch result {
      case .success(let items):
        self?.store.save(items)
        completion(.success((items, false)))
      case .failure(let error):
        let saved = self?.store.load() ?? []
        if saved.isEmpty {
          completion(.failure(error))
        } else {
          completion(.success((saved, true)))
        }
      }
    }
  }
  func cached() -> [Article] { store.load() }
}
