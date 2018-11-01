//
//  InternetHelper.swift
//  vincent
//
//  Created by Vincent on 10/30/18.
//  Copyright © 2018 drok. All rights reserved.
//

import Foundation
import Alamofire

public class InternetHelper {
    public static func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
