//
//  ConnectionManager.swift
//  RTRemote
//
//  Created by Stefan Walser on 08.04.21.
//

import Foundation
import Combine

fileprivate let platformHostname = "10.0.0.17:8080"
fileprivate let modeURL = URL(string: "http://\(platformHostname)/mode")!
fileprivate let connectURL = URL(string: "ws://\(platformHostname)/connect")!
fileprivate let statusURL = URL(string: "http://\(platformHostname)/status")!

/// This class is the connection between the view and the logic of the app. It contains the variables that can affect the view and functions which the view uses to access the model.
class ViewModel: ObservableObject {
    @Published var numberOfSentMessages = 0
    @Published var sliderValueLeft = 0.0
    @Published var sliderValueRight = 0.0
    @Published var platformModeLocal = PlatformMode.None
    @Published var platformReachableHTTP = false
    @Published var platformReachableBluetooth = false
    @Published var platformReachabilityIcon: String = "line.diagonal"
    @Published var webSocketConnected = false
    
    let RPMRange = 250
    
    private var sliderValueCancellable: (left: AnyCancellable?, right: AnyCancellable?)
    private var modeCancellable: AnyCancellable?
    private var lastErrorCancellable: AnyCancellable?
    private var webSocketTask: URLSessionWebSocketTask?
    
    private let jsonEncoder = JSONEncoder()
    
    private func readMessage () {
        webSocketTask!.receive { [self] result in
            switch (result) {
            case .success(let message):
                print(message)
                readMessage()
            case .failure(let error):
                print("Error: \(error)")
                sendDisconnectWebSocket()
            }
        }
    }
        
    func sendConnectWebSocket() {
        webSocketTask = URLSession.shared.webSocketTask(with: connectURL)
        DispatchQueue.main.async { [self] in
            webSocketConnected = true
        }
        readMessage()
        webSocketTask!.resume()
    }
    
    func sendDisconnectWebSocket() {
        if let socket = webSocketTask {
            socket.cancel(with: .goingAway, reason: nil)
        }
        webSocketConnected = false
    }
    
    private func sendTargetWebSocket(at side: motorSide, _ value: Double) {
        guard webSocketConnected && webSocketTask != nil else {
            return
        }
        do {
            let data = try jsonEncoder.encode(Instruction(rpm: abs(value), dir: value >= 0 ? .forward : .backward, side: side))
            webSocketTask!.send(.data(data)) { error in
                if let error = error {
                    NSLog("Sending an Instruction to the platform failed. \(error)")
                }
            }
        } catch {
            print("Encoding an Instruction for target failed.")
        }
    }
    
    private func sendModeHTTP(_ value: PlatformMode) {
        if value != .HTTPManual {
            sendDisconnectWebSocket()
        }
        
        let dataString = value.rawValue
        var request = URLRequest(url: modeURL)
        
        request.httpMethod = "PUT"
        request.httpBody = dataString.data(using: .utf8)
        request.setValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("\(dataString.count)", forHTTPHeaderField: "Content-Length")
        
        let task = URLSession.shared.dataTask(with: request) { [self] _, urlRespone, _ in
            parseResponseStatus(response: urlRespone as? HTTPURLResponse)
            if value == .HTTPManual {
                sendConnectWebSocket()
            }
        }
        task.resume()
    }
    
    private func parseResponseStatus(response: HTTPURLResponse?) {
        DispatchQueue.main.async { [self] in
            if let response = response {
                if 200...299 ~= response.statusCode || response.statusCode == 406 {
                    platformReachableHTTP = true
                } else {
                    platformReachableHTTP = false
                }
            } else {
                platformReachableHTTP = false
            }
            getConnectionIcon()
        }
    }
    
    private func getConnectionIcon() {
        switch platformModeLocal {
        case .None:
            platformReachabilityIcon = "line.diagonal"
        case .Bluetooth:
            platformReachabilityIcon = "line.diagonal"
        case .HTTPManual:
            platformReachabilityIcon = platformReachableHTTP ? "wifi" : "wifi.slash"
        case .HTTPAutomatic:
            platformReachabilityIcon = platformReachableHTTP ? "wifi" : "wifi.slash"
        }
    }
    
    /// This initilaizer subscribes to both slider value bindings. Every time the slider value changes, the updateInstructions function will be called.
    init() {
        sliderValueCancellable.left = $sliderValueLeft.sink { [self] value in
            if platformModeLocal == .HTTPManual {
                sendTargetWebSocket(at: .left, value)
            }
        }
        
        sliderValueCancellable.right = $sliderValueRight.sink { [self] value in
            if platformModeLocal == .HTTPManual {
                sendTargetWebSocket(at: .right, value)
            }
        }
        
        modeCancellable = $platformModeLocal.sink(receiveValue: { [self] value in
            sendModeHTTP(value)
        })
    }
}

/// Two different motors
enum motorSide: Int, Codable {
    case left
    case right
}

/// The direction the motor should turn in
enum motorDirection: Int, Codable {
    case forward
    case backward
}

/// The mode in which the platform is in
enum PlatformMode: String, Codable {
    case None
    case Bluetooth
    case HTTPManual
    case HTTPAutomatic
}

/// A struct representing a manual driving instruction
struct Instruction: Codable {
    var rpm: Double
    var dir: motorDirection
    var side: motorSide
}

/// A struct representing the infromation the platform can send
struct Status: Codable {
    var faultLeft: Int
    var faultRight: Int
    var currentTargetLeft: Instruction?
    var currentTargetRight: Instruction?
    var currentInstructionLeft: Instruction
    var currentInstructionRight: Instruction
    var mode: PlatformMode
    var targetMessageID: Int
}
