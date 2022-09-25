//
//  Encodable+Dictionary.swift
//  Generic-Network-Layer
//
//  Created by Thulani Mtetwa on 2022/09/26.
//

import Foundation

extension Encodable {
    var dict : [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { return nil }
        return json
    }
}
