//
//  NetworkError.swift
//  Generic-Network-Layer
//
//  Created by Thulani Mtetwa on 2022/09/26.
//

import Foundation

/// Custom Error enum that we'll use in case
enum NetworkError: Error {
    
    case noInternet
    case apiFailure
    case invalidResponse
    case decodingError
    case noData
    
    var customDescription: String {
        switch self {
        case .noInternet:
            return "No network"
        case .apiFailure:
            return "Service endpoint issues"
        case .invalidResponse:
            return "Unexpected response from server"
        case .decodingError:
            return "Something went wrong with the data from the server"
        case .noData:
            return "No data returned"
        }
    }
}
