import Foundation
import Capacitor
import Alamofire

enum ErrorCode: Int {
    case insufficientData = 1,
    fileNotFound,
    requestFailure,
    duplicateRequest
    
    func stringValue() -> String {
        return String(self.rawValue)
    }
}

protocol UIApplicationProtocol {
    func beginBackgroundTask(expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier
    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier)
}

extension UIApplication: UIApplicationProtocol {
    
}

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(FileTransfer)
public class FileTransfer: CAPPlugin {
    
    var session = AF
    var sessionTasks = [String:Request]()
    var bgTasks = [String:UIBackgroundTaskIdentifier]()
    //For UT purpose
    var application: UIApplicationProtocol = UIApplication.shared
    
    /// Method for initiating a download request from JS
    /// - Parameter call: Keys - {src: String, destination: String, objectID: String, options: [String:Any]}
    @objc func download(_ call: CAPPluginCall) {
        
        guard let src = call.getString("src"),
            let destination = call.getString("destination"),
            let objectID = call.getString("objectId") else {
                sendError(call: call, message: "Insufficient data", code: .insufficientData, error: nil)
                return
        }
        
        if isAlreadyRunning(for: src) {
            sendError(call: call, message: "Request already running for the given src URL", code: .duplicateRequest, error: nil)
            return
        }
        
        var isBackground: Bool = false
        var headers: HTTPHeaders?
        var backgroundTask: UIBackgroundTaskIdentifier = .invalid
        
        if let options = call.getObject("options") {
            isBackground = (options["background"] as? Bool) ?? isBackground
            
            if let headersDict = options["headers"] as? [String:String] {
                headers = HTTPHeaders(headersDict)
            }
        }
        
        if isBackground {
            backgroundTask =  application.beginBackgroundTask {
                backgroundTask = .invalid
                self.endBackgroundTask(backgroundTask, objectID)
            }
            
            bgTasks[objectID] = backgroundTask
        }
        
        
        
        let downloadTask = session.download(src, headers: headers) { (_, _) -> (destinationURL: URL, options: DownloadRequest.Options) in
            // Copy the downloaded file from temporary directory to the destination file path provided
            let destinationUrl = URL(fileURLWithPath: destination.replacingOccurrences(of: "file://", with: ""))
            
            return (destinationUrl, [.removePreviousFile, .createIntermediateDirectories])
        }
            
        .downloadProgress { (progress) in
            self.notifyListeners("onDownloadProgress", data: [
                "objectId" : objectID,
                "progress" : progress.fractionCompleted
            ])
        }
            
        .response { (response) in
            
            if let bgTask = self.bgTasks[objectID], bgTask != .invalid {
                self.endBackgroundTask(bgTask, objectID)
            }
            
            self.sessionTasks.removeValue(forKey: objectID)
            
            if response.error == nil {
                call.resolve()
            } else {
                self.sendError(call: call, message: "Request failed with error", code: .requestFailure, error: response.error, data: [
                    "httpCode" : (response.response?.statusCode) ?? 0,
                    "response" : (response.response) ?? [:]
                ])
            }
        }
        
        sessionTasks[objectID] = downloadTask
    }
    
