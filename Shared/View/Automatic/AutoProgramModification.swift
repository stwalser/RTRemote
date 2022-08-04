//
//  AutoProgramModification.swift
//  RTRemote
//
//  Created by Stefan Walser on 03.08.22.
//

import SwiftUI

struct AutoProgramModification: View {
    @Binding var showFlag: Bool

    var body: some View {
        NavigationView {
            Text("Henlo")
                .toolbar {
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
}

struct AutoProgramModification_Previews: PreviewProvider {
    @State static var isShowing = false
    
    static var previews: some View {
        AutoProgramModification(showFlag: $isShowing)
    }
}
