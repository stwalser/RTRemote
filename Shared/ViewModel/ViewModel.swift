//
//  ConnectionManager.swift
//  RTRemote
//
//  Created by Stefan Walser on 08.04.21.
//

import Foundation
import Combine

/// This class is the connection between the view and the logic of the app. It contains the variables that can affect the view and functions which the view uses to access the model.
class ViewModel: ObservableObject {
    // Manual steering
    @Published var sliderValueLeft = 0.0
    @Published var sliderValueRight = 0.0
    
    // HTTP variables
    @Published var platformModeLocal = PlatformMode.None
    @Published var platformReachableHTTP = false
    @Published var platformReachableBluetooth = false
    @Published var webSocketConnected = false
    
    // Automatic Program
    // @Published var automaticPrograms = [AutomaticProgram](arrayLiteral: AutomaticProgram(creationDate: .distantPast, name: "Short Time", stringContent: "[{\"type\":\"straightTime\",\"duration\":1.0,\"direction\":0},{\"type\":\"straightTime\",\"duration\":2.0,\"direction\":1}]"), AutomaticProgram(creationDate: .now, name: "Short Time 2", stringContent: "[{\"type\":\"straightTime\",\"duration\":1.0,\"direction\":0},{\"type\":\"straightTime\",\"duration\":2.0,\"direction\":1}]"))
    @Published var automaticProgramRunProgress = 0.0
    @Published var automaticProgramRunning: AutomaticProgram?
    

    @Published var platformStatus: Status?
    private var platformStatusTimer: Timer?
    private let intervalTime: TimeInterval = 4
    
    let RPMRange = 250
    
    private var sliderValueCancellable: (left: AnyCancellable?, right: AnyCancellable?)
    private var modeCancellable: AnyCancellable?
    private var httpCommunication = HTTPCommunication()
    
    /// This initilaizer subscribes to both slider value bindings. Every time the slider value changes, the updateInstructions function will be called.
    init() {
        sliderValueCancellable.left = $sliderValueLeft.sink { [self] in
            if platformModeLocal == .HTTPManual {
                sendTargetWebSocket(at: .left, $0)
            }
        }
        
        sliderValueCancellable.right = $sliderValueRight.sink { [self] in
            if platformModeLocal == .HTTPManual {
                sendTargetWebSocket(at: .right, $0)
            }
        }
        
        modeCancellable = $platformModeLocal.sink { [self] in
            sendModeRequest($0)
        }
        
        createTimer()
    }
    
    // MARK: - Actions
    func connectToPlatformAutomatic() {
        connectToPlatform(with: httpCommunication.startProgramURL, using: oneTimeReceiveHandlerProgress)
    }
    
    func disconnectFromPlatform() {
        if let socket = httpCommunication.webSocketTask {
            socket.cancel(with: .goingAway, reason: nil)
        }
        
        httpCommunication.webSocketTask = nil
        
        DispatchQueue.main.async { [self] in
            automaticProgramRunning = nil
            automaticProgramRunProgress = 0.0
            webSocketConnected = false
        }
    }
    
    func uploadAutomaticProgram(called program: AutomaticProgram) {
        print(program.content!)
        let task = URLSession.shared.dataTask(with: httpCommunication.requestJSON(to: httpCommunication.uploadProgramURL, program.content ?? Data())) { [self] _, urlRespone, _ in
            parseResponseStatus(response: urlRespone as? HTTPURLResponse)
        }
        task.resume()
    }
    
    // MARK: - HTTP helper functions
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
        }
    }
    
    private func sendTargetWebSocket(at side: MotorSide, _ value: Double) {
        guard webSocketConnected && httpCommunication.webSocketTask != nil else {
            return
        }
        do {
            httpCommunication.webSocketTask!.send(.data(try httpCommunication.encodeData(value, side))) { error in
                if let error = error {
                    NSLog("Sending an Instruction to the platform failed. \(error)")
                }
            }
        } catch {
            NSLog("Encoding an Instruction for target failed.")
        }
    }
    
    private func oneTimeReceiveHandlerNothing() {
        httpCommunication.webSocketTask!.receive { [self] result in
            switch (result) {
            case .success(_):
                oneTimeReceiveHandlerNothing()
            case .failure(let error):
                NSLog("Error: \(error)")
                disconnectFromPlatform()
            }
        }
    }
    
    private func oneTimeReceiveHandlerProgress() {
        httpCommunication.webSocketTask!.receive { [self] result in
            switch (result) {
            case .success(let message):
                print(message)
                switch message {
                case .string(let string):
                    DispatchQueue.main.async { [self] in
                        automaticProgramRunProgress = Double(string) ?? 0.0
                        print(automaticProgramRunProgress)
                    }
                default:
                    disconnectFromPlatform()
                }
                
                oneTimeReceiveHandlerProgress()
            case .failure(let error):
                NSLog("Error: \(error)")
                disconnectFromPlatform()
            }
        }
    }
    
    private func sendModeRequest(_ value: PlatformMode) {
        let task = URLSession.shared.dataTask(with: httpCommunication.requestPlain(to: httpCommunication.modeURL, value)) { [self] _, urlRespone, _ in
            parseResponseStatus(response: urlRespone as? HTTPURLResponse)
            
            if value == .HTTPManual {
                connectToPlatform(with: httpCommunication.connectURL, using: oneTimeReceiveHandlerNothing)
            } else {
                disconnectFromPlatform()
            }
        }
        task.resume()
    }
    
    private func connectToPlatform(with url: URL, using receiveHandler: () -> Void) {
        httpCommunication.webSocketTask = URLSession.shared.webSocketTask(with: url)
        
        DispatchQueue.main.async { [self] in
            webSocketConnected = true
        }
        
        receiveHandler()
        httpCommunication.webSocketTask!.resume()
    }
    
    private func getPlatformStatus() {
        let task = URLSession.shared.dataTask(with: httpCommunication.statusURL) { [self] data, response, error in
            let urlresponse = response as? HTTPURLResponse
            parseResponseStatus(response: urlresponse)
            
            if let res = urlresponse {
                if res.statusCode == 200 {
                    DispatchQueue.main.async { [self] in
                        platformStatus = try! httpCommunication.decodeStatus(data: data!)
                    }
                }
            }
        }
        task.resume()
    }
    
    private func createTimer() {
        platformStatusTimer = Timer.scheduledTimer(withTimeInterval: intervalTime, repeats: true) { [self] timer in
             getPlatformStatus()
        }
    }
}
