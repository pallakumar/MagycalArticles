//
//  AppDelegate.swift
//  MagycalArticles
//
//  Created by Palla Kumar on 04/12/26.
//

import Kingfisher
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    configureImageCache()
    return true
  }

  private func configureImageCache() {
    // Total on-disk image cache budget: 50 MiB.
    ImageCache.default.diskStorage.config.sizeLimit = 50 * 1024 * 1024

    // Cached images are eligible for expiration after 30 days.
    ImageCache.default.diskStorage.config.expiration = .days(30)

    // Bound in-memory image storage separately to reduce memory pressure.
    ImageCache.default.memoryStorage.config.totalCostLimit = 80 * 1024 * 1024
  }

  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    UISceneConfiguration(
      name: "Default Configuration",
      sessionRole: connectingSceneSession.role
    )
  }

  func application(
    _ application: UIApplication,
    didDiscardSceneSessions sceneSessions: Set<UISceneSession>
  ) {
    // Release scene-specific resources here if the app adds any.
  }
}
