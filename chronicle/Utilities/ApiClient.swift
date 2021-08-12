//
//  ApiClient.swift
//  ApiClient
//
//  Created by Alfonce Nzioka on 8/11/21.
//

import Foundation

/// handles all API requests
struct ApiClient {
    /// Enrolls a device
    static func enrollDevice(enrollment: Enrollment, withOrgId: Bool, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) async {
        
        // device data
        let deviceInformation = await EnrollmentUtils.getDeviceInformation()
        guard let deviceId = deviceInformation.deviceId else {
            return
        }
        
        guard let urlComponents: URLComponents = withOrgId
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
            
            // response should be a valid UUID
            if let mimeType = response.mimeType,
               mimeType == "text/plain",
               let data = data,
               let dataString = String(data: data, encoding: .utf8),
               let ekid = UUID.init(uuidString: dataString) {
                print("Device EKID: \(ekid)")
                onSuccess()
            }
        }
        task.resume()
    }
}
