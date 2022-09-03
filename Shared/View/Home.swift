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
        NavigationView {
            List {
                Section("Controls") {
                    NavigationLink {
                        ManualSteering().environmentObject(viewModel)
                    } label: {
                        Text("Manual HTTP")
                    }
                    .disabled(!viewModel.platformReachableHTTP)
                    
                    NavigationLink {
                        ManualSteering().environmentObject(viewModel)
                    } label: {
                        Text("Manual Bluetooth")
                    }.disabled(true)
                    
                    NavigationLink {
                        AutomaticSteering().environmentObject(viewModel)
                    } label: {
                        Text("Automatic HTTP")
                    }
                    .disabled(!viewModel.platformReachableHTTP)
                }
                
                Section("Platform Status") {
                    HStack {
                        Text("Platform Reachable HTTP")
                        Spacer()
                        Image(systemName: "dot.square").foregroundColor(reachabilityColor())
                    }
                    
                    HStack {
                        Text("Fault Pin Left")
                        Spacer()
                        Image(systemName: "dot.square").foregroundColor(faultPinImageColor())
                    }.foregroundColor(reachabilityTextColor())
                    
                    HStack {
                        Text("Fault Pin Right")
                        Spacer()
                        Image(systemName: "dot.square").foregroundColor(faultPinImageColor())
                    }.foregroundColor(reachabilityTextColor())
                }
            }.navigationTitle(Text("RTPlatform Remote"))
        }
    }
    
    func faultPinImageColor() -> Color {
        if viewModel.platformReachableHTTP {
            if let status = viewModel.platformStatus {
                return status.faultLeft == 0 ? .green : .red
            }
            return .gray
        }
        return .gray
    }
    
    func reachabilityColor() -> Color {
        viewModel.platformReachableHTTP ? .green : .red
    }
    
    func reachabilityTextColor() -> Color {
        viewModel.platformReachableHTTP ? .black : .gray
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Home(viewModel: ViewModel())
        }
    }
}
