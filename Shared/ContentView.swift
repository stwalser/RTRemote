//
//  ContentView.swift
//  Shared
//
//  Created by Stefan Walser on 07.04.21.
//

import SwiftUI

struct ContentView: View {
   
    var body: some View {
        Home(viewModel: ViewModel())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
