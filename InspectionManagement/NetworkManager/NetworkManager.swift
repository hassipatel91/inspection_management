//
//  NetworkManager.swift
//  InspectionManagementApp
//
//  Created by Sukh Vilas on 22/08/24.
//

import Foundation

class NetworkManager {
    // Singleton instance of NetworkManager
    static let shared = NetworkManager()
    private init() {}

    // Sends a POST request with a Codable body and calls the completion handler with the result
    func postRequest<T: Codable>(url: String, body: T, completion: @escaping (Result<Void, Error>) -> Void) {
        // Construct the URL from the provided endpoint
        guard let url = URL(string: "http://localhost:5001\(url)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // Encode the body into JSON and set it as the request's HTTP body
            request.httpBody = try JSONEncoder().encode(body)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    // Call completion with error if request fails
                    completion(.failure(error))
                    return
                }
                
                // Ensure the response is a 200 OK
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                    return
                }
                
                // Call completion with success if the response is valid
                completion(.success(()))
            }
            task.resume()
        } catch {
            // Call completion with error if JSON encoding fails
            completion(.failure(error))
        }
    }

    // Sends a GET request and decodes the response into a Codable type
    func getRequest<T: Codable>(url: String, completion: @escaping (Result<T, Error>) -> Void) {
        // Construct the URL from the provided endpoint
        guard let url = URL(string: "http://localhost:5001\(url)") else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                // Call completion with error if request fails
                completion(.failure(error))
                return
            }
            
            // Ensure there is data in the response
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                // Decode the data into the specified type
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedObject))
            } catch {
                // Call completion with error if JSON decoding fails
                completion(.failure(error))
            }
        }
        task.resume()
    }
}



