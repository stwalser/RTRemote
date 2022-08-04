//
//  Slider.swift
//  RTRemote
//
//  Created by Stefan Walser on 13.04.21.
//

import SwiftUI

struct MySlider: View {
    @Binding var sliderValue: Double
    
    let limit: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Rectangle()
                    .foregroundColor(.gray)
                    .cornerRadius(20)
                    .frame(width: geometry.size.width / 6, height: geometry.size.height)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                Circle()
                    .foregroundColor(.accentColor)
                    .frame(width: geometry.size.width / 3, alignment: .center)
                    .position(x: geometry.size.width / 2, y: calcHeight(for: geometry.size.height))
                Circle()
                    .foregroundColor(.white)
                    .frame(width: geometry.size.width / 5, alignment: .center)
                    .position(x: geometry.size.width / 2, y: calcHeight(for: geometry.size.height))
            }.gesture(DragGesture(minimumDistance: 2)
                        .onChanged { value in
                            self.sliderValue = min(max(-1, Double((geometry.size.height - 2 * value.location.y) / geometry.size.height)), 1) * limit
                        }.onEnded { value in
                            self.sliderValue = 0.0
                        }
            )
        }
    }
    
    private func calcHeight(for height: CGFloat) -> CGFloat {
        (height / 2) - ((CGFloat(sliderValue) / CGFloat(limit)) * (height / 2))
    }
}
