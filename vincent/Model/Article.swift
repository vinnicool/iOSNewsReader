//
//  Article.swift
//  vincent
//
//  Created by Vincent on 10/23/18.
//  Copyright © 2018 drok. All rights reserved.
//

import Foundation

public class Article : Codable {
    
    public var id : Int
    public var feed : Int
    public var title : String
    public var publishDate : String
    public var summary : String
    public var image : String
    public var url : String
    public var categories : [Category]
    public var isLiked : Bool
    
    enum CodingKeys : String, CodingKey{
        case id = "Id"
        case feed = "Feed"
        case title = "Title"
        case publishDate = "PublishDate"
        case summary = "Summary"
        case image = "Image"
        case url = "Url"
        case categories = "Categories"
        case isLiked = "IsLiked"
    }
}
