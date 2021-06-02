//
//  AccelerationPausingView.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 6/2/21.
//

import SwiftUI

// MARK: - AccelerationPausingView

/// To view the app switcher on iPhone X, the user swipes up from the bottom of the screen and
/// pauses midway. This interface re-creates this behavior.
///
/// # Key Features
///
/// 1. Pause is calculated based on the gesture’s acceleration.
/// 2. Faster stopping results in a faster response.
/// 3. No timers.
///
/// # Design Theory
///
/// Fluid interfaces should be fast. A delay from a timer, even if short, can make an interface feel
/// sluggish.
/// This interface is particularly cool because its reaction time is based on the user’s motion. If they
/// quickly pause, the interface quickly responds. If they slowly pause, it slowly responds.
///
/// # References
///
/// - [Building Fluid Interfaces. How to create natural gestures and…](https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5)
/// - [Calculate velocity of DragGesture](https://stackoverflow.com/questions/57222885/calculate-velocity-of-draggesture )
/// - [Gesture Deceleration - Gesture Recognizers in IOS 12, Xcode 10, and Swift 4.2](https://www.youtube.com/watch?v=cXr7ZYJXVAE)
/// - [SwiftUI Drag Gesture Tutorial](https://www.ioscreator.com/tutorials/swiftui-drag-gesture-tutorial)

struct AccelerationPausingView: View {
  // MARK: Internal

  var body: some View {
    let drag = DragGesture()
      .onChanged { value in

        let offset = { () -> CGFloat in
          let offset = value.translation.height
          if offset > 0 {
            return pow(offset, 0.7)
          } else if offset < -verticalOffset * 2 {
            return -verticalOffset * 2 - pow(
              -(offset + verticalOffset * 2),
              0.7
            )
          }
          return offset
        }()

        self.currentPosition = CGSize(
          width: value.translation.width + self.newPosition.width,
          height: offset + self.newPosition.height
        )

        self.currentVelocity = CGSize(
          width: value.predictedEndLocation.x - value.location.x,
          height: value.predictedEndLocation.y - value.location.y
        )

        trackPause(velocity: currentVelocity.height, offset: offset)
      }
      .onEnded { _ in
        hasPaused = false

        withAnimation(.spring()) {
          self.currentPosition = .zero
          self.newPosition = .zero
        }

        if abs(self.currentVelocity.height) > 200.0 {
          withAnimation(.spring()) {
            self.currentPosition = .zero
            self.newPosition = .zero
          }
        }
      }

    ZStack {
      DebugView(
        currentVelocityY: $currentVelocity.height,
        currentOffsetY: $currentPosition.height
      )
      VStack {
        if hasPaused {
          Text("Paused").textCase(.uppercase)
            .offset(x: 0, y: self.currentPosition.height)
        } else {
          Text("FIX").hidden()
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
          .offset(x: 0, y: self.currentPosition.height)
          .gesture(drag)
      }
    }
  }

  // MARK: Private

  private struct DebugView: View {
    @Binding var currentVelocityY: CGFloat
    @Binding var currentOffsetY: CGFloat

    var body: some View {
      VStack(alignment: .trailing, spacing: 8) {
        Spacer()
        HStack {
          Text("Last Velocity:")
          Spacer()
          Text("\(abs(currentVelocityY), specifier: "%.2f")")
            .font(.system(.body).monospacedDigit())
        }
        HStack {
          Text("Current Offset:")
          Spacer()
          Text(
            "\(currentOffsetY == 0 ? 0 : -currentOffsetY, specifier: "%.2f")"
          )
          .font(.system(.body).monospacedDigit())
        }
      }
      .animation(nil)
      .padding()
      .frame(
        width: .fullScreenWidth,
        height: .fullScreenWidth,
        alignment: .center
      )
    }
  }

  private let verticalOffset: CGFloat = 180

  /// The number of past velocities to track.
  private let numberOfVelocities = 7

  /// The array of past velocities.
  @State private var velocities = [CGFloat]()

  @State private var hasPaused: Bool = false

  /// The current veloctiy of drag gesture.
  ///
  /// The end of drag gesture velocity, but not our want:
  ///
  /// ``` swift
  /// let velocity = CGSize(
  ///   width: value.predictedEndLocation.x - value.location.x,
  ///   height: value.predictedEndLocation.y - value.location.y
  /// )
  /// ```
  @State private var currentVelocity: CGSize = .zero

  @State private var currentPosition: CGSize = .zero
  @State private var newPosition: CGSize = .zero

  /// Tracks the most recent velocity values, and determines whether the change is great enough to
  /// be pasued.
  ///
  /// After calling this function, the result can be checked in the `hasPaused` property.
  private func trackPause(velocity: CGFloat, offset: CGFloat) {
    // if the motion is paused, we are done
    if hasPaused { return }

    // update the array of most recent velocities
    if velocities.count < numberOfVelocities {
      velocities.append(velocity)
      return
    } else {
      velocities = Array(velocities.dropFirst())
      velocities.append(velocity)
    }

    /// Enforce minimum velocity and offset.
    if abs(velocity) > 100 || abs(offset) < 50 { return }

    guard let firstRecordedVelocity = velocities.first else { return }

    /// If the majority of the velocity has been lost recetly, we consider the
    /// motion to be paused
    if abs(firstRecordedVelocity - velocity) / abs(firstRecordedVelocity) >
      0.9 {
      hasPaused = true
      velocities.removeAll()
    }
  }
}

private extension Color {
  static let topColor = Color(red: 0.39, green: 1.00, blue: 0.56)
  static let bottomColor = Color(red: 0.32, green: 1.00, blue: 0.92)
}

// MARK: - AccelerationPausingView_Previews

struct AccelerationPausingView_Previews: PreviewProvider {
  static var previews: some View {
    AccelerationPausingView()
  }
}
