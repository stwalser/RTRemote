//
//  ButtonOrProgress.swift
//  RTRemote
//
//  Created by Stefan Walser on 03.08.22.
//

import SwiftUI

struct ButtonOrProgress: View {
    @State var showProgramModification = false
    @EnvironmentObject var viewModel: ViewModel
    @State var highLevelInstructions: [HighLevelInstruction]
    @State var programName: String
    
    init(showProgramModification: Bool = false, program: AutomaticProgram) {
        self.showProgramModification = showProgramModification
        self.program = program
        self.highLevelInstructions = getInstructions(from: program.content)
        self.programName = program.name ?? ""
    }
    
    let buttonSize: CGFloat = 22.0
    let program: AutomaticProgram
    
    var body: some View {
        if viewModel.automaticProgramRunning == nil || viewModel.automaticProgramRunning != program {
            Button {
                showProgramModification.toggle()
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .resizable()
                    .frame(width: buttonSize, height: buttonSize)
                    .foregroundColor(.white)
                    .padding(10)
            }.fullScreenCover(isPresented: $showProgramModification, onDismiss: {
                print(highLevelInstructions)
                program.content = getData(from: highLevelInstructions)
                program.name = programName
            }) {
                AutoProgramModification(values: $highLevelInstructions, showFlag: $showProgramModification, name: $programName)
            }.disabled(viewModel.automaticProgramRunning != nil)
        } else {
            Button {
                viewModel.disconnectFromPlatform()
            } label: {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 3)
                        .opacity(0.1)
                        .foregroundColor(.black)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(min(viewModel.automaticProgramRunProgress, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.black)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear, value: viewModel.automaticProgramRunProgress)
                    
                    Image(systemName: "stop.fill")
                        .resizable()
                        .frame(width: buttonSize - 12, height: buttonSize - 12)
                        .foregroundColor(.white)

                }
            }.frame(width: buttonSize, height: buttonSize)
            .padding(10)
        }
    }
}

func getInstructions(from d: Data?) -> [HighLevelInstruction] {
    do {
        return try JSONDecoder().decode([HighLevelInstruction].self, from: d ?? Data())
    } catch {
        return [HighLevelInstruction]()
    }
    
}

func getData(from a: [HighLevelInstruction]) -> Data {
    do {
        return try JSONEncoder().encode(a)
    } catch {
        return Data()
    }
}
