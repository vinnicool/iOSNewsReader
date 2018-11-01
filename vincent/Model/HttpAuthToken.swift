//
//  HttpAuthToken.swift
//  vincent
//
//  Created by Vincent on 10/24/18.
//  Copyright © 2018 drok. All rights reserved.
//

import Foundation

public class HttpAuthToken : Codable {
    public var authToken : String
    
    enum CodingKeys : String, CodingKey {
        case authToken = "AuthToken"
    }
}
