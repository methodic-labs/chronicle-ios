//
//  ApiClient.swift
//  ApiClient
//
//  Created by Alfonce Nzioka on 8/11/21.
//

import Foundation

/// handles all API requests
struct ApiClient {
    static var settings = UserDefaults.standard
    
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
    
    static func getPropertyTypeIds() async -> [FullQualifiedName: UUID]? {
        // get locally stored value
        let result = settings.object(forKey: UserSettingsKeys.propertyTypes) as? [String: String] ?? [:]
        if (result.count == FullQualifiedName.fqns.count) {
            print("Returning locally stored values")
            return Utils.toFqnUUIDMap(result)
        }
        
        let urlComponents: URLComponents = ApiUtils.getPropertyTypeIdsUrlComponents()
        
        guard let reqBody = try? JSONEncoder().encode(FullQualifiedName.fqns) else {
            return nil
        }
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let (data, response ) = try? await URLSession.shared.upload(for: request, from: reqBody),
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
            
            return nil
        }
        
        guard let decoded = try? JSONDecoder().decode([String: String].self, from: data) else {
            return nil
        }
        settings.set(decoded, forKey: UserSettingsKeys.propertyTypes)
                
        return Utils.toFqnUUIDMap(decoded)
    }
}
