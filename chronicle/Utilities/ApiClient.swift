//
//  ApiClient.swift
//  ApiClient
//
//  Created by Alfonce Nzioka on 8/11/21.
//

import Foundation
import OSLog
/// handles all API requests
struct ApiClient {
    // logger:
    static var logger = Logger(subsystem: "com.openlattice.chronicle", category: "ApiClient")
    /// Enrolls a device
    static func enrollDevice(enrollment: Enrollment, onSuccess: @escaping (String) -> Void, onError: @escaping (String) -> Void) async {
        
        // device data
        let deviceInformation = await EnrollmentUtils.getDeviceInformation()
        guard let deviceId = deviceInformation.deviceId else {
            return
        }
        
        guard let urlComponents: URLComponents = enrollment.withOrgId
                ? ApiUtils.makeEnrollDeviceComponentsWithOrg(enrollment: enrollment, deviceId: deviceId)
                : ApiUtils.makeEnrollDeviceComponentsWithoutOrg(enrollment: enrollment, deviceId: deviceId) else {
                    return
                }
        
        // prepare json data
        guard let reqBody = try? JSONEncoder().encode(deviceInformation) else {
            onError("encoding error")
            return
        }
        
        // configure url request
        guard let url = urlComponents.url else {
            onError("Invalid url")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // create task
        let task = URLSession.shared.uploadTask(with: request, from: reqBody) { data, response, error in
            if let error = error {
                onError(error.localizedDescription)
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                onError("server error")
                return
            }
            
            guard let data = data, let deviceEKID = try? JSONDecoder().decode(UUID.self, from: data) else {
                onError("expected a UUID response")
                return
            }
            onSuccess(deviceId)
            print(deviceEKID)
            
        }
        task.resume()
    }
    
    // upload SensorData to server
    static func uploadData(sensorData: Data, enrollment: Enrollment, deviceId: String, onCompletion: @escaping() -> Void, onError: @escaping (String) -> Void) {

        let urlComponents: URLComponents? = ApiUtils.createSensorDataUploadURLComponents(enrollment: enrollment, deviceId: deviceId)
        
        guard let url = urlComponents?.url else {
            onError("failed to upload sensor data: invalid url")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, from: sensorData) { data, response, error in
            if let error = error {
                onError(error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                onError("Unexpected response: \(String(describing: response))")
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            guard statusCode == 200 else {
                onError("unexpected status code: \(statusCode)")
                return
            }
            
            onCompletion()
        }
        
        task.resume()
    }
}

// throw strings as errors
extension String: Error {}
