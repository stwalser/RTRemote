//
//  Home.swift
//  RTRemote
//
//  Created by Stefan Walser on 09.04.21.
//

import SwiftUI

struct Home: View {
    @StateObject var viewModel: ViewModel
        
    var body: some View {
        VStack {
            TitleView()
            
            HStack {
                Spacer()
                
                Button {
                    if viewModel.webSocketConnected {
                        viewModel.disconnectFromPlatform()
                    } else {
                        viewModel.connectToPlatform()
                    }
                } label: {
                    if viewModel.platformModeLocal == .HTTPManual {
                        if viewModel.webSocketConnected {
                            Text("Disconnect")
                        } else {
                            Text("Connect")
                        }
                    }
                }

                Spacer()
                
                Picker(selection: $viewModel.platformModeLocal, label: Text("Platform Mode")) {
                    Text("Choose a mode").tag(PlatformMode.None)
                    Text("Bluetooth").tag(PlatformMode.Bluetooth)
                    Text("HTTP Manual").tag(PlatformMode.HTTPManual)
                    Text("HTTP Automatic").tag(PlatformMode.HTTPAutomatic)
                }
                
                Spacer()
                
                Image(systemName: getConnectionIcon())
                
                Spacer()
            }
            
            
            Divider().modifier(PaddingModifier())
            
            if viewModel.platformModeLocal == .HTTPManual || viewModel.platformModeLocal == .Bluetooth {
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
                
                HStack {
                    MySlider(sliderValue: $viewModel.sliderValueLeft, limit: sliderLimit())
                        .padding()
                    
                    MySlider(sliderValue: $viewModel.sliderValueRight, limit: sliderLimit())
                        .padding()
                }.padding(.top).padding(.bottom)
            }
            
            Spacer()
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func sliderLimit() -> Double {
        Double(viewModel.RPMRange)
    }
    
    private func getConnectionIcon() -> String {
        switch viewModel.platformModeLocal {
        case .None:
            return "line.diagonal"
        case .Bluetooth:
            return "line.diagonal"
        case .HTTPManual:
            return viewModel.platformReachableHTTP ? "wifi" : "wifi.slash"
        case .HTTPAutomatic:
            return viewModel.platformReachableHTTP ? "wifi" : "wifi.slash"
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Home(viewModel: ViewModel())
        }
    }
}
