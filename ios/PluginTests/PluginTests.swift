import XCTest
import Capacitor
@testable import Plugin

enum ErrorMessages {
    static let successBlockShouldNotBeCalled = "Success Block Should Not Be Callled"
    static let errorBlockShouldNotBeCalled = "Error Block Should Not Be Callled"
    static let nilValueFound = "Value should not be nil"
    static let nilValueNotFound = "Value should be nil"
    static let rejectMessageNotEqual = "Reject message not equal"
    static let rejectCodeNotEqual = "Reject code not equal"
    static let rejectErrorObjectNotEqual = "Reject error object not equal"
    static let rejectDataNotEqual = "Reject data not equal"
}

enum MockError: Error {
    case sampleError
}

class PluginTests: XCTestCase {
    
    var sut: FileTransfer!
    var mockApplication: MockApplication!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockApplication = MockApplication()
        sut = FileTransfer()
        sut.application = mockApplication
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mockApplication = nil
        sut = nil
        super.tearDown()
    }
    
    /// Function to assert the data sent while rejecting the promise
    /// - Parameters:
    ///   - rejectError: The actual rejected error object
    ///   - expectedError: The expected rejected error object
    ///   - file: The file name from which this method is called
    ///   - line: The line number from which this method is called
    func assertRejectValues(of rejectError: CAPPluginCallError, against expectedError: CAPPluginCallError, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(rejectError.message, expectedError.message, ErrorMessages.rejectMessageNotEqual, file: file, line: line)
        XCTAssertEqual(rejectError.code, expectedError.code, ErrorMessages.rejectCodeNotEqual, file: file, line: line)
        XCTAssertEqual(rejectError.error as NSError?, expectedError.error as NSError?, ErrorMessages.rejectErrorObjectNotEqual, file: file, line: line)
        XCTAssertEqual(NSDictionary(dictionary: rejectError.data), NSDictionary(dictionary: expectedError.data), ErrorMessages.rejectDataNotEqual, file: file, line: line)
    }
    
    /*
     For download and upload functions only the early return cases are tested. This is because the library has added download(), upload() methods as extensions to those respective objects and that cant be overridden. Due to this we have not added test cases for download and upload cases.
    */
    
    /// To test download when ObjectID is not sent
    /// - Throws: Error
    func testDownloadWhenObjectIDIsNotSent() throws {
        //given
        var pluginResult: CAPPluginCallResult? = nil
        var pluginError: CAPPluginCallError? = nil
        
        var successBlockCalled = false
        let errorCompletion = expectation(description: "Call reject")
        
        let call = CAPPluginCall(callbackId: "testDownloadWhenObjectIDIsNotSent", options: [
            "NOT_ObjectId" : "1"
            ], success: { (result, _) in
                successBlockCalled = true
                pluginResult = result
        }) { (error) in
            errorCompletion.fulfill()
            pluginError = error
        }
        
        //when
        sut.download(call!)
        waitForExpectations(timeout: 2, handler: nil)
        
        //then
        XCTAssertFalse(successBlockCalled, ErrorMessages.successBlockShouldNotBeCalled)
        XCTAssertNil(pluginResult, ErrorMessages.nilValueNotFound)
        
        let error = try XCTUnwrap(pluginError)
        
        assertRejectValues(of: error, against: CAPPluginCallError(message: "Insufficient data", code: "1", error: nil, data: [:]))
        
    }
    
    /// To test download when src is not sent
    /// - Throws: Error
    func testDownloadWhenSrcIsNotSent() throws {
        //given
        var pluginResult: CAPPluginCallResult? = nil
        var pluginError: CAPPluginCallError? = nil
        
        var successBlockCalled = false
        let errorCompletion = expectation(description: "Call reject")
        
        let call = CAPPluginCall(callbackId: "testDownloadWhenSrcIsNotSent", options: [
            "NOT_Src" : "Src URL"
            ], success: { (result, _) in
                successBlockCalled = true
                pluginResult = result
        }) { (error) in
            errorCompletion.fulfill()
            pluginError = error
        }
        
        //when
        sut.download(call!)
        waitForExpectations(timeout: 2, handler: nil)
        
        //then
        XCTAssertFalse(successBlockCalled, ErrorMessages.successBlockShouldNotBeCalled)
        XCTAssertNil(pluginResult, ErrorMessages.nilValueNotFound)
        
        let error = try XCTUnwrap(pluginError)
        
        assertRejectValues(of: error, against: CAPPluginCallError(message: "Insufficient data", code: "1", error: nil, data: [:]))
        
    }
    
    /// To test download when destination is not sent
    /// - Throws: Error
    func testDownloadWhenDestinationIsNotSent() throws {
        //given
        var pluginResult: CAPPluginCallResult? = nil
        var pluginError: CAPPluginCallError? = nil
        
        var successBlockCalled = false
        let errorCompletion = expectation(description: "Call reject")
        
        let call = CAPPluginCall(callbackId: "testDownloadWhenDestinationIsNotSent", options: [
            "NOT_Destination" : "Destination URL"
            ], success: { (result, _) in
                successBlockCalled = true
                pluginResult = result
        }) { (error) in
            errorCompletion.fulfill()
            pluginError = error
        }
        
        //when
        sut.download(call!)
        waitForExpectations(timeout: 2, handler: nil)
        
        //then
        XCTAssertFalse(successBlockCalled, ErrorMessages.successBlockShouldNotBeCalled)
        XCTAssertNil(pluginResult, ErrorMessages.nilValueNotFound)
        
        let error = try XCTUnwrap(pluginError)
        
        assertRejectValues(of: error, against: CAPPluginCallError(message: "Insufficient data", code: "1", error: nil, data: [:]))
        
    }
    
    /// To test download when destination is not sent
    /// - Throws: Error
    func testDownloadWhenRequestAlreadyRunning() throws {
        //given
        let mockObjectID = "1"
        //Using fileURL as URL as that method does not return any optionals. As this is a mock path it does not affect any flow.
        let mockURL = URL(fileURLWithPath: "Mock server URL")
        let mockServerPath = mockURL.absoluteString
        let mockURLRequest = URLRequest(url: mockURL)
        let mockRequest = MockRequest()
        mockRequest.mockRequest = mockURLRequest
        
        sut.sessionTasks = [:] // Setting it to empty to avoid any discrepancies
        sut.sessionTasks[mockObjectID] = mockRequest
        
        var pluginResult: CAPPluginCallResult? = nil
        var pluginError: CAPPluginCallError? = nil
        
        var successBlockCalled = false
        let errorCompletion = expectation(description: "Call reject")
        
        let call = CAPPluginCall(callbackId: "testDownloadWhenRequestAlreadyRunning", options: [
            "objectId" : mockObjectID,
            "src" : mockServerPath,
            "destination" : "Destination URL"
            ], success: { (result, _) in
                successBlockCalled = true
                pluginResult = result
        }) { (error) in
            errorCompletion.fulfill()
            pluginError = error
        }
        
        //when
        sut.download(call!)
        waitForExpectations(timeout: 2, handler: nil)
        
        //then
        XCTAssertFalse(successBlockCalled, ErrorMessages.successBlockShouldNotBeCalled)
        XCTAssertNil(pluginResult, ErrorMessages.nilValueNotFound)
        
        let error = try XCTUnwrap(pluginError)
        
        assertRejectValues(of: error, against: CAPPluginCallError(message: "Request already running for the given src URL", code: "4", error: nil, data: [:]))
        
    }
    
    /// To test upload when ObjectID is not sent
    /// - Throws: Error
    func testUploadWhenObjectIDIsNotSent() throws {
        //given
        var pluginResult: CAPPluginCallResult? = nil
        var pluginError: CAPPluginCallError? = nil
        
        var successBlockCalled = false
        let errorCompletion = expectation(description: "Call reject")
        
        let call = CAPPluginCall(callbackId: "testUploadWhenObjectIDIsNotSent", options: [
            "NOT_ObjectId" : "1"
            ], success: { (result, _) in
                successBlockCalled = true
                pluginResult = result
        }) { (error) in
            errorCompletion.fulfill()
            pluginError = error
        }
        
        //when
        sut.upload(call!)
        waitForExpectations(timeout: 2, handler: nil)
        
        //then
        XCTAssertFalse(successBlockCalled, ErrorMessages.successBlockShouldNotBeCalled)
        XCTAssertNil(pluginResult, ErrorMessages.nilValueNotFound)
        
        let error = try XCTUnwrap(pluginError)
        
        assertRejectValues(of: error, against: CAPPluginCallError(message: "Insufficient data", code: "1", error: nil, data: [:]))
        
    }
    
    /// To test upload when src is not sent
    /// - Throws: Error
    func testUploadWhenSrcIsNotSent() throws {
        //given
        var pluginResult: CAPPluginCallResult? = nil
        var pluginError: CAPPluginCallError? = nil
        
        var successBlockCalled = false
        let errorCompletion = expectation(description: "Call reject")
        
        let call = CAPPluginCall(callbackId: "testUploadWhenSrcIsNotSent", options: [
            "NOT_Src" : "Src URL"
            ], success: { (result, _) in
                successBlockCalled = true
                pluginResult = result
        }) { (error) in
            errorCompletion.fulfill()
            pluginError = error
        }
        
        //when
        sut.upload(call!)
        waitForExpectations(timeout: 2, handler: nil)
        
        //then
        XCTAssertFalse(successBlockCalled, ErrorMessages.successBlockShouldNotBeCalled)
        XCTAssertNil(pluginResult, ErrorMessages.nilValueNotFound)
        
        let error = try XCTUnwrap(pluginError)
        
        assertRejectValues(of: error, against: CAPPluginCallError(message: "Insufficient data", code: "1", error: nil, data: [:]))
        
    }
    
    /// To test upload when destination is not sent
    /// - Throws: Error
    func testUploadWhenDestinationIsNotSent() throws {
        //given
        var pluginResult: CAPPluginCallResult? = nil
        var pluginError: CAPPluginCallError? = nil
        
        var successBlockCalled = false
        let errorCompletion = expectation(description: "Call reject")
        
        let call = CAPPluginCall(callbackId: "testUploadWhenDestinationIsNotSent", options: [
            "NOT_Destination" : "Destination URL"
            ], success: { (result, _) in
                successBlockCalled = true
                pluginResult = result
        }) { (error) in
            errorCompletion.fulfill()
            pluginError = error
        }
        
        //when
        sut.upload(call!)
        waitForExpectations(timeout: 2, handler: nil)
        
        //then
        XCTAssertFalse(successBlockCalled, ErrorMessages.successBlockShouldNotBeCalled)
        XCTAssertNil(pluginResult, ErrorMessages.nilValueNotFound)
        
        let error = try XCTUnwrap(pluginError)
        
        assertRejectValues(of: error, against: CAPPluginCallError(message: "Insufficient data", code: "1", error: nil, data: [:]))
        
    }
    
    /// To test upload when destination is not sent
    /// - Throws: Error
    func testUploadWhenRequestAlreadyRunning() throws {
        //given
        let mockObjectID = "1"
        //Using fileURL as URL as that method does not return any optionals. As this is a mock path it does not affect any flow.
        let mockURL = URL(fileURLWithPath: "Mock server URL")
        let mockServerPath = mockURL.absoluteString
        let mockURLRequest = URLRequest(url: mockURL)
        let mockRequest = MockRequest()
        mockRequest.mockRequest = mockURLRequest
        
        sut.sessionTasks = [:] // Setting it to empty to avoid any discrepancies
        sut.sessionTasks[mockObjectID] = mockRequest
        
        var pluginResult: CAPPluginCallResult? = nil
        var pluginError: CAPPluginCallError? = nil
        
        var successBlockCalled = false
        let errorCompletion = expectation(description: "Call reject")
        
        let call = CAPPluginCall(callbackId: "testUploadWhenRequestAlreadyRunning", options: [
            "objectId" : mockObjectID,
            "src" : "Mock Src URL",
            "destination" : mockServerPath
            ], success: { (result, _) in
                successBlockCalled = true
                pluginResult = result
        }) { (error) in
            errorCompletion.fulfill()
            pluginError = error
        }
        
        //when
        sut.upload(call!)
        waitForExpectations(timeout: 2, handler: nil)
        
        //then
        XCTAssertFalse(successBlockCalled, ErrorMessages.successBlockShouldNotBeCalled)
        XCTAssertNil(pluginResult, ErrorMessages.nilValueNotFound)
        
        let error = try XCTUnwrap(pluginError)
        
        assertRejectValues(of: error, against: CAPPluginCallError(message: "Request already running for the given src URL", code: "4", error: nil, data: [:]))
        
    }
    
    /// To test upload when file does not exist
    /// - Throws: Error
    func testUploadWhenFileDoesNotExists() throws {
        //given
        
        var pluginResult: CAPPluginCallResult? = nil
        var pluginError: CAPPluginCallError? = nil
        
        var successBlockCalled = false
        let errorCompletion = expectation(description: "Call reject")
        
        let call = CAPPluginCall(callbackId: "testUploadWhenRequestAlreadyRunning", options: [
            "objectId" : "1",
            "src" : "Mock Src URL",
            "destination" : "Mock Destination URL"
            ], success: { (result, _) in
                successBlockCalled = true
                pluginResult = result
        }) { (error) in
            errorCompletion.fulfill()
            pluginError = error
        }
        
        //when
        sut.upload(call!)
        waitForExpectations(timeout: 2, handler: nil)
        
        //then
        XCTAssertFalse(successBlockCalled, ErrorMessages.successBlockShouldNotBeCalled)
        XCTAssertNil(pluginResult, ErrorMessages.nilValueNotFound)
        
        let error = try XCTUnwrap(pluginError)
        
        assertRejectValues(of: error, against: CAPPluginCallError(message: "File does not exists", code: "2", error: nil, data: [:]))
        
    }
    
    /// To test abort when objectId is not sent
    /// - Throws: Error
    func testAbortWhenObjectIdIsNotSent() throws {
        //given
        var pluginResult: CAPPluginCallResult? = nil
        var pluginError: CAPPluginCallError? = nil
        
        var successBlockCalled = false
        let errorCompletion = expectation(description: "Call reject")
        
        let call = CAPPluginCall(callbackId: "testAbortWhenObjectIdIsNotSent", options: [
            "NOT_ObjectId" : "1"
            ], success: { (result, _) in
                successBlockCalled = true
                pluginResult = result
        }) { (error) in
            errorCompletion.fulfill()
            pluginError = error
        }
        
        //when
        sut.abort(call!)
        waitForExpectations(timeout: 2, handler: nil)
        
        //then
        XCTAssertFalse(successBlockCalled, ErrorMessages.successBlockShouldNotBeCalled)
        XCTAssertNil(pluginResult, ErrorMessages.nilValueNotFound)
        
        let error = try XCTUnwrap(pluginError)
        
        assertRejectValues(of: error, against: CAPPluginCallError(message: "Insufficient data", code: "1", error: nil, data: [:]))
    }
    
    /// To test abort when objectId is sent but no task is found for that objectId
    /// - Throws: Error
    func testAbortWhenObjectIdIsSentAndTaskNotFound() throws {
        //given
        var pluginResult: CAPPluginCallResult? = nil
        var pluginError: CAPPluginCallError? = nil
        
        var successBlockCalled = false
        let errorCompletion = expectation(description: "Call reject")
        
        let call = CAPPluginCall(callbackId: "testAbortWhenObjectIdIsSentAndTaskNotFound", options: [
            "objectId" : "1"
            ], success: { (result, _) in
                successBlockCalled = true
                pluginResult = result
        }) { (error) in
            errorCompletion.fulfill()
            pluginError = error
        }
        
        //when
        sut.abort(call!)
        waitForExpectations(timeout: 2, handler: nil)
        
        //then
        XCTAssertFalse(successBlockCalled, ErrorMessages.successBlockShouldNotBeCalled)
        XCTAssertNil(pluginResult, ErrorMessages.nilValueNotFound)
        
        let error = try XCTUnwrap(pluginError)
        
        assertRejectValues(of: error, against: CAPPluginCallError(message: "Task not found for objectID", code: "1", error: nil, data: [:]))
    }
    
    /// To test abort when objectId is sent and task is found for that objectId
    /// - Throws: Error
    func testAbortWhenObjectIdIsSentAndTaskFound() throws {
        //given
        var pluginResult: CAPPluginCallResult? = nil
        var pluginError: CAPPluginCallError? = nil
        
        var errorBlockCalled = false
        let successCompletion = expectation(description: "Call resolve")
        
        let mockTask = MockRequest()
        sut.sessionTasks["1"] = mockTask
        
        let call = CAPPluginCall(callbackId: "testAbortWhenObjectIdIsSentAndTaskFound", options: [
            "objectId" : "1"
            ], success: { (result, _) in
                successCompletion.fulfill()
                pluginResult = result
        }) { (error) in
            errorBlockCalled = true
            pluginError = error
        }
        
        //when
        sut.abort(call!)
        waitForExpectations(timeout: 2, handler: nil)
        
        //then
        XCTAssertFalse(errorBlockCalled, ErrorMessages.errorBlockShouldNotBeCalled)
        XCTAssertNil(pluginError, ErrorMessages.nilValueNotFound)
        XCTAssert(mockTask.cancelCalled, "Task not cancelled")
        XCTAssertNotNil(pluginResult, ErrorMessages.nilValueFound)
    }
    
    /// To test sendError
    /// - Throws: Error
    func testSendError() throws {
        //given
        var pluginResult: CAPPluginCallResult? = nil
        var pluginError: CAPPluginCallError? = nil
        
        var successBlockCalled = false
        let errorCompletion = expectation(description: "Call reject")
        
        let call = CAPPluginCall(callbackId: "testSendError", options: [:], success: { (result, _) in
                successBlockCalled = true
                pluginResult = result
        }) { (error) in
            errorCompletion.fulfill()
            pluginError = error
        }
        
        let mockMessage = "mock message"
        let mockCode = "1"
        let mockError: MockError = .sampleError
        let mockData = PluginResultData(dictionaryLiteral: ("Mock Key", "Mock Value"))
        
        //when
        sut.sendError(call: call!, message: mockMessage, code: ErrorCode(rawValue: 1)!, error: mockError, data: mockData)
        waitForExpectations(timeout: 2, handler: nil)
        
        //then
        XCTAssertFalse(successBlockCalled, ErrorMessages.successBlockShouldNotBeCalled)
        XCTAssertNil(pluginResult, ErrorMessages.nilValueNotFound)
        
        let error = try XCTUnwrap(pluginError)
        
        assertRejectValues(of: error, against: CAPPluginCallError(message: mockMessage, code: mockCode, error: mockError, data: mockData))
    }
    
    /// To test if background task is ended properly
    func testEndBackgroundTask() {
        //given
        let mockBGId: UIBackgroundTaskIdentifier = .invalid
        let mockObjectID = "1"
        sut.bgTasks[mockObjectID] = mockBGId
        
        //when
        sut.endBackgroundTask(mockBGId, mockObjectID)
        
        //then
        XCTAssertTrue(mockApplication.endBackgroundTaskCalled, "Background task not ended")
        XCTAssertNil(sut.bgTasks[mockObjectID], "Stored BGtask is not removed from dictionary")
        
    }
    
    /// To test isAlreadyRunning when the request is not duplicate
    func testIsAlreadyRunningForNonDuplicateRequest() {
        //given
        let mockPath = "Mock Server URL"
        sut.sessionTasks = [:] // Setting it to empty to avoid any discrepancies
        
        //when
        let returnValue = sut.isAlreadyRunning(for: mockPath)
        
        //then
        XCTAssertFalse(returnValue, "Should return false as no request is running for that path")
        
    }
    
    /// To test isAlreadyRunning when the request is duplicate
    func testIsAlreadyRunningForDuplicateRequest() {
        //given
        //Using fileURL as URL as that method does not return any optionals. As this is a mock path it does not affect any flow.
        let mockURL = URL(fileURLWithPath: "Mock server URL")
        let mockPath = mockURL.absoluteString
        let mockURLRequest = URLRequest(url: mockURL)
        let mockRequest = MockRequest()
        mockRequest.mockRequest = mockURLRequest
        
        sut.sessionTasks = [:] // Setting it to empty to avoid any discrepancies
        sut.sessionTasks["1"] = mockRequest
        
        //when
        let returnValue = sut.isAlreadyRunning(for: mockPath)
        
        //then
        XCTAssertTrue(returnValue, "Should return true as there is already another request for that path")
        
    }
    
}
