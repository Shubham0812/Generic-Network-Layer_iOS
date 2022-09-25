//
//  HTTPMethod.swift
//  Generic-Network-Layer
//
//  Created by Thulani Mtetwa on 2022/09/26.
//

import Foundation

/// An enum for various HTTPMethod. I've implemented GET and POST. I'll update the code and add the rest shortly :D
enum HTTPMethod: String {
    
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}
