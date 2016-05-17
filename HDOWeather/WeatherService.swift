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
    
    func forecast() {
        
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