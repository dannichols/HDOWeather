//
//  WeatherCondition.swift
//  HDOWeather
//
//  Created by Daniel Nichols on 5/17/16.
//  Copyright © 2016 Hey Danno. All rights reserved.
//

import Foundation

enum WeatherCondition {
    case
    Thunderstorm,
    Drizzle,
    Rain,
    Snow,
    Atmosphere,
    Clear,
    FewClouds,
    ScatteredClouds,
    OvercastClouds,
    Windy
    
    static func from(condition: OpenWeatherMapCondition) -> WeatherCondition? {
        guard let i = condition.id else {
            return nil
        }
        if i >= 200 && i < 300 {
            return .Thunderstorm
        } else if i >= 300 && i < 400 {
            return .Drizzle
        } else if i >= 500 && i < 600 {
            return .Rain
        } else if i >= 600 && i < 700 {
            return .Snow
        } else if i >= 700 && i < 800 {
            return .Atmosphere
        } else if i == 800 {
            return .Clear
        } else if i == 801 {
            return .FewClouds
        } else if i >= 802 && i < 804 {
            return .ScatteredClouds
        } else if i == 804 {
            return .OvercastClouds
        } else if i >= 952 && i < 960 {
            return .Windy
        } else {
            return nil
        }
    }
    
    static func summarize(conditions: [WeatherCondition]) -> WeatherCondition {
        var mode = WeatherCondition.Clear
        var maxCount = 0
        for condition in conditions {
            var count = 0
            for other in conditions {
                if other == condition {
                    count += 1
                }
            }
            if count > maxCount {
                maxCount = count
                mode = condition
            }
        }
        return mode
    }
    
    static func summarize(conditions: [OpenWeatherMapCondition]) -> WeatherCondition? {
        let cleaned = conditions
            .map({ WeatherCondition.from($0) })
            .filter({ $0 != nil })
            .flatMap({ $0 })
        return self.summarize(cleaned)
    }
}