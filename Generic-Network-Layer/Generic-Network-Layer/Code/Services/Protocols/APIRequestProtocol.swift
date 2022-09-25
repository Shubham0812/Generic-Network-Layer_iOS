//
//  APIRequestProtocol.swift
//  Generic-Network-Layer
//
//  Created by Thulani Mtetwa on 2022/09/26.
//

import Foundation

protocol APIRequestProtocol {
    func makeGetRequest<T: Codable> (path: String, queries: Parameters, onCompletion: @escaping(Result<T?, NetworkError>) -> Void)
    func makePostRequest<T: Codable> (path: String, body: Parameters, onCompletion: @escaping (Result<T?, NetworkError>) -> Void)
}
