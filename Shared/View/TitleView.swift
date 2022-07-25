//
//  TitleView.swift
//  RTRemote
//
//  Created by Stefan Walser on 02.06.21.
//

import SwiftUI

struct TitleView: View {
    var body: some View {
        HStack {
            Text("RTPlatform Remote")
                .font(.title)
                .fontWeight(.bold)
                .padding(.leading, 20)
            Spacer()
        }
        .padding()
    }
}
