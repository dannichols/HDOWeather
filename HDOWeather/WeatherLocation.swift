//
//  WeatherLocation.swift
//  HDOWeather
//
//  Created by Daniel Nichols on 5/17/16.
//  Copyright © 2016 Hey Danno. All rights reserved.
//

import Foundation
import CoreLocation

struct WeatherLocation {
    let name: String
    let country: String
    let coordinates: CLLocationCoordinate2D
    
    init() {
        self.name = "Unknown"
        self.country = "Unknown"
        self.coordinates = CLLocationCoordinate2D()
    }
    
    init(_ owmCity: OpenWeatherMapCity) {
        if let name = owmCity.name {
            self.name = name
        } else {
            self.name = ""
        }
        if let country = owmCity.country {
            self.country = country
        } else {
            self.country = ""
        }
        if let coords = owmCity.coordinates, lat = coords.latitude, lon = coords.longitude {
            self.coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        } else {
            self.coordinates = CLLocationCoordinate2D.init()
        }
    }
}
