//
//  ContentView.swift
//  Shared
//
//  Created by Frad LEE on 5/27/21.
//

import SwiftUI

// MARK: - Demo

/// The seven fluid-interface demos, type-driven so routing cannot drift from
/// the case set. Icons are SF Symbols (auto-theming, no image assets).
enum Demo: String, CaseIterable, Identifiable {
  case calculator
  case spring
  case flashlight
  case rubberbanding
  case accelerationPausing
  case rewardingMomentum
  case faceTimePiP

  var id: String { rawValue }

  var title: String {
    switch self {
    case .calculator: "Calculator Button"
    case .spring: "Spring Animations"
    case .flashlight: "Flashlight Button"
    case .rubberbanding: "Rubberbanding"
    case .accelerationPausing: "Acceleration Pausing"
    case .rewardingMomentum: "Rewarding Momentum"
    case .faceTimePiP: "FaceTime PiP"
    }
  }

  var symbolName: String {
    switch self {
    case .calculator: "plus.square"
    case .spring: "waveform"
    case .flashlight: "flashlight.on.fill"
    case .rubberbanding: "arrow.up.and.down.and.arrow.left.and.right"
    case .accelerationPausing: "speedometer"
    case .rewardingMomentum: "rectangle.stack"
    case .faceTimePiP: "pip"
    }
  }

  @ViewBuilder
  @MainActor var destination: some View {
    switch self {
    case .calculator: CalculatorButtonView()
    case .spring: SpringAnimationsView()
    case .flashlight: FlashlightButtonView()
    case .rubberbanding: RubberbandingView()
    case .accelerationPausing: AccelerationPausingView()
    case .rewardingMomentum: RewardingMomentumView()
    case .faceTimePiP: FaceTimePiPView()
    }
  }
}

// MARK: - ContentView

struct ContentView: View {
  @State private var path: [Demo] = []

  var body: some View {
    NavigationStack(path: $path) {
      List(Demo.allCases) { demo in
        NavigationLink(value: demo) {
          HStack(spacing: 16) {
            Image(systemName: demo.symbolName)
              .font(.headline)
              .frame(width: 32, height: 32)
              .foregroundStyle(.tint)
              .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            Text(demo.title)
              .font(.body.weight(.medium))
          }
          .padding(.vertical, 4)
        }
      }
      #if os(iOS)
        .listStyle(.insetGrouped)
      #else
        .listStyle(.sidebar)
      #endif
      .background(MeshBackgroundView().ignoresSafeArea())
      .scrollContentBackground(.hidden)
      .navigationTitle("Fluid Interfaces")
      #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
      #endif
      .navigationDestination(for: Demo.self) { demo in
        demo.destination
          #if !os(macOS)
            .navigationTitle(demo.title)
            .navigationBarTitleDisplayMode(.inline)
          #endif
      }
    }
  }
}

// MARK: - Previews

#Preview {
  ContentView()
    .preferredColorScheme(.dark)
}
