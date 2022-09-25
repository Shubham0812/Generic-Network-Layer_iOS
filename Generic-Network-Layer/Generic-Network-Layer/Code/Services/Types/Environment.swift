//
//  Environment.swift
//  Generic-Network-Layer
//
//  Created by Thulani Mtetwa on 2022/09/26.
//

import Foundation

enum Environment {

    static var apiBaseURL: URL {
        URL(string: "https://jsonplaceholder.typicode.com/")!
    }
}
