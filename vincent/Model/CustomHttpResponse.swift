//
//  CustomHttpResponse.swift
//  vincent
//
//  Created by Vincent on 10/23/18.
//  Copyright © 2018 drok. All rights reserved.
//

import Foundation

public class CustomHttpResponse : Codable {
    public var success : Bool
    public var message : String
    
    enum CodingKeys : String, CodingKey{
        case success = "Success"
        case message = "Message"
    }
}
