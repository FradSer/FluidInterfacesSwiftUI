//
//  FluidInterfacesSwiftUIApp.swift
//  Shared
//
//  Created by Frad LEE on 5/27/21.
//

import SwiftUI

@main
struct FluidInterfacesSwiftUIApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    #if os(macOS)
      .defaultSize(width: 480, height: 720)
    #endif
  }
}
