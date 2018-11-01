//
//  NewsreaderApiManager.swift
//  vincent
//
//  Created by Vincent on 10/23/18.
//  Copyright © 2018 drok. All rights reserved.
//

import Foundation
import Alamofire

public class NewsreaderApiManager {
    static let baseUrl : String = "https://inhollandbackend.azurewebsites.net/api/"
    
    static func login(user : User) -> DataRequest {
        
        let encoder = JSONEncoder()
        let jsonData = try? encoder.encode(user)
        
        let url = baseUrl + "Users/login"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        return Alamofire.request(request)
    }
    
    static func register(user: User) -> DataRequest {
        let encoder = JSONEncoder()
        let jsonData = try? encoder.encode(user)
        
        let url = baseUrl + "Users/register"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        return Alamofire.request(request)
    }
    
    static func getNews(token: String?, count: Int?, nextId: Int?, feed: Int?) -> DataRequest {
        var params: [String:String] = [:]
        var url = baseUrl + "Articles"
        
        if let count = count{
            params["count"] = "\(count)"
        }
        
        if let feed = feed {
            params["feed"] = "\(feed)"
        }
        
        if let nextId = nextId {
            url = url + "/" + "\(nextId)"
        }
        
        if let authtoken = token {
            let header = ["x-authtoken": authtoken]
            return Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: header)
        }
        
        return Alamofire.request(url, method: .get, parameters: params)
    }
    
    static func getLikedNews(token: String) -> DataRequest {
        let url = baseUrl + "Articles/liked"
        
        let header = ["x-authtoken": token]
        
        return Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header)
    }
    
    static func like(token: String, articleId: Int) -> DataRequest {
        let url = baseUrl + "articles/" + "\(articleId)" + "/like"
        
        let header = ["x-authtoken": token]
        
        return Alamofire.request(url, method: .put, parameters: nil, encoding: URLEncoding.default, headers: header)
    }
    
    static func unlike(token: String, articleId: Int) -> DataRequest {
        let url = baseUrl + "articles/" + "\(articleId)" + "/like"
        
        let header = ["x-authtoken" : token]
        
        return Alamofire.request(url, method: .delete, parameters: nil, encoding: URLEncoding.default, headers: header)
    }
    
    static func getFeed() -> DataRequest {
        let url = baseUrl + "Feeds"
        return Alamofire.request(url, method: .get)
    }
}
