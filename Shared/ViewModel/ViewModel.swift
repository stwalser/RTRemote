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
    @Published var numberOfSentMessages = 0
    @Published var sliderValueLeft = 0.0
    @Published var sliderValueRight = 0.0
    @Published var platformModeLocal = PlatformMode.None
    @Published var platformReachableHTTP = false
    @Published var platformReachableBluetooth = false
    @Published var webSocketConnected = false
    
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
            changePlatformMode(to: $0)
        }
    }
    
    // MARK: - Actions
    func connectToPlatform() {
        httpCommunication.webSocketTask = URLSession.shared.webSocketTask(with: httpCommunication.connectURL)
        DispatchQueue.main.async { [self] in
            webSocketConnected = true
        }
        setOneTimeReceiveHandler()
        httpCommunication.webSocketTask!.resume()
    }
    
    func disconnectFromPlatform() {
        if let socket = httpCommunication.webSocketTask {
            socket.cancel(with: .goingAway, reason: nil)
        }
        httpCommunication.webSocketTask = nil
        DispatchQueue.main.async { [self] in
            webSocketConnected = false
        }
    }
    
    private func changePlatformMode(to mode: PlatformMode) {
        if mode != .HTTPManual {
            disconnectFromPlatform()
        }
        
        sendModeRequest(mode)
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
    
    private func setOneTimeReceiveHandler () {
        httpCommunication.webSocketTask!.receive { [self] result in
            switch (result) {
            case .success(_):
                setOneTimeReceiveHandler()
            case .failure(let error):
                NSLog("Error: \(error)")
                disconnectFromPlatform()
            }
        }
    }
    
    private func sendModeRequest(_ value: PlatformMode) {
        let task = URLSession.shared.dataTask(with: httpCommunication.request(value)) { [self] _, urlRespone, _ in
            parseResponseStatus(response: urlRespone as? HTTPURLResponse)
            
            if value == .HTTPManual {
                connectToPlatform()
            }
        }
        task.resume()
    }
}
