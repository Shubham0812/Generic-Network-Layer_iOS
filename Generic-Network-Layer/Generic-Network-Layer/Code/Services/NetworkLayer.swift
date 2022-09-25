//
//  NetworkManager.swift
//  Generic-Network-Layer
//
//  Created by Shubham on 01/09/21.
//

import Foundation


struct APIRequestManager {
    // MARK:- functions
    
    /// This function calls the URLRequest passed to it, maps the result and returns it. It is called by GET and POST.
    private func makeRequest<T: Codable>(session: URLSession, request: URLRequest, model: T.Type, onCompletion: @escaping(Result<T?, NetworkError>) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            onCompletion(.failure(NetworkError.noInternet))
            return
        }
        
        session.dataTask(with: request) { data, response, error in
            guard error == nil, let responseData = data else { onCompletion(.failure (NetworkError.apiFailure)) ; return }
            
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            guard statusCode.isSuccess else {
                onCompletion(.failure (NetworkError.apiFailure))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                    as? Parameters  {
                    let jsonData = try JSONSerialization.data(withJSONObject: json)
                    let response = try JSONDecoder().decode(T.self, from: jsonData)
                    onCompletion(.success (response))
                    /// if the response is an `Array of Objects`
                } else if let json = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                            as? [Parameters] {
                    let jsonData = try JSONSerialization.data(withJSONObject: json)
                    let response = try JSONDecoder().decode(T.self, from: jsonData)
                    onCompletion(.success (response))
                }
                else {
                    onCompletion(.failure (NetworkError.invalidResponse))
                    return
                }
            } catch {
                onCompletion(.failure (NetworkError.decodingError))
                return
            }
        }.resume()
    }
    
}



extension APIRequestManager: APIRequestProtocol {
    /// Generic GET Request
    func makeGetRequest<T: Codable>(path: String, queries: Parameters, onCompletion: @escaping (Result<T?, NetworkError>) -> Void) {
        let session = URLSession.shared
        let request: URLRequest = APIEndpoint.getAPI(path: path, data: queries).asURLRequest()
        
        makeRequest(session: session, request: request, model: T.self) { (result) in
            switch result {
            case .success(let data):
                onCompletion(.success(data))
            case .failure(let error):
                onCompletion(.failure(error))
            }
        }
    }
    
    /// Generic POST request
    func makePostRequest<T: Codable>(path: String, body: Parameters, onCompletion: @escaping (Result<T?, NetworkError>) -> Void) {
        let session = URLSession.shared
        let request: URLRequest = APIEndpoint.postAPI(path: path, data: body).asURLRequest()
        
        makeRequest(session: session, request: request, model: T.self) { (result) in
            switch result {
            case .success(let data):
                onCompletion(.success(data))
            case .failure(let error):
                onCompletion(.failure(error))
            }
        }
    }
}

/// Wrapper for Network Requests, has functions for various API Requests, and passes the queries to the Generic GET/POST functions.
struct NetworkManager {
    
    private let apiService: APIRequestProtocol
    var parameters: Post?
    
    init(apiService: APIRequestProtocol) {
        self.apiService = apiService
    }
    
    // MARK:- functions
    
    /// Fetches Array of Posts. Note that I've passed T as [Post]?
    func getPosts(onCompletion: @escaping (Result<[Post]?, NetworkError>) -> ()) {
        apiService.makeGetRequest(path: "posts", queries: [:]) {(result: Result<[Post]?, NetworkError>) in
            switch result {
            case .success(let data):
                onCompletion(.success(data))
            case .failure(let error):
                onCompletion(.failure(error))
            }
        }
    }
    
    /// Puts a post using POST API. Here T passed is [String : String]?
    func addPost(onCompletion: @escaping (Result<Response?, NetworkError>) -> ()) {
        
        guard let body = parameters.dict else {
            onCompletion(.failure(.decodingError))
            return
        }
        
        apiService.makePostRequest(path: "posts", body: body, onCompletion: {(result: Result<Response?, NetworkError>) in
            switch result {
            case .success(let data):
                onCompletion(.success(data))
            case .failure(let error):
                onCompletion(.failure(error))
            }
        })
    }
}



/// Models
///
/// for GET API
struct Post: Codable {
    let userId: Int
    let title: String
    let body: String
}

struct Response: Codable {
    let userId: Int
    let title: String
    let body: String
    let id: Int
}

