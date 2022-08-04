//
//  ManualSteering.swift
//  RTRemote
//
//  Created by Stefan Walser on 03.08.22.
//

import SwiftUI

struct ManualSteering: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("Left Track").fontWeight(.bold)
                    Text("\(Int(viewModel.sliderValueLeft)) RPM")
                }
                Spacer()
                VStack {
                    Text("Right Track").fontWeight(.bold)
                    Text("\(Int(viewModel.sliderValueRight)) RPM")
                }
            }.padding()
            
            Spacer()
            
            HStack {
                MySlider(sliderValue: $viewModel.sliderValueLeft, limit: sliderLimit())
                    .padding()
                
                MySlider(sliderValue: $viewModel.sliderValueRight, limit: sliderLimit())
                    .padding()
            }.padding(.top)
            .padding(.bottom)
        }.navigationTitle("HTTP Manuell")
            .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.platformModeLocal = .HTTPManual
        }
        .onDisappear {
            viewModel.platformModeLocal = .None
        }
    }
    
    private func sliderLimit() -> Double {
        Double(viewModel.RPMRange)
    }
}

struct ManualSteering_Previews: PreviewProvider {
    static var previews: some View {
        ManualSteering().environmentObject(ViewModel())
    }
}
