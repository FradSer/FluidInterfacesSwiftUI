//
//  AccelerationPausingView.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 6/2/21.
//

import SwiftUI

// MARK: - AccelerationPausingView

/// To view the app switcher on iPhone X, the user swipes up from the bottom
/// and pauses midway. This interface re-creates that behavior.
///
/// # Key Features
///
/// 1. The pause is calculated from the gesture's acceleration.
/// 2. Faster stopping results in a faster response.
/// 3. No timers.
///
/// # Design Theory
///
/// Fluid interfaces should be fast. A delay from a timer, even if short, makes
/// an interface feel sluggish. This interface is cool because its reaction time
/// is based on the user's motion: a quick pause → quick response; a slow pause
/// → slow response.
///
/// # iOS 26 Approach
///
/// `DragGesture` still does not expose per-frame velocity (only the end-of-gesture
/// `predictedEndLocation`), so the sliding-window pause heuristic is retained.
/// The view is rebuilt around `containerRelativeFrame`/`frame(maxWidth:)` instead
/// of `UIScreen.main`, snaps back with a value-based `.spring(.snappy)`, and
/// debug numbers flow through `FormatedNumView` (numericText). The duplicated
/// `withAnimation` block in the original `.onEnded` is removed.
///
/// # References
///
/// - [Building Fluid Interfaces](https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5)
/// - [Calculate velocity of DragGesture](https://stackoverflow.com/questions/57222885/calculate-velocity-of-draggesture)

struct AccelerationPausingView: View {
  var body: some View {
    content
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(MeshBackgroundView())
      #if os(iOS)
        .ignoresSafeArea()
      #endif
  }

  #if !os(tvOS)
    private var content: some View {
      ZStack {
        DebugView(
          currentVelocityY: $currentVelocity.height,
          currentOffsetY: $currentPosition.height
        )
        VStack(spacing: 12) {
          if hasPaused {
            Text("Paused")
              .font(.caption.weight(.bold))
              .textCase(.uppercase)
              .foregroundStyle(.green)
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .background(.quaternary, in: Capsule())
              .transition(.scale.combined(with: .opacity))
          }
          RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(
              LinearGradient(
                colors: [.accelerationTop, .accelerationBottom],
                startPoint: .top,
                endPoint: .bottom
              )
            )
            .frame(width: 120, height: 120)
            #if !os(tvOS)
              .glassEffect(.regular, in: .rect(cornerRadius: 32))
            #endif
            .offset(y: currentPosition.height)
            .gesture(drag)
        }
      }
    }

    private var drag: some Gesture {
      DragGesture()
        .onChanged { value in
          let offset = resistedOffset(value.translation.height)
          currentPosition = CGSize(
            width: value.translation.width + newPosition.width,
            height: offset + newPosition.height
          )
          currentVelocity = CGSize(
            width: value.predictedEndLocation.x - value.location.x,
            height: value.predictedEndLocation.y - value.location.y
          )
          trackPause(velocity: currentVelocity.height, offset: offset)
        }
        .onEnded { _ in
          hasPaused = false
          withAnimation(.spring(.snappy)) {
            currentPosition = .zero
            newPosition = .zero
          }
        }
    }
  #else
    private var content: some View {
      Text("Acceleration pausing requires a drag gesture, which is not available on tvOS.")
        .foregroundStyle(.secondary)
        .padding()
    }
  #endif

  // MARK: Private

  private struct DebugView: View {
    @Binding var currentVelocityY: CGFloat
    @Binding var currentOffsetY: CGFloat

    var body: some View {
      VStack(spacing: 12) {
        HStack {
          Text("Last Velocity")
            .font(.subheadline)
            .foregroundStyle(.secondary)
          Spacer()
          FormatedNumView(num: abs(currentVelocityY))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.quaternary, in: Capsule())
        }
        Divider()
        HStack {
          Text("Current Offset")
            .font(.subheadline)
            .foregroundStyle(.secondary)
          Spacer()
          FormatedNumView(num: currentOffsetY == 0 ? 0 : -currentOffsetY)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.quaternary, in: Capsule())
        }
      }
      .padding(16)
      .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
      .overlay {
        RoundedRectangle(cornerRadius: 16)
          .strokeBorder(.separator, lineWidth: 1)
      }
      .padding()
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
  }

  private let verticalOffset: CGFloat = 180
  private let numberOfVelocities = 7

  @State private var velocities = [CGFloat]()
  @State private var hasPaused = false
  @State private var currentVelocity: CGSize = .zero
  @State private var currentPosition: CGSize = .zero
  @State private var newPosition: CGSize = .zero

  /// Apply rubberbanding resistance to the raw drag translation.
  private func resistedOffset(_ translation: CGFloat) -> CGFloat {
    if translation > 0 {
      return pow(translation, 0.7)
    } else if translation < -verticalOffset * 2 {
      return -verticalOffset * 2 - pow(-(translation + verticalOffset * 2), 0.7)
    }
    return translation
  }

  /// Tracks recent velocities and decides whether the motion has paused.
  private func trackPause(velocity: CGFloat, offset: CGFloat) {
    if hasPaused { return }

    if velocities.count < numberOfVelocities {
      velocities.append(velocity)
      return
    } else {
      velocities.removeFirst()
      velocities.append(velocity)
    }

    if abs(velocity) > 100 || abs(offset) < 50 { return }

    guard let firstRecordedVelocity = velocities.first,
      abs(firstRecordedVelocity) > 1.0
    else { return }

    if abs(firstRecordedVelocity - velocity) / abs(firstRecordedVelocity) > 0.9 {
      hasPaused = true
      velocities.removeAll()
    }
  }
}

// MARK: - Previews

#Preview {
  AccelerationPausingView()
}
