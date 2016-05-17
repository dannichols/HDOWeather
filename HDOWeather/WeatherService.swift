//
//  WeatherService.swift
//  HDOWeather
//
//  Created by Daniel Nichols on 5/17/16.
//  Copyright © 2016 Hey Danno. All rights reserved.
//

import Foundation
import HDOLocation
import HDOPromise

class WeatherService {
    
    init() {
        // Do nothing
    }
    
    func forecast() -> Promise<WeatherForecast> {
        return Promise { (onFulfilled, onRejected) in
            self._locationService
                .current()
                .then { [weak self] (location) in
                    guard let me = self else {
                        onRejected(NSError(domain: "com.heydanno.HDOWeather", code: 400, userInfo: ["message": "Service no longer exists"]))
                        return
                    }
                    me._openWeatherMapService
                        .forecastForLatitude(location.coordinate.latitude, longitude: location.coordinate.longitude)
                        .then { (payload) in
                            guard let forecast = WeatherForecast.from(payload) else {
                                onRejected(NSError(domain: "com.heydanno.HDOWeather", code: 500, userInfo: ["message": "Data was not in expected format"]))
                                return
                            }
                            onFulfilled(forecast)
                        }
                        .error(onRejected)
                }
                .error(onRejected)
        }
    }
    
    // Private
    
    private lazy var _locationService: LocationService = {
        return LocationService()
    }()
    
    private lazy var _openWeatherMapService: OpenWeatherMapService = {
        guard let appID: String = Config.plist("OpenWeatherMap", key: "AppID") else {
            print("OpenWeatherMap.plist is missing key AppID")
            fatalError()
        }
        return OpenWeatherMapService(appID: appID)
    }()
}