//
//  StringHelper.swift
//  vincent
//
//  Created by Vincent on 10/29/18.
//  Copyright © 2018 drok. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    public func setAsLink(textToFind: String, linkUrl: String) -> Bool {
        let foundRange = self.mutableString.range(of: textToFind)
        
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkUrl, range: foundRange)
            return true
        }
        return false
    }
}
