//
//  FormatedNumView.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 6/3/21.
//

import SwiftUI

// MARK: - FormatedNumView

/// A `Text` showing a formatted `CGFloat`, with an animated digit roll on change.
///
/// The original used `.animation(nil)` to suppress jitter. With
/// `contentTransition(.numericText())` the value now rolls smoothly, gated by a
/// value-based `.animation(_:value:)`.
struct FormatedNumView: View {
  @Binding var num: CGFloat

  var body: some View {
    Text("\(num, specifier: "%.2f")")
      .font(.system(.body).monospacedDigit().bold())
      .contentTransition(.numericText(value: num))
      .animation(.smooth, value: num)
  }
}

// MARK: - Previews

#Preview {
  @Previewable @State var num: CGFloat = 89.64
  return VStack {
    FormatedNumView(num: $num)
    Button("Randomize") {
      num = CGFloat.random(in: 0...100)
    }
  }
  .padding()
}
