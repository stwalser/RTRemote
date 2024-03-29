//
//  Platform.swift
//  RTRemote
//
//  Created by Stefan Walser on 27.07.22.
//

import Foundation

/// The mode in which the platform is in
enum PlatformMode: String, Codable {
    case None
    case Bluetooth
    case HTTPManual
    case HTTPAutomatic
}

/// Two different motors
enum MotorSide: Int, Codable {
    case left
    case right
}

/// The direction the motor should turn in
enum MotorDirection: String, Codable, CaseIterable, Identifiable {
    var id: MotorDirection {
        self
    }
    case forward = "Vorwärts"
    case backward = "Rückwärts"
}

/// A struct representing a manual driving instruction
struct Instruction: Codable {
    var rpm: Double
    var dir: MotorDirection
    var side: MotorSide
}

/// A struct representing the information the platform can send
struct Status: Codable {
    var faultLeft: Int
    var faultRight: Int
    var currentTargetLeft: Instruction?
    var currentTargetRight: Instruction?
    var currentInstructionLeft: Instruction
    var currentInstructionRight: Instruction
    var mode: PlatformMode
}
