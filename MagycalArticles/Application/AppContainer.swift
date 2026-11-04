//
//  AppContainer.swift
//  MagycalArticles
//
//  Created by Palla Kumar on 04/12/26.
//

import Foundation
import Swinject
import XCGLogger

final class AppContainer {
  static let shared = AppContainer()
  let container: Container
  private init() {
    container = Container()
    let logger = XCGLogger.default
    logger.setup(
      level: .debug, showThreadName: false, showLevel: true, showFileNames: true,
      showLineNumbers: true, writeToFile: nil, fileLevel: .debug)
    container.register(ArticleProviding.self) { _ in ArticleProvider(logger: logger) }
    container.register(ArticleStore.self) { _ in ArticleStore() }.inObjectScope(.container)
    container.register(ArticleManager.self) { r in
      ArticleManager(
        provider: r.resolve(ArticleProviding.self)!, store: r.resolve(ArticleStore.self)!)
    }.inObjectScope(.container)
  }
}
