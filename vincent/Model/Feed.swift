//
//  Feed.swift
//  vincent
//
//  Created by Vincent on 11/1/18.
//  Copyright © 2018 drok. All rights reserved.
//

import Foundation

public class Feed : Codable {
    public var id : Int
    public var name : String
    
    enum CodingKeys : String, CodingKey {
        case id = "Id"
        case name = "Name"
    }
}
