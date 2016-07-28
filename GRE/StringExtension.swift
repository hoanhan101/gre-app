//
//  StringExtension.swift
//  GRE
//
//  Created by Hoanh An on 7/15/16.
//  Copyright © 2016 Hoanh An. All rights reserved.
//

import Foundation

extension String {
    func deleteHTMLTag(tag:String) -> String {
        return self.stringByReplacingOccurrencesOfString("(?i)</?\(tag)\\b[^<]*>", withString: "", options: .RegularExpressionSearch, range: nil)
    }
    
    func deleteHTMLTags(tags:[String]) -> String {
        var mutableString = self
        for tag in tags {
            mutableString = mutableString.deleteHTMLTag(tag)
        }
        return mutableString
    }
}