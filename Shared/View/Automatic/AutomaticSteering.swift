//
//  AutomaticSteering.swift
//  RTRemote
//
//  Created by Stefan Walser on 04.08.22.
//

import SwiftUI

struct AutomaticSteering: View {
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: Int(UIScreen.main.bounds.width) / 160)

    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.creationDate)]) var automaticPrograms: FetchedResults<AutomaticProgram>
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(automaticPrograms) {program in
                    AutomaticProgramButton(program: program, buttonColor: .red).environmentObject(viewModel)
                        .contextMenu {
                            Button {
                                deleteAutomaticProgram(program)
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }

                        }
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
        .toolbar {
            Button {
                addNewAutomaticProgram()
            } label: {
                Image(systemName: "plus")
            }

        }
    }
    
    func addNewAutomaticProgram() {
        let program = AutomaticProgram(context: managedObjectContext)
        program.name = "Program"
        program.creationDate = .now
        program.stringContent = "Test"
        program.id = UUID()
        PersistenceController.shared.save()
    }
    
    func deleteAutomaticProgram(_ program: AutomaticProgram) {
        print(program)
        managedObjectContext.delete(program)
        PersistenceController.shared.save()
    }
}

struct AutomaticSteering_Previews: PreviewProvider {
    static var previews: some View {
        AutomaticSteering().environmentObject(ViewModel())
    }
}
