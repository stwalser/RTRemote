//
//  AutomaticSteering.swift
//  RTRemote
//
//  Created by Stefan Walser on 04.08.22.
//

import SwiftUI

struct AutomaticSteering: View {
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.automaticPrograms) {program in
                    AutomaticProgramButton(program: program, buttonColor: .red).environmentObject(viewModel)
                }
            }
            
        }.padding()
            .navigationTitle("Automatisch HTTP")
            .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.platformModeLocal = .HTTPAutomatic
        }
        .onDisappear {
            viewModel.platformModeLocal = .None
        }
    }
}

struct AutomaticSteering_Previews: PreviewProvider {
    static var previews: some View {
        AutomaticSteering().environmentObject(ViewModel())
    }
}
