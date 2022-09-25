//
//  StatusCode+Helpers.swift
//  Generic-Network-Layer
//
//  Created by Thulani Mtetwa on 2022/09/26.
//

import Foundation

extension StatusCode {

    var isSuccess: Bool {
        (200..<300).contains(self)
    }
}
