//
//  Tests_iOS.swift
//  Tests iOS
//
//  Created by Frad LEE on 5/27/21.
//

import XCTest

final class Tests_iOS: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  /// Smoke test: the demo list appears and each row navigates to its destination.
  func testDemoListAndNavigation() throws {
    let app = XCUIApplication()
    app.launch()

    XCTAssertTrue(app.navigationBars["Fluid Interfaces"].waitForExistence(timeout: 10))

    let demos = [
      "Calculator Button", "Spring Animations", "Flashlight Button",
      "Rubberbanding", "Acceleration Pausing", "Rewarding Momentum",
      "FaceTime PiP",
    ]
    for demo in demos {
      let cell = app.staticTexts[demo]
      XCTAssertTrue(cell.waitForExistence(timeout: 5), "\(demo) row missing")
      cell.tap()
      XCTAssertTrue(app.navigationBars[demo].waitForExistence(timeout: 5))
      app.navigationBars.buttons.firstMatch.tap()
    }
  }
}
