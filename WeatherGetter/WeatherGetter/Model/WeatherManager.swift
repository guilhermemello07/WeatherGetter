//
//  WeatherManager.swift
//  WeatherGetter
//
//  Created by Guilherme Mello on 22/10/23.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(_ weatherManager: WeatherManager, error: Error)
}

struct WeatherManager {
    
    var YOUR_API_KEY: String?
    
    let weatherBaseURL = "https://api.openweathermap.org/data/2.5/weather?appid="
    
    let units = "units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(for cityName: String) {
        if let YOUR_API_KEY {
            let urlString = "\(weatherBaseURL)\(YOUR_API_KEY)&\(units)&q=\(cityName)"
            performRequest(from: urlString)
        }
    }
    
    func fetchWeather(latitude: Double, longitude: Double) {
        if let YOUR_API_KEY {
            let urlString = "\(weatherBaseURL)\(YOUR_API_KEY)&\(units)&lat=\(latitude)&lon=\(longitude)"
            performRequest(from: urlString)
        }
    }
    
    func performRequest(from urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(self, error: error!)
                }
                if let safeData = data {
                    if let weather = self.parseJSON(weatherData: safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(WeatherData.self, from: weatherData)
            let id = result.weather[0].id
            let name = result.name
            let temperature = result.main.temp
            let conditionDescription = result.weather[0].description.capitalized
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temperature, description: conditionDescription)
            return weather
        } catch {
            self.delegate?.didFailWithError(self, error: error)
            return nil
        }
    }
}
