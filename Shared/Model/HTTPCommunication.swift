//
//  HTTPCommunication.swift
//  RTRemote
//
//  Created by Stefan Walser on 26.07.22.
//

import Foundation

struct HTTPCommunication {
    private let platformHostname = "10.0.0.17:8080"
    private let jsonEncoder = JSONEncoder()
    
    let modeURL: URL
    let connectURL: URL
    let statusURL: URL
    
    var webSocketTask: URLSessionWebSocketTask?
    
    init() {
        modeURL = URL(string: "http://\(platformHostname)/mode")!
        connectURL = URL(string: "ws://\(platformHostname)/connect")!
        statusURL = URL(string: "http://\(platformHostname)/status")!
    }
    
    func request(_ value: PlatformMode) -> URLRequest {
        let dataString = value.rawValue
        var request = URLRequest(url: modeURL)
        
        request.httpMethod = "PUT"
        request.httpBody = dataString.data(using: .utf8)
        request.setValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("\(dataString.count)", forHTTPHeaderField: "Content-Length")
        
        return request
    }
    
    func encodeData(_ rpm: Double, _ side: MotorSide) throws -> Data {
        try jsonEncoder.encode(Instruction(rpm: abs(rpm), dir: rpm >= 0 ? .forward : .backward, side: side))
    }
}
