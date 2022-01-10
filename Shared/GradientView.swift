//
//  GradientView.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 10/12/21.
//

import SwiftUI

// MARK: - GradientView

struct GradientView: View {
  var topColor: Color
  var bottomColor: Color

  var body: some View {
    LinearGradient(
      gradient: Gradient(colors: [topColor, bottomColor]),
      startPoint: .top,
      endPoint: .bottom
    )
  }
}

// MARK: - SwiftUIView_Previews

struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    GradientView(topColor: .red, bottomColor: .blue)
  }
}
