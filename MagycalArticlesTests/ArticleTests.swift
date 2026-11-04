import Kingfisher
import XCTest
@testable import MagycalArticles

final class ArticleModelTests: XCTestCase {

    func testDecodesArticleFromAPIJSON() throws {
        let data = """
        {
          "title": "Testing Article",
          "author": "Test Author",
          "description": "Summary text",
          "content": "Full content",
          "url": "https://example.com/article",
          "urlToImage": "https://example.com/image.jpg",
          "publishedAt": "2026-11-04",
          "source": { "name": "Example News" }
        }
        """.data(using: .utf8)!

        let article = try JSONDecoder().decode(Article.self, from: data)

        XCTAssertEqual(article.title, "Testing Article")
        XCTAssertEqual(article.author, "Test Author")
        XCTAssertEqual(article.summary, "Summary text")
        XCTAssertEqual(article.imageURL?.absoluteString, "https://example.com/image.jpg")
        XCTAssertEqual(article.sourceName, "Example News")
    }

    func testMissingFieldsUseSafeDefaults() throws {
        let data = """
        { "title": " ", "description": "" }
        """.data(using: .utf8)!

        let article = try JSONDecoder().decode(Article.self, from: data)

        XCTAssertEqual(article.title, "Untitled article")
        XCTAssertEqual(article.author, "Unknown author")
        XCTAssertEqual(article.summary, "No description is available.")
        XCTAssertNil(article.imageURL)
    }

    func testNonHTTPImageURLIsRejected() throws {
        let data = """
        { "title": "Unsafe image", "urlToImage": "file:///tmp/image.png" }
        """.data(using: .utf8)!

        let article = try JSONDecoder().decode(Article.self, from: data)

        XCTAssertNil(article.imageURL)
    }

    func testArticleCodableRoundTrip() throws {
        let data = """
        {
          "title": "Round trip",
          "author": "Author",
          "description": "Summary",
          "content": "Content",
          "url": "https://example.com",
          "urlToImage": "https://example.com/image.jpg",
          "publishedAt": "2026-11-04",
          "source": { "name": "Source" }
        }
        """.data(using: .utf8)!

        let original = try JSONDecoder().decode(Article.self, from: data)
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Article.self, from: encoded)

        XCTAssertEqual(decoded, original)
    }
}

final class ArticleStoreTests: XCTestCase {

    private let cacheKey = "magycal.articles.cache"

    func testSaveAndLoadArticles() throws {
        let defaults = UserDefaults.standard
        let previousData = defaults.data(forKey: cacheKey)
        defer { restore(previousData, in: defaults) }

        let data = """
        [{
          "title": "Cached Article",
          "author": "Test",
          "description": "Cached summary",
          "content": "Cached content",
          "url": "https://example.com/cached",
          "urlToImage": "https://example.com/cached.jpg",
          "publishedAt": "2026-11-04",
          "source": { "name": "Cache" }
        }]
        """.data(using: .utf8)!

        let articles = try JSONDecoder().decode([Article].self, from: data)
        let store = ArticleStore()

        store.save(articles)

        XCTAssertEqual(store.load(), articles)
    }

    func testMissingOrCorruptCacheReturnsEmptyArray() {
        let defaults = UserDefaults.standard
        let previousData = defaults.data(forKey: cacheKey)
        defer { restore(previousData, in: defaults) }

        defaults.removeObject(forKey: cacheKey)
        XCTAssertTrue(ArticleStore().load().isEmpty)

        defaults.set(Data("not-json".utf8), forKey: cacheKey)
        XCTAssertTrue(ArticleStore().load().isEmpty)
    }

    private func restore(_ data: Data?, in defaults: UserDefaults) {
        if let data = data {
            defaults.set(data, forKey: cacheKey)
        } else {
            defaults.removeObject(forKey: cacheKey)
        }
    }
}

private enum MockProviderError: Error {
    case offline
}

private final class MockArticleProvider: ArticleProviding {
    private let result: Result<[Article], Error>

    init(result: Result<[Article], Error>) {
        self.result = result
    }

    func fetch(completion: @escaping (Result<[Article], Error>) -> Void) {
        completion(result)
    }
}

final class ArticleManagerTests: XCTestCase {

    private let cacheKey = "magycal.articles.cache"

    func testSuccessfulFetchSavesArticlesToCache() throws {
        let article = try makeArticle()
        let defaults = UserDefaults.standard
        let previousData = defaults.data(forKey: cacheKey)
        defer { restore(previousData, in: defaults) }

        let store = ArticleStore()
        let manager = ArticleManager(
            provider: MockArticleProvider(result: .success([article])),
            store: store
        )

        let expectation = expectation(description: "API success")
        manager.load { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.0, [article])
                XCTAssertFalse(response.1)
                XCTAssertEqual(store.load(), [article])
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testNetworkFailureReturnsSavedArticles() throws {
        let article = try makeArticle()
        let defaults = UserDefaults.standard
        let previousData = defaults.data(forKey: cacheKey)
        defer { restore(previousData, in: defaults) }

        let store = ArticleStore()
        store.save([article])

        let manager = ArticleManager(
            provider: MockArticleProvider(result: .failure(MockProviderError.offline)),
            store: store
        )

        let expectation = expectation(description: "Offline cache fallback")
        manager.load { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.0, [article])
                XCTAssertTrue(response.1)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testNetworkFailureWithoutCacheReturnsError() {
        let defaults = UserDefaults.standard
        let previousData = defaults.data(forKey: cacheKey)
        defer { restore(previousData, in: defaults) }
        defaults.removeObject(forKey: cacheKey)

        let manager = ArticleManager(
            provider: MockArticleProvider(result: .failure(MockProviderError.offline)),
            store: ArticleStore()
        )

        let expectation = expectation(description: "No offline cache")
        manager.load { result in
            if case .success = result {
                XCTFail("Expected network failure when no saved articles exist")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    private func makeArticle() throws -> Article {
        let data = """
        [{
          "title": "Manager Test",
          "author": "Tester",
          "description": "Summary",
          "content": "Content",
          "url": "https://example.com/manager",
          "urlToImage": "https://example.com/manager.jpg",
          "publishedAt": "2026-11-04",
          "source": { "name": "Manager" }
        }]
        """.data(using: .utf8)!

        return try JSONDecoder().decode([Article].self, from: data)[0]
    }

    private func restore(_ data: Data?, in defaults: UserDefaults) {
        if let data = data {
            defaults.set(data, forKey: cacheKey)
        } else {
            defaults.removeObject(forKey: cacheKey)
        }
    }
}

final class ImageCacheConfigurationTests: XCTestCase {

    func testImageDiskCacheLimitIs50MiB() {
        XCTAssertEqual(
            ImageCache.default.diskStorage.config.sizeLimit,
            50 * 1024 * 1024
        )
    }
}
