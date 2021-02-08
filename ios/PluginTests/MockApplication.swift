//
//  MockApplication.swift
//  PluginTests
//
//  Created by Swaminathan on 28/01/21.
//  Copyright © 2021 Max Lynch. All rights reserved.
//

import Foundation
@testable import Plugin

class MockApplication: UIApplicationProtocol {
    var endBackgroundTaskCalled = false
    var beginBackgroundTaskCalled = false
    
    var mockReturnId: UIBackgroundTaskIdentifier = .invalid
    
    func beginBackgroundTask(expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier {
        beginBackgroundTaskCalled = true
        return mockReturnId
    }
    
    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier) {
        endBackgroundTaskCalled = true
    }
}
