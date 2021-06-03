//
//  FormatedNumView.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 6/3/21.
//

import SwiftUI

// MARK: - FormatedNumView

/// A `Text` returns with formated number (`CGFloat`).
struct FormatedNumView: View {
  @Binding var num: CGFloat

  var body: some View {
    Text("\(num, specifier: "%.2f")")
      .font(.system(.body).monospacedDigit().bold())
      .animation(nil)
  }
}

// MARK: - FormatedNumView_Previews

struct FormatedNumView_Previews: PreviewProvider {
  static var previews: some View {
    FormatedNumView(num: .constant(89.64))
  }
}
