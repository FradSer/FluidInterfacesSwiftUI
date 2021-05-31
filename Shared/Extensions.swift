//
//  Extensions.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 5/28/21.
//

import SwiftUI

public extension View {
  func fullScreenBlackBackgroundIgnoresSafeArea() -> some View {
    modifier(FullScreenBlackBackgroundIgnoresSafeArea())
  }
}

public extension CGFloat {
  static let fullScreenWidth = UIScreen.main.bounds.width
  static let fullScreenHeight = UIScreen.main.bounds.height
}
