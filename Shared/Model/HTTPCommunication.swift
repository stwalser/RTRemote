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
    private let jsonDecoder = JSONDecoder()
    
    let modeURL: URL
    let connectURL: URL
    let statusURL: URL
    let uploadProgramURL: URL
    let startProgramURL: URL
    
    var webSocketTask: URLSessionWebSocketTask?
    
    init() {
        modeURL = URL(string: "http://\(platformHostname)/mode")!
        connectURL = URL(string: "ws://\(platformHostname)/connect")!
        statusURL = URL(string: "http://\(platformHostname)/status")!
        uploadProgramURL = URL(string: "http://\(platformHostname)/auto/program")!
        startProgramURL = URL(string: "ws://\(platformHostname)/auto/start")!
    }
    
    func requestPlain(to url: URL, _ value: PlatformMode) -> URLRequest {
        let dataString = value.rawValue
        var request = URLRequest(url: url)
        
        request.httpMethod = "PUT"
        request.httpBody = dataString.data(using: .utf8)
        request.setValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("\(dataString.count)", forHTTPHeaderField: "Content-Length")
        
        return request
    }
    
    func requestJSON(to url: URL, _ value: String) -> URLRequest {
        var request = URLRequest(url: url)
        
        request.httpMethod = "PUT"
        request.httpBody = value.data(using: .utf8)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("\(value.count)", forHTTPHeaderField: "Content-Length")
        
        return request
    }
    
    func encodeData(_ rpm: Double, _ side: MotorSide) throws -> Data {
        try jsonEncoder.encode(Instruction(rpm: abs(rpm), dir: rpm >= 0 ? .forward : .backward, side: side))
    }
    
    func decodeStatus(data: Data) throws -> Status {
        try jsonDecoder.decode(Status.self, from: data)
    }
}
