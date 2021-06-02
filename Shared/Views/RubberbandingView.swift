//
//  RubberbandingView.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 6/1/21.
//

import SwiftUI

// MARK: - RubberbandingView

/// Rubberbanding occurs when a view resists movement. An example is when a scrolling view
/// reaches the end of its content.
///
/// # Key Features
///
/// 1. Interface is always responsive, even when an action is invalid.
/// 2. De-synced touch tracking indicates a boundary.
/// 3. Amount of motion lessens further from the boundary.
///
/// # Design Theory
///
/// Rubberbanding is a great way to communicate invalid actions while still giving the user a sense
/// of control. It softly indicates a boundary, pulling them back into a valid state.
///
/// # References
///
/// - [Building Fluid Interfaces. How to create natural gestures and…](https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5)
struct RubberbandingView: View {
  // MARK: Internal

  var body: some View {
    let drag = DragGesture()
      .onChanged { drag in
        withAnimation(.linear) {
          self.viewState = drag.translation
        }
      }
      .onEnded { _ in
        withAnimation(.spring()) {
          viewState = .zero
        }
      }

    RoundedRectangle(cornerRadius: 32)
      .fill(
        LinearGradient(
          gradient: Gradient(colors: [.topColor, .bottomColor]),
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .frame(width: 120, height: 120, alignment: .center)
      .gesture(drag)
      .offset(x: 0, y: rubberbanding(viewState.height))
  }

  // MARK: Private

  @State private var viewState: CGSize = .zero

  /// A Apple-like rubberbanding.
  /// - Parameter of: Offset of movement distance. Base value to be power raised.
  /// - Returns: The power raised to drag movement distance .
  /// - Note: This is not how Apple preforms rubberbanding, but simplely.
  private func rubberbanding(_ of: CGFloat) -> CGFloat {
    var offset = Double(of)
    offset = offset > 0 ? pow(offset, 0.7) : -pow(-offset, 0.7)
    return CGFloat(offset)
  }
}

private extension Color {
  static let topColor = Color(red: 1.00, green: 0.36, blue: 0.31)
  static let bottomColor = Color(red: 1.00, green: 0.79, blue: 0.31)
}

// MARK: - RubberbandingView_Previews

struct RubberbandingView_Previews: PreviewProvider {
  static var previews: some View {
    RubberbandingView()
  }
}
