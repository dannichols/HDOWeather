//
//  OpenWeatherMapResponsePayload.swift
//  HDOWeather
//
//  Created by Daniel Nichols on 5/16/16.
//  Copyright © 2016 Hey Danno. All rights reserved.
//

import Foundation
import HDOService

class OpenWeatherMapModel {
    required init(_ json: JSONDictionary) {
        
    }
    
    class func fromJSON(json: JSONDictionary?) -> Self? {
        guard let json = json else {
            return nil
        }
        return self.init(json)
    }
}

class OpenWeatherMapResponsePayload: OpenWeatherMapModel {
    let code: Int?
    let message: String?
    let city: OpenWeatherMapCity?
    let list: [OpenWeatherMapWeatherData]?
    
    var isError: Bool {
        get {
            return self.code >= 400
        }
    }
    
    required init(_ json: JSONDictionary) {
        // cod field is inconsistently typed between calls
        if let codeRaw = json["cod"] as? String {
            self.code = Int(codeRaw)
        } else {
            self.code = json["cod"] as? Int
        }
        self.message = json["message"] as? String
        if let cityRaw = json["city"] as? JSONDictionary {
            self.city = OpenWeatherMapCity.fromJSON(cityRaw)
        } else {
            self.city = OpenWeatherMapCity.fromJSON(json)
            self.city?.country = (json["sys"] as? JSONDictionary)?["country"] as? String
        }
        if let listRaw = json["list"] as? [JSONDictionary] {
            self.list = listRaw.map({ OpenWeatherMapWeatherData.fromJSON($0) }).filter({ $0 != nil }).map({ $0! })
        } else if let data = OpenWeatherMapWeatherData.fromJSON(json) {
            self.list = [data]
        } else {
            self.list = nil
        }
        super.init(json)
    }
}

class OpenWeatherMapCity: OpenWeatherMapModel {
    let id: String?
    let name: String?
    let coordinates: OpenWeatherMapGeocoordinates?
    
    // Note: Strange circumstance where data for country comes from a separate object, necessitating private(set) instead of let
    private(set) var country: String?
    
    required init(_ json: JSONDictionary) {
        self.id = json["id"] as? String
        self.name = json["name"] as? String
        self.coordinates = OpenWeatherMapGeocoordinates.fromJSON(json["coord"] as? JSONDictionary)
        self.country = json["country"] as? String
        super.init(json)
    }
}

class OpenWeatherMapGeocoordinates: OpenWeatherMapModel {
    let latitude: Double?
    let longitude: Double?
    
    required init(_ json: JSONDictionary) {
        self.latitude = json["lat"] as? Double
        self.longitude = json["lon"] as? Double
        super.init(json)
    }
}

class OpenWeatherMapWeatherData: OpenWeatherMapModel {
    let date: NSDate?
    let main: OpenWeatherMapMeasurement?
    let weather: [OpenWeatherMapCondition]?
    let clouds: OpenWeatherMapCloud?
    let wind: OpenWeatherMapWind?
    let rain: OpenWeatherMapPrecipitation?
    let snow: OpenWeatherMapPrecipitation?
    let sunrise: NSDate?
    let sunset: NSDate?
    
