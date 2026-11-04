//
//  ArticleProviderTests.swift
//  MagycalArticles
//
//  Created by Palla Kumar on 04/11/26.
//
import XCTest
@testable import MagycalArticles

final class ArticleProviderTests: XCTestCase {
    func testProviderParsesValidResponse() {
        // TODO: Stub URLSession (for example, with a custom URLProtocol)
        // to return a valid JSON fixture; assert decoded Article values.
        XCTAssertTrue(true, "Implement against your ArticleProvider API.")
    }

    func testProviderHandlesInvalidJSON() {
        // TODO: Stub a malformed JSON response and assert a decoding error.
        XCTAssertTrue(true, "Implement against your ArticleProvider API.")
    }

    func testProviderHandlesNetworkError() {
        // TODO: Stub a URLSession network error and assert it is propagated.
        XCTAssertTrue(true, "Implement against your ArticleProvider API.")
    }
}
