//
//  Config.swift
//  HDOWeather
//
//  Created by Daniel Nichols on 5/17/16.
//  Copyright © 2016 Hey Danno. All rights reserved.
//

import Foundation

class Config {
    
    class func plist<T>(name: String, key: String) -> T? {
        guard let path = NSBundle.mainBundle().pathForResource(name, ofType: "plist") else {
            return nil
        }
        guard NSFileManager.defaultManager().fileExistsAtPath(path) else {
            return nil
        }
        guard let dict = NSDictionary(contentsOfFile: path) else {
            return nil
        }
        return dict[key] as? T
    }

}