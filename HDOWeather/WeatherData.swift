//
//  WeatherData.swift
//  HDOWeather
//
//  Created by Daniel Nichols on 5/17/16.
//  Copyright © 2016 Hey Danno. All rights reserved.
//

import Foundation

struct WeatherData {
    
    static func summarize(forecasts: [WeatherData]) -> WeatherData? {
        guard forecasts.count > 0 else {
            return nil
        }
        let count = Double(forecasts.count)
        var low = 999.0
        var high = -999.0
        var temperature = 0.0
        var humidity = 0.0
        var wind = 0.0
        var cloudiness = 0.0
        var conditions: [WeatherCondition] = []
        var advisory: WeatherAdvisory?
        var date: NSDate?
        for forecast in forecasts {
            temperature += forecast.temperature
            low = min(forecast.low, low)
            high = max(forecast.high, high)
            humidity += forecast.humidity
            wind += forecast.wind
            cloudiness += forecast.cloudiness
            conditions.append(forecast.condition)
            if advisory == nil && forecast.advisory != nil {
                advisory = forecast.advisory
            }
            if date == nil {
                date = forecast.date
            } else if let ref = date where forecast.date.timeIntervalSinceDate(ref) < 0 {
                date = forecast.date
            }
        }
        temperature /= count
        humidity /= count
        wind /= count
        cloudiness /= count
        let condition = WeatherCondition.summarize(conditions)
        guard let dateNN = date else {
            return nil
        }
        let day = NSCalendar.currentCalendar().startOfDayForDate(dateNN)
        return WeatherData(date: day, condition: condition, advisory: advisory, cloudiness: cloudiness, temperature: temperature, low: low, high: high, humidity: humidity, wind: wind)
    }
    
    static func summarizeByDay(forecasts: [WeatherData]) -> [WeatherData] {
        let calendar = NSCalendar.currentCalendar()
        var groups = [NSDate: [WeatherData]]()
        for forecast in forecasts {
            let day = calendar.startOfDayForDate(forecast.date)
            if groups[day] == nil {
                groups[day] = []
            }
            groups[day]?.append(forecast)
        }
        var results = [WeatherData]()
        for (_, items) in groups {
            guard let summary = WeatherData.summarize(items) else {
                continue
            }
            results.append(summary)
        }
        return results.sort({ $0.date.timeIntervalSinceDate($1.date) < 0 })
    }
    
    let date: NSDate
    let condition: WeatherCondition
    let advisory: WeatherAdvisory?
    let cloudiness: Double
    let temperature: Double
    let low: Double
    let high: Double
    let humidity: Double
    let wind: Double
    
    init(date: NSDate, condition: WeatherCondition, advisory: WeatherAdvisory?, cloudiness: Double, temperature: Double, low: Double, high: Double, humidity: Double, wind: Double) {
        self.date = date
        self.condition = condition
        self.advisory = advisory
        self.cloudiness = cloudiness
        self.temperature = temperature
        self.low = low
        self.high = high
        self.humidity = humidity
        self.wind = wind
    }
    
    init(_ owmData: OpenWeatherMapWeatherData) {
        if let date = owmData.date {
            self.date = date
        } else {
            self.date = NSDate()
        }
        if let conditions = owmData.weather, condition = WeatherCondition.summarize(conditions) {
            self.condition = condition
        } else {
            self.condition = .Clear
        }
        if let advisories = owmData.weather?.map({ WeatherAdvisory.from($0) }).filter({ $0 != nil }) as? [WeatherAdvisory] {
            self.advisory = advisories.first
        } else {
            self.advisory = nil
        }
        if let cloudiness = owmData.clouds?.all {
            self.cloudiness = cloudiness
        } else {
            self.cloudiness = 0
        }
        if let temp = owmData.main?.temperatureC {
            self.temperature = temp
        } else {
            self.temperature = 0
        }
        if let low = owmData.main?.temperatureMinC {
            self.low = low
        } else {
            self.low = 0
        }
        if let high = owmData.main?.temperatureMaxC {
            self.high = high
        } else {
            self.high = 0
        }
        if let humidity = owmData.main?.humidity {
            self.humidity = humidity
        } else {
            self.humidity = 0
        }
        if let wind = owmData.wind?.speed {
            self.wind = wind
        } else {
            self.wind = 0
        }
    }
}