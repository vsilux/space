//
//  RequestError.swift
//  Space
//
//  Created by Illia Suvorov on 14.06.2025.
//

import Foundation

struct RequestError: LocalizedError, Decodable {
    let message: String
    let code: String
    
    var errorDescription: String? {
#if DEBUG
        return "Error code: \(code), message: \(message)"
#else
        return message
#endif
    }
}
