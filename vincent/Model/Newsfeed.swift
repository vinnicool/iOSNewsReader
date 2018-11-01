//
//  Newsfeed.swift
//  vincent
//
//  Created by Vincent on 10/23/18.
//  Copyright © 2018 drok. All rights reserved.
//

import Foundation

public class Newsfeed : Codable {
    public var nextId : Int
    public var results : [Article]
    
    enum CodingKeys : String, CodingKey {
        case nextId = "NextId"
        case results = "Results"
    }
}
