//
//  URLEncoding.swift
//  Generic-Network-Layer
//
//  Created by Thulani Mtetwa on 2022/09/26.
//

import Foundation

/// for encoding the Query Parameters in case of a GET call. Queries are passed in the ?q=<>&<> format
enum URLEncoding {
    
    case queryString
    case none
    
    func encode(_ request: inout URLRequest, with parameters: Parameters)  {
        switch self {
        
        case .queryString:
            guard let url = request.url else { return }
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
               !parameters.isEmpty {
                
                urlComponents.queryItems = [URLQueryItem]()
                for (k, v) in parameters {
                    let queryItem = URLQueryItem(name: k, value: "\(v)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                    urlComponents.queryItems?.append(queryItem)
                }
                request.url = urlComponents.url
            }
            
        case .none:
            break
        }
    }
}
