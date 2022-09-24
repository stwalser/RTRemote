//
//  AutomaticProgramCommand.swift
//  RTRemote
//
//  Created by Stefan Walser on 24.09.22.
//

import Foundation

struct HighLevelInstruction: Identifiable, Equatable {
    var id: UUID = UUID()
    
    init(type: DrivingType) {
        self.type = type
    }
    
    init(type: DrivingType, duration: TimeInterval, direction: MotorDirection) {
        self.type = type
        self.duration = duration
        self.direction = direction
    }
    
    init(type: DrivingType, distance: Double, direction: MotorDirection) {
        self.type = type
        self.distance = distance
        self.direction = direction
    }
    
    init(type: DrivingType, degrees: Double) {
        self.type = type
        self.degrees = degrees
    }
    
    var type: DrivingType
    var duration: TimeInterval?
    var degrees: Double?
    var direction: MotorDirection?
    var distance: Double?
}

enum DrivingType: String {
    case straightTime
    case straightDistance
    case turn
}
