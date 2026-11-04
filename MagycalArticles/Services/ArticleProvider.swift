//
//  ArticleProviding.swift
//  MagycalArticles
//
//  Created by Palla Kumar on 04/12/26.
//

import Alamofire
import Foundation
import XCGLogger

protocol ArticleProviding { func fetch(completion: @escaping (Result<[Article], Error>) -> Void) }
final class ArticleProvider: ArticleProviding {
  private let endpoint = "https://mocki.io/v1/9f09ed09-d8ca-48c7-9957-dec39e745321"
  private let logger: XCGLogger
  init(logger: XCGLogger = XCGLogger.default) { self.logger = logger }
  func fetch(completion: @escaping (Result<[Article], Error>) -> Void) {
    logger.info("Fetching article feed")
    AF.request(endpoint).validate(statusCode: 200..<300).responseDecodable(
      of: ArticlesResponse.self
    ) { [weak self] response in
      switch response.result {
      case .success(let payload):
        self?.logger.info("Loaded \(payload.articles.count) articles")
        completion(.success(payload.articles))
      case .failure(let error):
        self?.logger.error(error.localizedDescription)
        completion(.failure(error))
      }
    }
  }
}
