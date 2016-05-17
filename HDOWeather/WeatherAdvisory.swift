//
//  WeatherAdvisory.swift
//  HDOWeather
//
//  Created by Daniel Nichols on 5/17/16.
//  Copyright © 2016 Hey Danno. All rights reserved.
//

import Foundation

enum WeatherAdvisory: Int {
    case
    Tornado = 900,
    TropicalStorm = 901,
    Hurricane = 902,
    Cold = 903,
    Heat = 904,
    Wind = 905,
    Hale = 906
    
    static func from(condition: OpenWeatherMapCondition) -> WeatherAdvisory? {
        guard let i = condition.id else {
            return nil
        }
        return self.init(rawValue: i)
    }
}