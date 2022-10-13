//
//  AutomaticProgramCommand.swift
//  RTRemote
//
//  Created by Stefan Walser on 24.09.22.
//

import Foundation

struct HighLevelInstruction: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    
    init(type: DrivingType, direction: MotorDirection) {
        self.type = type
        self.direction = direction
    }
    
    init(type: DrivingType) {
        self.type = type
    }
    
    init(type: DrivingType, value: String, direction: MotorDirection) {
        self.type = type
        self.value = value
        self.direction = direction
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case direction
        case distance
        case degrees
        case duration
        case value
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(DrivingType.self, forKey: .type)
        direction = try values.decode(MotorDirection.self, forKey: .direction)
        distance = try values.decode(Double.self, forKey: .distance)
        degrees = try values.decode(Double.self, forKey: .degrees)
        duration = try values.decode(Double.self, forKey: .duration)
        value = try values.decode(String.self, forKey: .value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(direction, forKey: .direction)
        try container.encode(distance, forKey: .distance)
        try container.encode(degrees, forKey: .degrees)
        try container.encode(duration, forKey: .duration)
        try container.encode(value, forKey: .value)
    }
    
    var type: DrivingType
    var value: String?
    var direction: MotorDirection?
    
    
    var distance: Double? {
        get {
            Double(value ?? "0,0")
        }
        set {
        }
    }
    var duration: TimeInterval? {
        get {
            TimeInterval(value ?? "0,0")
        }
        set {
        }
    }
    var degrees: Double? {
        get {
            Double(value ?? "0,0")
        }
        set {
        }
    }
}

enum DrivingType: String, Codable {
    case straightTime
    case straightDistance
    case turn
}
