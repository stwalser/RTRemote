//
//  AutomaticProgram.swift
//  RTRemote
//
//  Created by Stefan Walser on 27.07.22.
//

import Foundation

struct AutomaticProgram: Identifiable, Equatable {
    let id = UUID()
    let creationDate: Date
    
    var name: String
    var stringContent: String
}
