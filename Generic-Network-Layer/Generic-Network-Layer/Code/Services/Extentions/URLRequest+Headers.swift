//
//  URLRequest+Headers.swift
//  Generic-Network-Layer
//
//  Created by Thulani Mtetwa on 2022/09/26.
//

import Foundation

extension URLRequest {
    mutating func addHeaders(_ headers: Headers) {
        headers.forEach { header, value in
            addValue(value, forHTTPHeaderField: header)
        }
    }
}
