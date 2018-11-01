//
//  User.swift
//  vincent
//
//  Created by Vincent on 10/23/18.
//  Copyright © 2018 drok. All rights reserved.
//

import Foundation

public class User : Codable {
    public var username : String
    public var password : String
    
    enum CodingKeys : String, CodingKey {
        case username = "Username"
        case password = "Password"
    }
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
