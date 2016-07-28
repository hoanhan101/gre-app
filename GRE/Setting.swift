//
//  Settings.swift
//  GRE
//
//  Created by Hoanh An on 7/13/16.
//  Copyright © 2016 Hoanh An. All rights reserved.
//

import Foundation
import RealmSwift

class Setting : Object{
    dynamic var turnOffSound : Int = 0
    dynamic var isRandom: Int = 0
    static func create() -> Setting {
        let setting = Setting()
        DB.createSetting(setting)
        return setting
    }
}