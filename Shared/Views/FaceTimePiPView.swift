//
//  FaceTimePiPView.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 6/3/21.
//

import SwiftUI

// MARK: - FaceTimePiPView

/// A re-creation of the picture-in-picture UI of the iOS FaceTime app.
///
/// # Key Features
///
/// 1. Light weight, airy interaction.
/// 2. Continuous animation that respects the gesture’s initial velocity.
///
/// # Design Theory
///
/// This drawer shows the concept of rewarding momentum. When the user swipes a view with
/// velocity, it’s much more satisfying to animate the view with bounciness. This makes the interface
/// feel alive and fun.
///
/// When the drawer is tapped, it animates without bounciness, which feels appropriate, since a tap
/// has no momentum in a particular direction.
///
/// When designing custom interactions, it’s important to remember that interfaces can have
/// different animations for different interactions.
///
/// # References
///
/// - [Building Fluid Interfaces. How to create natural gestures and…](https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5)
///
///
/// # To Do
///
/// - Use `PreferenceKey` rewrite this view, [read more](https://swiftwithmajid.com/2020/01/15/the-magic-of-view-preferences-in-swiftui/ ).

struct FaceTimePiPView: View {
  // MARK: Internal

  var body: some View {
    ZStack(alignment: .bottom) {
      GeometryReader { geometry in
        let geometryWidth = geometry.size.width
        let geometryHeight = geometry.size.height
        background
        filledRoundedRectangle
          .offset(x: currentPosition.width, y: currentPosition.height)
          .gesture(
            DragGesture()
              .onChanged { value in
                self.currentPosition = CGSize(
                  width: value.translation.width + self.newPosition.width,
                  height: value.translation.height + self.newPosition.height
                )
              }
              .onEnded { value in
                self.predictedEndLocation = value.predictedEndLocation

                self.roundedRectanglePosition =
                  findRoundedRectanglePosition(
                    geometry, currentPosition, predictedEndLocation
                  ).position ?? .topLeading

                switch roundedRectanglePosition {
                case .topLeading:
                  newPosition = CGSize(width: 0, height: 0)
                case .topTrailing:
                  newPosition = CGSize(width: geometryWidth - 120, height: 0)
                case .bottomLeading:
                  newPosition = CGSize(width: 0, height: geometryHeight - 180)
                case .bottomTrailing:
                  newPosition = CGSize(
                    width: geometryWidth - 120,
                    height: geometryHeight - 180
                  )
                }

                if findRoundedRectanglePosition(
                  geometry, currentPosition, predictedEndLocation
                ).shouldSpring {
                  withAnimation(.spring()) {
                    self.currentPosition = self.newPosition
                  }
                } else {
                  withAnimation(.default) {
                    self.currentPosition = self.newPosition
                  }
                }
              }
          )
      }
      debugView
    }
    .padding()
  }

  // MARK: Private

  private enum RoundedRectanglePosition {
    /// `-----`
    /// `|x| |`
    /// `-----`
    /// `| | |`
    /// `-----`
    case topLeading

    /// `-----`
    /// `| |x|`
    /// `-----`
    /// `| | |`
    /// `-----`
    case topTrailing

    /// `-----`
    /// `| | |`
    /// `-----`
    /// `|x| |`
    /// `-----`
    case bottomLeading

    /// `-----`
    /// `| | |`
    /// `-----`
    /// `| |x|`
    /// `-----`
    case bottomTrailing
  }

  @State private var roundedRectanglePosition: RoundedRectanglePosition =
    .topLeading

  @State private var predictedEndLocation: CGPoint = .zero

  @State private var currentPosition: CGSize = .zero
  @State private var newPosition: CGSize = .zero

