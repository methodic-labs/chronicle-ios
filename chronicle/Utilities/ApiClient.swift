//
//  ApiClient.swift
//  ApiClient
//
//  Created by Alfonce Nzioka on 8/11/21.
//

import Foundation

/// handles all API requests
struct ApiClient {
    static func enrollDevice(enrollment: Enrollment, withOrgId: Bool = true, onSuccess: @escaping () -> Void, onError: @escaping (EnrollmentError) -> Void) async {
        
        // validate input
        let error: EnrollmentError? = EnrollmentUtils.validateEnrollmentDetails(enrollment: enrollment, withOrgId: withOrgId)
        if error != nil {
            onError(error!)
            return
        }
                
        // device data
        let deviceInformation = await EnrollmentUtils.getDeviceInformation()
        guard let deviceId = deviceInformation.deviceId else {
            onError(EnrollmentError.invalidDeviceId)
            return
        }
        
        guard let urlComponents: URLComponents = withOrgId
                ? ApiUtils.makeEnrollDeviceComponentsWithOrg(enrollment: enrollment, deviceId: deviceId)
                : ApiUtils.makeEnrollDeviceComponentsWithoutOrg(enrollment: enrollment, deviceId: deviceId) else {
            onError(EnrollmentError.invalidUrl)
            return
        }
        
        // prepare json data
        guard let reqBody = try? JSONEncoder().encode(deviceInformation) else {
            onError(EnrollmentError.encodingError)
            return
        }
    
        // configure url request
        guard let url = urlComponents.url else {
            onError(EnrollmentError.invalidUrl)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // create task
        let task = URLSession.shared.uploadTask(with: request, from: reqBody) { data, response, error in
            if let error = error {
                onError(EnrollmentError.serverError(description: error.localizedDescription))
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                onError(EnrollmentError.serverError(description: "server error"))
                return
            }
            
            // response should be a valid UUID
            if let mimeType = response.mimeType,
                mimeType == "text/plain",
                let data = data,
                let dataString = String(data: data, encoding: .utf8),
                UUID.init(uuidString: dataString) != nil{
                onSuccess()
            }
        }
        task.resume()
    }
}
