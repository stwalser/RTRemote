//
//  AutoProgramModification.swift
//  RTRemote
//
//  Created by Stefan Walser on 03.08.22.
//

import SwiftUI

struct AutoProgramModification: View {
    @State var values: [HighLevelInstruction]
    @Binding var showFlag: Bool
    
    init(showFlag: Binding<Bool>, highLevelInstructions: [HighLevelInstruction]) {
        self._showFlag = showFlag
        self._values = State(wrappedValue: highLevelInstructions)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach($values) { $instruction in
                    HStack {
                        Image(systemName: getImageName(inst: instruction))
                        Text(getTypeString(inst: instruction))
                        switch instruction.type {
                        case .turn:
                            TextField("", value: $instruction.degrees, formatter: NumberFormatter())
                        case .straightDistance:
                            TextField("", value: $instruction.distance, formatter: NumberFormatter())
                        case .straightTime:
                            TextField("", value: $instruction.duration, formatter: NumberFormatter())
                        }
                        Text(getEndingString(inst: instruction))
                    }.padding(10)
                        .background(.white)
                        .frame(height: 50)
                
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            addInstruction(type: .straightTime)
                        } label: {
                            Label("Geradeaus", systemImage: "timer")
                        }

                        Button {
                            addInstruction(type: .straightDistance)
                        } label: {
                            Label("Geradeaus", systemImage: "arrow.up")
                        }

                        Button {
                            addInstruction(type: .turn)
                        } label: {
                            Label("Drehen", systemImage: "arrow.clockwise")
                        }

                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItemGroup {
                    Button {
                        showFlag.toggle()
                    } label: {
                        Text("Fertig").bold()
                    }

                }
            }
        }
    }
    
    func addInstruction(type: DrivingType) {
        values.append(HighLevelInstruction(type: type))
    }
    
    func getImageName(inst: HighLevelInstruction) -> String {
        switch inst.type {
        case .turn:
            return "arrow.clockwise"
        case .straightDistance:
            return "arrow.up"
        case .straightTime:
            return "timer"
        }
    }
    
    func getTypeString(inst: HighLevelInstruction) -> String {
        switch inst.type {
        case .turn:
            return "Drehen"
        case .straightDistance:
            return "Geradeaus für"
        case .straightTime:
            return "Geradeaus für"
        }
    }
    
    func getEndingString(inst: HighLevelInstruction) -> String {
        switch inst.type {
        case .turn:
            return ""
        case .straightDistance:
            return "Meter"
        case .straightTime:
            return "Sekunden"
        }
    }
}