    /// Method for initiating an upload request from JS
    /// - Parameter call: Keys - {src: String, destination: String, objectID: String, options: [String:Any]}
    @objc func upload(_ call: CAPPluginCall) {
        guard let src = call.getString("src"),
            let destination = call.getString("destination"),
            let objectID = call.getString("objectId") else {
                sendError(call: call, message: "Insufficient data", code: .insufficientData, error: nil)
                return
        }
        
        if isAlreadyRunning(for: destination) {
            sendError(call: call, message: "Request already running for the given src URL", code: .duplicateRequest, error: nil)
            return
        }
        
        let absSrcPath = src.replacingOccurrences(of: "file://", with: "")
        
        if !FileManager.default.fileExists(atPath: absSrcPath) {
            sendError(call: call, message: "File does not exists", code: .fileNotFound, error: nil)
            return
        }
        
        var isBackground: Bool = false
        var headers: HTTPHeaders?
        var httpMethod: HTTPMethod = .post
        var fileKey: String = "file"
        var fileName: String = "image.jpg"
        var mimeType: String = "image/jpeg"
        var backgroundTask: UIBackgroundTaskIdentifier = .invalid
        
        if let options = call.getObject("options") {
            
            isBackground = (options["background"] as? Bool) ?? isBackground
            fileKey = (options["fileKey"] as? String) ?? fileKey
            fileName = (options["fileName"] as? String) ?? fileName
            mimeType = (options["mimeType"] as? String) ?? mimeType
            
            if let method = options["httpMethod"] as? String {
                httpMethod = HTTPMethod(rawValue: method.uppercased())
            }
            
            if let headersDict = options["headers"] as? [String:String] {
                headers = HTTPHeaders(headersDict)
            }
        }
        
        if isBackground {
            backgroundTask =  application.beginBackgroundTask {
                backgroundTask = .invalid
                self.endBackgroundTask(backgroundTask, objectID)
            }
            
            bgTasks[objectID] = backgroundTask
        }
        
        let uploadTask = session.upload(multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(URL(fileURLWithPath: absSrcPath), withName: fileKey, fileName: fileName, mimeType: mimeType)
            
        }, to: destination, method: httpMethod, headers: headers)
            
            .uploadProgress(closure: { (progress) in
                self.notifyListeners("onUploadProgress", data: [
                    "objectId" : objectID,
                    "progress" : progress.fractionCompleted
                ])
            })
            .response { (response) in
                
                if let bgTask = self.bgTasks[objectID], bgTask != .invalid {
                    self.endBackgroundTask(bgTask, objectID)
                }
                
                self.sessionTasks.removeValue(forKey: objectID)
                
                if response.error == nil {
                    call.resolve()
                } else {
                    self.sendError(call: call, message: "Request failed with error", code: .requestFailure, error: response.error, data: [
                        "httpCode" : (response.response?.statusCode) ?? 0,
                        "response" : (response.response) ?? [:]
                    ])
                }
        }
        
        sessionTasks[objectID] = uploadTask
        
    }
    
    /// Method for aborting a request initiated from JS
    /// - Parameter call: Keys - {objectID: String}
    @objc func abort(_ call: CAPPluginCall) {
        
        guard let objectID = call.getString("objectId") else {
            sendError(call: call, message: "Insufficient data", code: .insufficientData, error: nil)
            return
        }
        
        if let task = sessionTasks[objectID] {
            //Cancel the request
            task.cancel()
            //Resolve the promise that initiated the abort request
            call.resolve()
        } else {
            sendError(call: call, message: "Task not found for objectID", code: .insufficientData, error: nil)
        }
    }
    
    /// This is used to reject the promise of CAPPluginCall
    /// - Parameters:
    ///   - call: The CAPPluginCall object
    ///   - message: The message string that is to be sent while rejecting
    ///   - code: The error code
    ///   - error: The Error object
    ///   - data: Any additional data
    func sendError(call: CAPPluginCall, message: String, code: ErrorCode, error:Error?, data: PluginCallErrorData = [:]) {
        call.reject(message, code.stringValue(), error, data)
    }
    
    /// Method to end an already running background task
    /// - Parameters:
    ///   - backgroundTask: The background task identifier
    ///   - objectID: The objectID for identifying and removing the background task from the bgTasks list
    func endBackgroundTask(_ backgroundTask: UIBackgroundTaskIdentifier, _ objectID: String) {
        application.endBackgroundTask(backgroundTask)
        self.bgTasks.removeValue(forKey: objectID)
    }
    
    /// To check if a request is already running for the src URL
    /// - Parameter path: The src path to check
    /// - Returns: True if a request is already running, false otherwise
    func isAlreadyRunning(for path: String) -> Bool {
        for task in self.sessionTasks.values {
            if task.request?.url?.absoluteString == path {
                return true
            }
        }
        return false
    }
    
}
