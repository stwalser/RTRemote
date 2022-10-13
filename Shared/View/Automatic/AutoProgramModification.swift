//
//  AutoProgramModification.swift
//  RTRemote
//
//  Created by Stefan Walser on 03.08.22.
//

import SwiftUI

struct AutoProgramModification: View {
    @Binding var values: [HighLevelInstruction]
    @Binding var showFlag: Bool
    @Binding var name: String
    
    @State var showRenameAlert: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach($values) { $instruction in
                    HStack {
                        Image(systemName: getImageName(inst: instruction))
                        Text(getTypeString(inst: instruction))
                        TextField("", text: $instruction.value ?? "")
                            .padding(1)
                            .background(Color(UIColor.lightGray))
                            .cornerRadius(5.0)
                            .frame(maxWidth: 50.0)
                        Text(getEndingString(inst: instruction))
                        
                        if instruction.type != .turn {
                            Picker("", selection: $instruction.direction) {
                                ForEach(MotorDirection.allCases) {
                                    Text($0.rawValue).tag($0 as MotorDirection?)
                                }
                            }
                        }
                    }.padding(10)
                        .background(.white)
                        .frame(height: 50)
                }.onDelete { indexSet in
                    values.remove(atOffsets: indexSet)
                }.onMove { indexSet, offset in
                    values.move(fromOffsets: indexSet, toOffset: offset)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            addInstruction(type: .straightTime)
                        } label: {
                            Label("Gerade", systemImage: "timer")
                        }
                        
                        Button {
                            addInstruction(type: .straightDistance)
                        } label: {
                            Label("Gerade", systemImage: "arrow.up")
                        }
                        
                        Button {
                            addInstruction(type: .turn)
                        } label: {
                            Label("Drehen", systemImage: "arrow.clockwise")
                        }
                        
                    } label: {
                        Image(systemName: "plus")
                    }
                    
                    EditButton()
                }
                
                ToolbarItemGroup(placement: .principal) {
                    Text(name).bold()                    
                }
                
                ToolbarItemGroup {
                    Menu {
                        Button {
                            showRenameAlert = true
                        } label: {
                            Label("Umbenennen", systemImage: "pencil")
                        }
                    } label: {
                        Image(systemName: "chevron.down.circle")
                    }
                    
                    Button {
                        showFlag.toggle()
                    } label: {
                        Text("Fertig").bold()
                    }
                    
                }
            }
            .alert("Programm umbenennen", isPresented: $showRenameAlert) {
                TextField("", text: $name)
                
                Button("Fertig", action: {
                    showRenameAlert = false
                })
                Button("Abbrechen", role: .cancel, action: {})
            }
        }
    }
    
    func addInstruction(type: DrivingType) {
        values.append(HighLevelInstruction(type: type, value: "0.0", direction: .forward))
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
            return "Drehen um"
        default:
            return ""
        }
    }
    
    func getEndingString(inst: HighLevelInstruction) -> String {
        switch inst.type {
        case .turn:
            return "Grad"
        case .straightDistance:
            return "Meter"
        case .straightTime:
            return "Sekunden"
        }
    }
}

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
