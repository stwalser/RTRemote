//
//  Modifiers.swift
//  RTRemote
//
//  Created by Stefan Walser on 31.05.21.
//

import SwiftUI

struct PaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(.leading).padding(.trailing)
    }
}

extension View {
    func defaultPadding() -> some View {
        self.modifier(PaddingModifier())
    }
}
