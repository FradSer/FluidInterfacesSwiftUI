//
//  Tests_macOS.swift
//  Tests macOS
//
//  Created by Frad LEE on 5/27/21.
//

import XCTest

final class Tests_macOS: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  /// Smoke test: the app launches and the demo list is visible.
  func testListAppears() throws {
    let app = XCUIApplication()
    app.launch()

    XCTAssertTrue(app.staticTexts["Fluid Interfaces"].waitForExistence(timeout: 10))
  }
}
