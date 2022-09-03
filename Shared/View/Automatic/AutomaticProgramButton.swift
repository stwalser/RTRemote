//
//  AutomaticProgram.swift
//  RTRemote
//
//  Created by Stefan Walser on 27.07.22.
//

import SwiftUI

struct AutomaticProgramButton: View {
    let program: AutomaticProgram
    let buttonColor: Color
    
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            Button {
                viewModel.automaticProgramRunning = program
                viewModel.uploadAutomaticProgram(called: program)
                viewModel.connectToPlatformAutomatic()
            } label: {
                RoundedRectangle(cornerSize: .init(width: 20, height: 20))
                    .foregroundColor(buttonColor)
                    .opacity(getOpacity())
            }.disabled(checkIfDisabled())
                
            
            VStack {
                HStack {
                    Spacer()
                    
                    ButtonOrProgress(program: program).environmentObject(viewModel)
                }
                
                Spacer()
                
                Text(program.name ?? "Unknown")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(10)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                
            }
        }
    }
    
    func checkIfDisabled() -> Bool {
        viewModel.automaticProgramRunning != nil
    }
    
    func getOpacity() -> Double {
        if viewModel.automaticProgramRunning != nil {
            return 0.4
        } else {
            return 1.0
        }
    }
}
