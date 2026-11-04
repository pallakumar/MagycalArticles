//
//  SceneDelegate.swift
//  MagycalArticles
//
//  Created by Palla Kumar on 04/12/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let ws = scene as? UIWindowScene else { return }

    let w = UIWindow(windowScene: ws)

    let rootVC = ArticleListViewController()
    let navController = UINavigationController(rootViewController: rootVC)

    // Hide only the navigation bar
    navController.setNavigationBarHidden(true, animated: false)

    w.rootViewController = navController
    window = w
    w.makeKeyAndVisible()
  }
}
