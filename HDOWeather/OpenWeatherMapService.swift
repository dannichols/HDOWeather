//
//  OpenWeatherMapService.swift
//  HDOWeather
//
//  Created by Daniel Nichols on 5/15/16.
//  Copyright © 2016 Hey Danno. All rights reserved.
//

import HDOService
import HDOPromise

class OpenWeatherMapServiceResponse: DecoderServiceResponse<OpenWeatherMapResponsePayload> {

    required init(response: NSHTTPURLResponse, data: NSData?) {
        super.init(response: response, data: data)
    }
    
    override func decode(data: NSData) throws -> OpenWeatherMapResponsePayload? {
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
            return OpenWeatherMapResponsePayload.fromJSON(json as? JSONDictionary)
        } catch {
            return nil
        }
    }
}

class OpenWeatherMapService: Service {
    
    typealias Payload = Promise<OpenWeatherMapResponsePayload>
    
    private(set) var baseURL = NSURL(string: "http://api.openweathermap.org/data/2.5/")
    private(set) var appID: String
    
    init(appID: String) {
        self.appID = appID
    }
    
    func weatherForCity(city: String, country: String?) -> Payload {
        let q: String
        if let country = country {
            q = "\(city),\(country)"
        } else {
            q = city
        }
        return self.send("weather", ["q": q])
    }
    
    func weatherForCity(city: String) -> Payload {
        return self.weatherForCity(city, country: nil)
    }
    
    func weatherForCityID(id: String) -> Payload {
        return self.send("weather", ["id": id])
    }
    
    func weatherForLatitude(latitude: Double, longitude: Double) -> Payload {
        return self.send("weather", ["lat": latitude, "lon": longitude])
    }
    
    func weatherForZIPCode(zip: String) -> Payload {
        return self.send("weather", ["zip": zip])
    }
    
    func forecastForCity(city: String, country: String?) -> Payload {
        let q: String
        if let country = country {
            q = "\(city),\(country)"
        } else {
            q = city
        }
        return self.send("forecast", ["q": q])
    }
    
    func forecastForCity(city: String) -> Payload {
        return self.forecastForCity(city, country: nil)
    }
    
    func forecastForLatitude(latitude: Double, longitude: Double) -> Payload {
        return self.send("forecast", ["lat": latitude, "lon": longitude])
    }
    
    func forecastForZIPCode(zip: String) -> Payload {
        return self.send("forecast", ["zip": zip])
    }
    
    // Private
    
    private func send(endpoint: String, _ params: ServiceRequestQuery) -> Payload {
        return Promise { (onFulfilled, onRejected) in
            var query = params
            query["appid"] = self.appID
            self.GET(endpoint, query)
                .then { (response: OpenWeatherMapServiceResponse) in
                    response.parse()
                        .then { (payload) in
                            guard let payload = payload else {
                                onRejected(NSError(domain: "com.heydanno.HDOWeather", code: 404, userInfo: ["message": "No data"]))
                                return
                            }
                            guard !payload.isError else {
                                let code: Int, message: String
                                if let payloadCode = payload.code {
                                    code = payloadCode
                                } else {
                                    code = -1
                                }
                                if let payloadMessage = payload.message {
                                    message = payloadMessage
                                } else {
                                    message = "Received error payload"
                                }
                                onRejected(NSError(domain: "com.heydanno.HDOWeather.OWM", code: code, userInfo: ["message": message, "payload": payload]))
                                return
                            }
                            onFulfilled(payload)
                        }
                        .error { (error) in
                            onRejected(error)
                        }
                }
                .error { (error) in
                    onRejected(error)
                }
        }
    }
}
