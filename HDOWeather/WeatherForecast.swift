//
//  WeatherForecast.swift
//  HDOWeather
//
//  Created by Daniel Nichols on 5/17/16.
//  Copyright © 2016 Hey Danno. All rights reserved.
//

import Foundation

struct WeatherForecast {
    
    static func from(payload: OpenWeatherMapResponsePayload) -> WeatherForecast? {
        guard let city = payload.city, list = payload.list else {
            return nil
        }
        var forecasts: [WeatherData] = []
        for item in list {
            let forecast = WeatherData(item)
            forecasts.append(forecast)
        }
        let location = WeatherLocation(city)
        let summaries = WeatherData.summarizeByDay(forecasts)
        return WeatherForecast(location: location, summaries: summaries)
    }
    
    let location: WeatherLocation
    let summaries: [WeatherData]
}