  /// Find the right corner which rounded rectangle should be pinned.
  /// - Parameters:
  ///   - geometry: Size of the container view.
  ///   - currentPosition: Current poistion of  rounded rectangle.
  /// - Returns: The corner which rounded rectangle should be pinned.
  private func findRoundedRectanglePosition(
    _ geometry: GeometryProxy,
    _ currentPosition: CGSize,
    _ predictedEndLocation: CGPoint
  ) -> (position: RoundedRectanglePosition?, shouldSpring: Bool) {
    /// Current position X / width
    let currentX = currentPosition.width
    /// Current position Y / height
    let currentY = currentPosition.height

    /// `GeometryProxy` X / width
    let geometryX = geometry.size.width
    /// `GeometryProxy` Y / height
    let geometryY = geometry.size.height

    /// Predicted End Location X
    let predictedX = predictedEndLocation.x
    /// Predicted End Location Y
    let predictedY = predictedEndLocation.y

    // - TODO: Fix the CHAOS logic.
    if predictedX < geometryX / 2,
       predictedY < geometryY / 2 {
      return (position: .topLeading, shouldSpring: true)
    } else if predictedX > geometryX / 2,
              predictedY < geometryY / 2 {
      return (position: .topTrailing, shouldSpring: true)
    } else if predictedX < geometryX / 2,
              predictedY > geometryY / 2 {
      return (position: .bottomLeading, shouldSpring: true)
    } else if predictedX > geometryX / 2,
              predictedY > geometryY / 2 {
      return (position: .bottomTrailing, shouldSpring: true)
    } else if currentX < geometryX / 2,
              currentY < geometryY / 2 {
      return (position: .topLeading, shouldSpring: false)
    } else if currentX > geometryX / 2,
              currentY < geometryY / 2 {
      return (position: .topTrailing, shouldSpring: false)
    } else if currentX < geometryX / 2,
              currentY > geometryY / 2 {
      return (position: .bottomLeading, shouldSpring: false)
    } else if currentX > geometryX / 2,
              currentY > geometryY / 2 {
      return (position: .bottomTrailing, shouldSpring: false)
    } else {
      // -TODO: Catch the error
      return (nil, false)
    }
  }
}

extension FaceTimePiPView {
  var roundedRectangle: some View {
    RoundedRectangleView(isFiiled: false)
  }

  var filledRoundedRectangle: some View {
    RoundedRectangleView(isFiiled: true)
  }

  var background: some View {
    HStack {
      VStack {
        roundedRectangle
        Spacer()
        roundedRectangle
      }
      Spacer()
      VStack {
        roundedRectangle
        Spacer()
        roundedRectangle
      }
    }
  }

  var debugView: some View {
    VStack(alignment: .center, spacing: 8) {
      Text("Current Position")
        .textCase(.uppercase)
      HStack(spacing: 0) {
        Text("(")
        FormatedNumView(num: $currentPosition.height)
        Text(", ")
        FormatedNumView(num: $currentPosition.width)
        Text(")")
      }
      .animation(nil)
    }
    .foregroundColor(.white)
    .padding()
    .background(RoundedRectangle(cornerRadius: 8)
      .fill(Color.black.opacity(0.3)))
  }
}

// MARK: - RoundedRectangleView

struct RoundedRectangleView: View {
  @State var isFiiled: Bool

  var body: some View {
    let linearGradient = LinearGradient(
      gradient: Gradient(colors: [.topColor, .bottomColor]),
      startPoint: .top,
      endPoint: .bottom
    )
    Group {
      if isFiiled {
        RoundedRectangle(cornerRadius: 8)
          .fill(linearGradient)
      } else {
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.clear)
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Color.gray, lineWidth: 2)
          )
      }
    }
    .frame(
      width: 120,
      height: 180,
      alignment: .center
    )
  }
}

private extension Color {
  static let topColor = Color(red: 0.95, green: 0.95, blue: 0.23)
  static let bottomColor = Color(red: 0.97, green: 0.65, blue: 0.11)
}

// MARK: - FaceTimePiPView_Previews

struct FaceTimePiPView_Previews: PreviewProvider {
  static var previews: some View {
    FaceTimePiPView()
  }
}
