//
//  Article.swift
//  MagycalArticles
//
//  Created by Palla Kumar on 04/12/26.
//

import Foundation

struct Article: Codable, Equatable {
  let title: String
  let author: String
  let summary: String
  let content: String
  let articleURL: URL?
  let imageURL: URL?
  let publishedAt: String
  let sourceName: String
  enum CodingKeys: String, CodingKey {
    case title, author, description, content, url, urlToImage, publishedAt, source
  }
  enum SourceKeys: String, CodingKey { case name }
  init(from decoder: Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    title = Self.clean(try? c.decode(String.self, forKey: .title)) ?? "Untitled article"
    author = Self.clean(try? c.decode(String.self, forKey: .author)) ?? "Unknown author"
    summary =
      Self.clean(try? c.decode(String.self, forKey: .description)) ?? "No description is available."
    content = Self.clean(try? c.decode(String.self, forKey: .content)) ?? summary
    articleURL = Self.safeURL(try? c.decode(String.self, forKey: .url))
    imageURL = Self.safeURL(try? c.decode(String.self, forKey: .urlToImage))
    publishedAt = Self.clean(try? c.decode(String.self, forKey: .publishedAt)) ?? ""
    if let s = try? c.nestedContainer(keyedBy: SourceKeys.self, forKey: .source) {
      sourceName = Self.clean(try? s.decode(String.self, forKey: .name)) ?? "News"
    } else {
      sourceName = "News"
    }
  }
  func encode(to encoder: Encoder) throws {
    var c = encoder.container(keyedBy: CodingKeys.self)
    try c.encode(title, forKey: .title)
    try c.encode(author, forKey: .author)
    try c.encode(summary, forKey: .description)
    try c.encode(content, forKey: .content)
    try c.encodeIfPresent(articleURL?.absoluteString, forKey: .url)
    try c.encodeIfPresent(imageURL?.absoluteString, forKey: .urlToImage)
    try c.encode(publishedAt, forKey: .publishedAt)
    var source = c.nestedContainer(keyedBy: SourceKeys.self, forKey: .source)
    try source.encode(sourceName, forKey: .name)
  }
  private static func clean(_ s: String?) -> String? {
    guard let v = s?.trimmingCharacters(in: .whitespacesAndNewlines), !v.isEmpty else { return nil }
    return v
  }
  private static func safeURL(_ s: String?) -> URL? {
    guard let v = clean(s), let u = URL(string: v), let scheme = u.scheme?.lowercased(),
      scheme == "https" || scheme == "http"
    else { return nil }
    return u
  }
}
struct ArticlesResponse: Decodable { let articles: [Article] }
