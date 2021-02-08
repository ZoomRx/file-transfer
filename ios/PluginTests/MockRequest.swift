//
//  MockRequest.swift
//  PluginTests
//
//  Created by Swaminathan on 25/01/21.
//  Copyright © 2021 Max Lynch. All rights reserved.
//

import Foundation
@testable import Alamofire

class MockRequest: Request {
    
    var cancelCalled = false
    var mockRequest: URLRequest?
    
    override init(id: UUID = UUID(), underlyingQueue: DispatchQueue = .main, serializationQueue: DispatchQueue = .main, eventMonitor: EventMonitor? = nil, interceptor: RequestInterceptor? = nil, delegate: RequestDelegate = MockRequestDelegate()) {

        super.init(id: id, underlyingQueue: underlyingQueue, serializationQueue: serializationQueue, eventMonitor: eventMonitor, interceptor: interceptor, delegate: delegate)
    }
    
    override func cancel() -> Self {
        cancelCalled = true
        return self
    }
    
    override var request: URLRequest? {
        get {
            return mockRequest
        }
        set {
            mockRequest = newValue
        }
    }
    
}

class MockRequestDelegate: RequestDelegate {
    var sessionConfiguration: URLSessionConfiguration
    
    var startImmediately: Bool
    
    init() {
        startImmediately = true
        sessionConfiguration = AF.sessionConfiguration
    }
    
    func cleanup(after request: Request) {
        // Mock Stub
    }
    
    func retryResult(for request: Request, dueTo error: AFError, completion: @escaping (RetryResult) -> Void) {
        // Mock Stub
    }
    
    func retryRequest(_ request: Request, withDelay timeDelay: TimeInterval?) {
        // Mock Stub
    }
    
    
}
