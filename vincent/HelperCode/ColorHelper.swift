//
//  ColorHelper.swift
//  vincent
//
//  Created by Vincent on 10/28/18.
//  Copyright © 2018 drok. All rights reserved.
//

import Foundation
import UIKit

public class ColorHelper {
    static func hexStringToUIColor(hex : String) -> UIColor {
        var hexString = hex.uppercased()
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        if hexString.count != 6 {
            return UIColor.lightGray
        }
        
        var rgb : UInt32 = 0
        Scanner(string: hexString).scanHexInt32(&rgb)
        
        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255,
            blue: CGFloat((rgb & 0x0000FF) >> 0) / 255,
            alpha: CGFloat(1.0)
        )
    }
}