    required init(_ json: JSONDictionary) {
        if let dateRaw = json["dt"] as? NSTimeInterval {
            self.date = NSDate(timeIntervalSince1970: dateRaw)
        } else {
            self.date = nil
        }
        self.main = OpenWeatherMapMeasurement.fromJSON(json["main"] as? JSONDictionary)
        if let weatherListRaw = json["weather"] as? [JSONDictionary] {
            self.weather = weatherListRaw.map({ OpenWeatherMapCondition.fromJSON($0) }).filter({ $0 != nil }).map({ $0! })
        } else if let weatherRaw = json["weather"] as? JSONDictionary, weatherData = OpenWeatherMapCondition.fromJSON(weatherRaw) {
            self.weather = [weatherData]
        } else {
            self.weather = nil
        }
        self.clouds = OpenWeatherMapCloud.fromJSON(json["clouds"] as? JSONDictionary)
        self.wind = OpenWeatherMapWind.fromJSON(json["wind"] as? JSONDictionary)
        self.rain = OpenWeatherMapPrecipitation.fromJSON(json["rain"] as? JSONDictionary)
        self.snow = OpenWeatherMapPrecipitation.fromJSON(json["snow"] as? JSONDictionary)
        if let sys = json["sys"] as? JSONDictionary, sunriseRaw = sys["sunrise"] as? NSTimeInterval, sunsetRaw = sys["sunset"] as? NSTimeInterval {
            self.sunrise = NSDate(timeIntervalSince1970: sunriseRaw)
            self.sunset = NSDate(timeIntervalSince1970: sunsetRaw)
        } else {
            self.sunrise = nil
            self.sunset = nil
        }
        super.init(json)
    }
}

class OpenWeatherMapMeasurement: OpenWeatherMapModel {
    let temperatureK: Double?
    let temperatureMinK: Double?
    let temperatureMaxK: Double?
    let pressure: Double?
    let seaLevel: Double?
    let groundLevel: Double?
    let humidity: Double?
    
    var temperatureC: Double? {
        get {
            return self.kelvinToCelsius(self.temperatureK)
        }
    }
    
    var temperatureMinC: Double? {
        get {
            return self.kelvinToCelsius(self.temperatureMinK)
        }
    }
    
    var temperatureMaxC: Double? {
        get {
            return self.kelvinToCelsius(self.temperatureMaxK)
        }
    }
    
    var temperatureF: Double? {
        get {
            return self.kelvinToFahrenheit(self.temperatureK)
        }
    }
    
    var temperatureMinF: Double? {
        get {
            return self.kelvinToFahrenheit(self.temperatureMinK)
        }
    }
    
    var temperatureMaxF: Double? {
        get {
            return self.kelvinToFahrenheit(self.temperatureMaxK)
        }
    }
    
    required init(_ json: JSONDictionary) {
        self.temperatureK = json["temp"] as? Double
        self.temperatureMinK = json["temp_min"] as? Double
        self.temperatureMaxK = json["temp_max"] as? Double
        self.pressure = json["pressure"] as? Double
        self.seaLevel = json["sea_level"] as? Double
        self.groundLevel = json["grnd_level"] as? Double
        self.humidity = json["humidity"] as? Double
        super.init(json)
    }
    
    // Private
    
    private func kelvinToCelsius(k: Double?) -> Double? {
        guard let k = k else {
            return nil
        }
        return k - 273.15
    }
    
    private func kelvinToFahrenheit(k: Double?) -> Double? {
        guard let c = self.kelvinToCelsius(k) else {
            return nil
        }
        return c * 1.8 + 32
    }
}

class OpenWeatherMapCondition: OpenWeatherMapModel {
    let id: Int?
    let main: String?
    let description: String?
    let icon: String?
    
    required init(_ json: JSONDictionary) {
        self.id = json["id"] as? Int
        self.main = json["main"] as? String
        self.description = json["description"] as? String
        self.icon = json["icon"] as? String
        super.init(json)
    }
}

class OpenWeatherMapCloud: OpenWeatherMapModel {
    let all: Double?
    
    required init(_ json: JSONDictionary) {
        self.all = json["all"] as? Double
        super.init(json)
    }
}

class OpenWeatherMapWind: OpenWeatherMapModel {
    let speed: Double?
    let degrees: Double?
    
    required init(_ json: JSONDictionary) {
        self.speed = json["speed"] as? Double
        self.degrees = json["deg"] as? Double
        super.init(json)
    }
}

class OpenWeatherMapPrecipitation: OpenWeatherMapModel {
    let volumeLastThreeHoursMM: Double?
    
    required init(_ json: JSONDictionary) {
        self.volumeLastThreeHoursMM = json["3h"] as? Double
        super.init(json)
    }
}